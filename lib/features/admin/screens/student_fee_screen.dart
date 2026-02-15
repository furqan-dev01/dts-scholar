import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_colors.dart';
import '../../../config/firestore_config.dart';

class StudentFeeScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const StudentFeeScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentFeeScreen> createState() => _StudentFeeScreenState();
}

class _StudentFeeScreenState extends State<StudentFeeScreen> {
  final List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  Map<String, dynamic>? _feeData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeeData();
  }

  Future<void> _fetchFeeData() async {
    try {
      final doc = await FirestoreConfig.feesCollection
          .doc(widget.studentId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure yearly_fund exists
        if (!data.containsKey('yearly_fund')) {
          data['yearly_fund'] = {'amount': 0, 'status': 'Unpaid'};
        }
        setState(() {
          _feeData = data;
          _isLoading = false;
        });
      } else {
        // Initialize empty data if not exists
        final initialData = <String, dynamic>{};
        for (var month in _months) {
          initialData[month] = {
            'total_fee': 0,
            'payable': 0,
            'status': 'Unpaid',
          };
        }
        initialData['yearly_fund'] = {'amount': 0, 'status': 'Unpaid'};
        setState(() {
          _feeData = initialData;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading fees: $e')));
      }
    }
  }

  Future<void> _saveFees() async {
    if (_feeData == null) return;

    try {
      await FirestoreConfig.feesCollection
          .doc(widget.studentId)
          .set(_feeData!, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fees updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving fees: $e'),
            backgroundColor: AppColors.maroon,
          ),
        );
      }
    }
  }

  void _updateMonthData(String month, String field, dynamic value) {
    setState(() {
      if (_feeData![month] == null) {
        _feeData![month] = {'total_fee': 0, 'payable': 0, 'status': 'Unpaid'};
      }
      // Ensure the month data is a Map we can modify
      if (_feeData![month] is! Map) {
        _feeData![month] = Map<String, dynamic>.from(_feeData![month] as Map);
      }

      _feeData![month][field] = value;

      // Auto-update status based on total_fee and payable (paid amount)
      if (field == 'total_fee' || field == 'payable') {
        final total =
            double.tryParse(_feeData![month]['total_fee']?.toString() ?? '0') ??
            0;
        final paid =
            double.tryParse(_feeData![month]['payable']?.toString() ?? '0') ??
            0;

        String newStatus = _feeData![month]['status'] ?? 'Unpaid';

        if (total != 0 && total == paid) {
          newStatus = 'Paid';
        } else if (paid == 0) {
          newStatus = 'Unpaid';
        } else if (total > paid && paid > 0) {
          newStatus = 'Partially Paid';
        }

        _feeData![month]['status'] = newStatus;
      }
    });
  }

  void _updateYearlyFund(String field, dynamic value) {
    setState(() {
      if (_feeData!['yearly_fund'] == null) {
        _feeData!['yearly_fund'] = {'amount': 0, 'status': 'Unpaid'};
      }
      if (_feeData!['yearly_fund'] is! Map) {
        _feeData!['yearly_fund'] = Map<String, dynamic>.from(
          _feeData!['yearly_fund'] as Map,
        );
      }
      _feeData!['yearly_fund'][field] = value;
    });
  }

  Map<String, double> _calculateTotals() {
    double totalFees = 0;
    double totalPaid = 0;

    if (_feeData == null) return {'total': 0, 'paid': 0, 'pending': 0};

    for (var month in _months) {
      final data = _feeData![month];
      if (data != null && data is Map) {
        final total =
            double.tryParse(data['total_fee']?.toString() ?? '0') ?? 0;
        final paid = double.tryParse(data['payable']?.toString() ?? '0') ?? 0;

        totalFees += total;
        totalPaid += paid;
      }
    }

    return {
      'total': totalFees,
      'paid': totalPaid,
      'pending': totalFees - totalPaid,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(child: _buildSummaryHeader(totals)),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == 0) {
                        final fundData =
                            _feeData?['yearly_fund'] ??
                            {'amount': 0, 'status': 'Unpaid'};
                        return _YearlyFundCard(
                          data: fundData,
                          onUpdate: _updateYearlyFund,
                        );
                      }
                      final month = _months[index - 1];
                      final data =
                          _feeData?[month] ??
                          {'total_fee': 0, 'payable': 0, 'status': 'Unpaid'};

                      return _MonthFeeCard(
                        month: month,
                        data: data,
                        onUpdate: (field, value) =>
                            _updateMonthData(month, field, value),
                      );
                    }, childCount: _months.length + 1),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveFees,
        elevation: 4,
        highlightElevation: 8,
        backgroundColor: AppColors.deepBlue,
        icon: const Icon(Icons.save_rounded, color: Colors.white),
        label: const Text(
          'Save Fee Data',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.deepBlue,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          widget.studentName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withOpacity(0.05),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 40,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.05),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: _fetchFeeData,
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(Map<String, double> totals) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'Total Amount',
                totals['total']!,
                AppColors.deepBlue,
                Icons.account_balance_wallet_rounded,
              ),
              _buildSummaryItem(
                'Total Paid',
                totals['paid']!,
                Colors.green,
                Icons.check_circle_rounded,
              ),
              _buildSummaryItem(
                'Balance Due',
                totals['pending']!,
                Colors.orange,
                Icons.pending_actions_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rs${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthCard(String month, Map<dynamic, dynamic> data) {
    // Ensure we don't lose focus by recreating controllers every build
    // But for this simple list, it's okay, or we could use KeyedSubtree.
    // Ideally, we should use a stateful widget for each card to hold controllers.
    // However, to keep it simple and responsive, we will rely on onChanged updating the state.

    // NOTE: Creating controllers inside build method causes cursor reset issues.
    // We should use initialValue in TextFormField or manage controllers better.
    // Switching to TextFormField with initialValue is better for this stateless-like build.

    return _MonthFeeCard(
      month: month,
      data: data,
      onUpdate: (field, value) => _updateMonthData(month, field, value),
    );
  }
}

class _MonthFeeCard extends StatefulWidget {
  final String month;
  final Map<dynamic, dynamic> data;
  final Function(String, dynamic) onUpdate;

  const _MonthFeeCard({
    required this.month,
    required this.data,
    required this.onUpdate,
  });

  @override
  State<_MonthFeeCard> createState() => _MonthFeeCardState();
}

class _MonthFeeCardState extends State<_MonthFeeCard> {
  late TextEditingController _totalController;
  late TextEditingController _payableController;

  @override
  void initState() {
    super.initState();
    _totalController = TextEditingController(
      text: widget.data['total_fee']?.toString() ?? '0',
    );
    _payableController = TextEditingController(
      text: widget.data['payable']?.toString() ?? '0',
    );
  }

  @override
  void didUpdateWidget(covariant _MonthFeeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month) {
      _totalController.text = widget.data['total_fee']?.toString() ?? '0';
      _payableController.text = widget.data['payable']?.toString() ?? '0';
    }
    // Update controllers if values change externally (e.g. status auto-update logic might not change text, but if we wanted to enforce consistency)
    // However, for text fields, we usually don't force update while typing.
  }

  @override
  void dispose() {
    _totalController.dispose();
    _payableController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Partially Paid':
        return Colors.orange;
      case 'Unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.data['status']?.toString() ?? 'Unpaid';
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.15), width: 1),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        status == 'Paid'
                            ? Icons.check_circle_rounded
                            : status == 'Partially Paid'
                            ? Icons.pending_rounded
                            : Icons.error_outline_rounded,
                        color: statusColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.month,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:
                          ['Paid', 'Unpaid', 'Partially Paid'].contains(status)
                          ? status
                          : 'Unpaid',
                      isDense: true,
                      borderRadius: BorderRadius.circular(12),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      items: ['Paid', 'Unpaid', 'Partially Paid'].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: _getStatusColor(value),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          widget.onUpdate('status', newValue);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _totalController,
                    label: 'Expected Fee',
                    icon: Icons.account_balance_rounded,
                    onChanged: (val) =>
                        widget.onUpdate('total_fee', int.tryParse(val) ?? 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    controller: _payableController,
                    label: 'Received Amount',
                    icon: Icons.payments_rounded,
                    onChanged: (val) =>
                        widget.onUpdate('payable', int.tryParse(val) ?? 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.deepBlue,
          ),
          decoration: InputDecoration(
            isDense: true,
            prefixText: 'Rs ',
            prefixStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[100]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.deepBlue,
                width: 1.5,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _YearlyFundCard extends StatefulWidget {
  final Map<dynamic, dynamic> data;
  final Function(String, dynamic) onUpdate;

  const _YearlyFundCard({required this.data, required this.onUpdate});

  @override
  State<_YearlyFundCard> createState() => _YearlyFundCardState();
}

class _YearlyFundCardState extends State<_YearlyFundCard> {
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.data['amount']?.toString() ?? '0',
    );
  }

  @override
  void didUpdateWidget(covariant _YearlyFundCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data['amount'] != widget.data['amount']) {
      _amountController.text = widget.data['amount']?.toString() ?? '0';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    return status == 'Paid' ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.data['status']?.toString() ?? 'Unpaid';
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.deepBlue.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.deepBlue.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: AppColors.deepBlue,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Yearly Fund Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepBlue,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: status == 'Paid' ? 'Paid' : 'Unpaid',
                      isDense: true,
                      icon: Icon(Icons.arrow_drop_down, color: statusColor),
                      items: ['Paid', 'Unpaid'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: value == 'Paid'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          widget.onUpdate('status', newValue);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  controller: _amountController,
                  label: 'Fund Amount',
                  onChanged: (val) =>
                      widget.onUpdate('amount', int.tryParse(val) ?? 0),
                ),
                const SizedBox(height: 8),
                Text(
                  'This is a one-time fund submission for the academic year.',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            isDense: true,
            prefixText: 'Rs ',
            prefixStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.deepBlue, width: 1),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
