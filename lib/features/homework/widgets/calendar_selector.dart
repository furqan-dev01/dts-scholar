import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class CalendarSelector extends StatefulWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  const CalendarSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<CalendarSelector> createState() => _CalendarSelectorState();
}

class _CalendarSelectorState extends State<CalendarSelector> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(widget.selected.year, widget.selected.month);
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  String _monthLabel(DateTime m) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${months[m.month - 1]} ${m.year}';
  }

  int _daysInMonth(DateTime m) {
    final last = DateTime(m.year, m.month + 1, 0);
    return last.day;
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final startWeekday = firstDay.weekday;
    final totalDays = _daysInMonth(_displayedMonth);

    final dayCells = <Widget>[];
    for (int i = 1; i < startWeekday; i++) {
      dayCells.add(const SizedBox.shrink());
    }
    for (int d = 1; d <= totalDays; d++) {
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, d);
      final isSelected = _isSameDate(date, widget.selected);
      dayCells.add(_buildDay(date, isSelected));
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.deepBlue.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: const Icon(Icons.chevron_left_rounded, color: AppColors.deepBlue),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _monthLabel(_displayedMonth),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepBlue,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right_rounded, color: AppColors.deepBlue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _WeekdayLabel('Mon'),
                _WeekdayLabel('Tue'),
                _WeekdayLabel('Wed'),
                _WeekdayLabel('Thu'),
                _WeekdayLabel('Fri'),
                _WeekdayLabel('Sat'),
                _WeekdayLabel('Sun'),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              physics: const NeverScrollableScrollPhysics(),
              children: dayCells,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDay(DateTime date, bool isSelected) {
    final isToday = _isSameDate(date, DateTime.now());
    final bg = isSelected ? AppColors.maroon : AppColors.white;
    final borderColor = isSelected
        ? AppColors.maroon
        : (isToday ? AppColors.deepBlue.withOpacity(0.25) : AppColors.deepBlue.withOpacity(0.08));
    final txt = isSelected ? AppColors.white : AppColors.deepBlue;

    return InkWell(
      onTap: () => widget.onSelect(date),
      customBorder: const CircleBorder(),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.maroon.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: txt,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _WeekdayLabel extends StatelessWidget {
  final String text;
  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.deepBlue.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}

