import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';
import '../../../services/loading_service.dart';
import '../../../services/fees_repository.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  String? _studentId;
  bool _isLoadingId = true;

  Future<void> _initRepo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('student_id') ?? prefs.getString('user_uid');
    setState(() {
      _studentId = id;
      _isLoadingId = false;
    });
    if (id != null) {
      await FeesRepository.instance.ensureListening(id);
    }
  }

  @override
  void initState() {
    super.initState();
    _initRepo();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LoadingService().show();
      });
      return const SizedBox.shrink();
    }

    if (_studentId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LoadingService().hide();
      });
      return const Center(
        child: Text("Student ID not found. Please login again."),
      );
    }

    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: FeesRepository.instance.data,
      builder: (context, feesData, _) {
        if (_isLoadingId && feesData == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LoadingService().show();
          });
          return const SizedBox.shrink();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          LoadingService().hide();
        });

        List<Map<String, dynamic>> invoices = [];
        double totalPending = 0.0;
        double totalPaid = 0.0;
        bool docExists = feesData != null;
        double yearlyAmount = 0.0;
        String yearlyStatus = 'Unpaid';

        if (docExists) {
          final data = feesData!;

          if (data['yearly_fund'] is Map) {
            final yf = Map<String, dynamic>.from(data['yearly_fund'] as Map);
            yearlyAmount = double.tryParse(yf['amount']?.toString() ?? '0') ?? 0.0;
            yearlyStatus = yf['status']?.toString() ?? 'Unpaid';
          }

          // Define month order for sorting
          final monthsOrder = {
            'Jan': 1,
            'Feb': 2,
            'Mar': 3,
            'Apr': 4,
            'May': 5,
            'Jun': 6,
            'Jul': 7,
            'Aug': 8,
            'Sep': 9,
            'Oct': 10,
            'Nov': 11,
            'Dec': 12,
          };

          data.forEach((key, value) {
            // Check if the value is a Map (which represents the fee details for a month)
            if (value is Map) {
              // Safely cast the map to ensure string keys are accessible
              final monthData = Map<String, dynamic>.from(value as Map);

              final status = monthData['status']?.toString() ?? 'Pending';
              final totalFee =
                  double.tryParse(monthData['total_fee'].toString()) ?? 0.0;
              final payable =
                  double.tryParse(monthData['payable'].toString()) ?? 0.0;

              // Normalize key for sorting (trim and match case if possible)
              String displayMonth = key;
              int sortIndex = 99;

              // Try to find matching month in monthsOrder (case-insensitive)
              for (var mKey in monthsOrder.keys) {
                if (mKey.toLowerCase() == key.trim().toLowerCase()) {
                  sortIndex = monthsOrder[mKey]!;
                  displayMonth = mKey; // Use standard formatting
                  break;
                }
              }

              // Only add if it looks like a fee record (has amount or is a known month)
              if (sortIndex != 99 || totalFee > 0 || payable > 0) {
                invoices.add({
                  'month': displayMonth, // Use the matched key or original
                  'amount': totalFee,
                  'payable': payable,
                  'status': status,
                  'sortIndex': sortIndex,
                });

                if (status == 'Paid') {
                  totalPaid += totalFee;
                } else {
                  totalPending += totalFee;
                }
              }
            }
          });

          // Sort invoices by month
          invoices.sort(
            (a, b) => (a['sortIndex'] as int).compareTo(b['sortIndex'] as int),
          );
        }

        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(
                top: 56,
                left: 20,
                right: 20,
                bottom: 28,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.deepBlue,
                    Color(0xFF003380),
                    AppColors.maroon,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              width: double.infinity,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Invoices",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Fee history & payments",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  // Summary Section
                  _buildSummaryCard(totalPending, totalPaid),

                  const SizedBox(height: 20),

                  _buildYearlyFundCard(amount: yearlyAmount, status: yearlyStatus),

                  const SizedBox(height: 20),

                  // Monthly Fee List
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.maroon.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.maroon,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Monthly Fees",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepBlue,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (!docExists)
                    _buildEmptyState(
                      icon: Icons.folder_off_rounded,
                      title: "No fee record yet",
                      subtitle: "Your fee history will show here once added.",
                    )
                  else if (invoices.isEmpty)
                    _buildEmptyState(
                      icon: Icons.description_outlined,
                      title: "No invoices yet",
                      subtitle: "Monthly fee details will appear here.",
                    ),

                  ...invoices.map((invoice) {
                    final amount = invoice['amount'] as double? ?? 0.0;
                    final payable = invoice['payable'] as double? ?? 0.0;

                    return _buildFeeItem(
                      month: invoice['month'] ?? 'Unknown Month',
                      totalAmount: amount,
                      payableAmount: payable,
                      status: invoice['status'] ?? 'Pending',
                      isPaid: invoice['status'] == 'Paid',
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.deepBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppColors.deepBlue.withOpacity(0.6)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.deepBlue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double totalPending, double totalPaid) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.deepBlue,
            Color(0xFF003380),
            AppColors.maroon,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Total Pending",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Rs ${totalPending.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildPaperFundCard(String status) {
    final isPaid = status == 'Paid';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.deepBlue.withOpacity(0.12),
                      AppColors.maroon.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.deepBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Paper Fund",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Books & materials",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isPaid
                  ? const Color(0xFF22C55E).withOpacity(0.12)
                  : const Color(0xFFF59E0B).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isPaid ? const Color(0xFF22C55E) : const Color(0xFFF59E0B))
                      .withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyFundCard({required double amount, required String status}) {
    final isPaid = status == 'Paid';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.deepBlue.withOpacity(0.12),
                      AppColors.maroon.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: AppColors.deepBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Yearly Fund",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Amount: Rs ${amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isPaid
                  ? const Color(0xFF22C55E).withOpacity(0.12)
                  : const Color(0xFFF59E0B).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isPaid ? const Color(0xFF22C55E) : const Color(0xFFF59E0B))
                      .withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isPaid ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItem({
    required String month,
    required double totalAmount,
    required double payableAmount,
    required String status,
    required bool isPaid,
  }) {
    final Color statusColor = isPaid
        ? const Color(0xFF22C55E)
        : AppColors.maroon;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    month,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Total: Rs ${totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (payableAmount > 0)
                    Text(
                      "Payable: Rs ${payableAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.maroon.withOpacity(0.9),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              if (!isPaid) ...[
                const SizedBox(height: 10),
                Text(
                  "Pay at office",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepBlue.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
