import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/homework_model.dart';
import '../widgets/calendar_selector.dart';
import '../widgets/homework_item.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  late DateTime _selected;
  late final Map<DateTime, List<HomeworkModel>> _data;
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
    _data = _seedData();
  }

  Map<DateTime, List<HomeworkModel>> _seedData() {
    Map<DateTime, List<HomeworkModel>> map = {};
    // Sample for current date
    map[_key(_selected)] = const [
      HomeworkModel(
        subject: 'Math',
        description: 'Algebra Questions 1–20',
        icon: Icons.calculate_rounded,
      ),
      HomeworkModel(
        subject: 'English',
        description: 'Essay writing',
        icon: Icons.menu_book_rounded,
      ),
    ];
    // Sample for 12 March (as per example) of current year
    final now = DateTime.now();
    final demo = DateTime(now.year, 3, 12);
    map[_key(demo)] = const [
      HomeworkModel(
        subject: 'Math',
        description: 'Algebra Questions 1–20',
        icon: Icons.calculate_rounded,
      ),
      HomeworkModel(
        subject: 'English',
        description: 'Essay writing',
        icon: Icons.menu_book_rounded,
      ),
    ];
    return map;
  }

  DateTime _key(DateTime d) => DateTime(d.year, d.month, d.day);

  String _title(DateTime d) {
    final fullMonths = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${d.day} ${fullMonths[d.month - 1]} Homework';
    }

  @override
  Widget build(BuildContext context) {
    final items = _data[_key(_selected)] ?? const [];
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.deepBlue,
        elevation: 0,
        title: const Text(
          'Homework',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepBlue,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showCalendar = !_showCalendar;
                    });
                  },
                  icon: Icon(
                    _showCalendar ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppColors.maroon,
                    size: 18,
                  ),
                  label: Text(
                    _showCalendar ? 'Hide Calendar' : 'Show Calendar',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.maroon,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    foregroundColor: AppColors.maroon,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedCrossFade(
              crossFadeState:
                  _showCalendar ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
              firstChild: CalendarSelector(
                selected: _selected,
                onSelect: (d) {
                  setState(() {
                    _selected = d;
                    _showCalendar = false;
                  });
                },
              ),
              secondChild: const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            Text(
              _title(_selected),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.deepBlue,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No homework for this date',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.deepBlue.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HomeworkItem(item: items[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}