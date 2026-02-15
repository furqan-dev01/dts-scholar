import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../config/firestore_config.dart';
import '../../../theme/app_colors.dart';

class FeeSummaryCharts extends StatefulWidget {
  final String schoolId;

  const FeeSummaryCharts({super.key, required this.schoolId});

  @override
  State<FeeSummaryCharts> createState() => _FeeSummaryChartsState();
}

class _FeeSummaryChartsState extends State<FeeSummaryCharts> {
  final PageController _pageController = PageController(
    viewportFraction: 0.85,
    initialPage: 0,
  );
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreConfig.studentsCollection
          .where('school_id', isEqualTo: widget.schoolId)
          .snapshots(),
      builder: (context, studentSnapshot) {
        if (studentSnapshot.connectionState == ConnectionState.waiting &&
            !studentSnapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final studentDocs = studentSnapshot.data?.docs ?? [];
        final studentIds = studentDocs.map((doc) => doc.id).toList();

        if (studentIds.isEmpty &&
            studentSnapshot.connectionState != ConnectionState.waiting) {
          return _buildEmptyState('No students found in this school');
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirestoreConfig.feesCollection.snapshots(),
          builder: (context, feeSnapshot) {
            if (feeSnapshot.connectionState == ConnectionState.waiting &&
                !feeSnapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            final schoolFees =
                feeSnapshot.data?.docs
                    .where((doc) => studentIds.contains(doc.id))
                    .toList() ??
                [];

            final now = DateTime.now();
            final months = [
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

            final currentMonth = months[now.month - 1];
            int prevMonthIdx = now.month - 2;
            if (prevMonthIdx < 0) prevMonthIdx = 11;
            final prevMonth = months[prevMonthIdx];

            final currentStats = _calculateStats(schoolFees, currentMonth);
            final prevStats = _calculateStats(schoolFees, prevMonth);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(),
                const SizedBox(height: 12),
                SizedBox(
                  height: 380,
                  child: PageView(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    physics: const PageScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    clipBehavior: Clip.none,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      _buildModernChartCard(
                        context,
                        "Current Month",
                        currentMonth,
                        currentStats,
                      ),
                      _buildModernChartCard(
                        context,
                        "Previous Month",
                        prevMonth,
                        prevStats,
                      ),
                    ],
                  ),
                ),
                _buildPageIndicator(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.deepBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: AppColors.deepBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Fee Analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.deepBlue
                : AppColors.deepBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400], size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  _Stats _calculateStats(List<QueryDocumentSnapshot> fees, String month) {
    int paidCount = 0;
    int unpaidCount = 0;
    int partiallyPaidCount = 0;

    for (var doc in fees) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey(month)) {
        final monthData = data[month] as Map<String, dynamic>;
        final status = monthData['status']?.toString() ?? 'Unpaid';

        if (status == 'Paid') {
          paidCount++;
        } else if (status == 'Partially Paid') {
          partiallyPaidCount++;
        } else {
          unpaidCount++;
        }
      } else {
        unpaidCount++;
      }
    }

    return _Stats(
      paid: paidCount.toDouble(),
      unpaid: unpaidCount.toDouble(),
      partiallyPaid: partiallyPaidCount.toDouble(),
    );
  }

  Widget _buildModernChartCard(
    BuildContext context,
    String title,
    String monthName,
    _Stats stats,
  ) {
    final total = stats.paid + stats.unpaid + stats.partiallyPaid;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      monthName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepBlue,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${total.toInt()} Students',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepBlue,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (total == 0)
              _buildNoDataState()
            else
              _buildChartWithCenterText(stats, total),
            const Spacer(),
            _buildDetailedLegend(stats),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.pie_chart_outline_rounded,
          size: 60,
          color: Colors.grey[200],
        ),
        const SizedBox(height: 12),
        Text(
          "No data available",
          style: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildChartWithCenterText(_Stats stats, double total) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: [
                if (stats.paid > 0)
                  PieChartSectionData(
                    color: const Color(0xFF4CAF50),
                    value: stats.paid,
                    title: '',
                    radius: 22,
                    showTitle: false,
                  ),
                if (stats.partiallyPaid > 0)
                  PieChartSectionData(
                    color: const Color(0xFFFFB74D),
                    value: stats.partiallyPaid,
                    title: '',
                    radius: 22,
                    showTitle: false,
                  ),
                if (stats.unpaid > 0)
                  PieChartSectionData(
                    color: const Color(0xFFE57373),
                    value: stats.unpaid,
                    title: '',
                    radius: 22,
                    showTitle: false,
                  ),
              ],
              sectionsSpace: 4,
              centerSpaceRadius: 50,
              borderData: FlBorderData(show: false),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${((stats.paid / total) * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBlue,
                ),
              ),
              const Text(
                'Paid',
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
    );
  }

  Widget _buildDetailedLegend(_Stats stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLegendItem(const Color(0xFF4CAF50), "Paid", stats.paid.toInt()),
        _buildLegendItem(
          const Color(0xFFFFB74D),
          "Partial",
          stats.partiallyPaid.toInt(),
        ),
        _buildLegendItem(
          const Color(0xFFE57373),
          "Unpaid",
          stats.unpaid.toInt(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _Stats {
  final double paid;
  final double unpaid;
  final double partiallyPaid;
  _Stats({
    required this.paid,
    required this.unpaid,
    required this.partiallyPaid,
  });
}
