import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:untitled7/Color%20Compound%20class.dart';

Future<DateTime?> showCalendarSheet(
    BuildContext context, {
      required DateTime initialDate,
    }) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _CalendarSheet(initialDate: initialDate),
  );
}
class _CalendarSheet extends StatefulWidget {
  final DateTime initialDate;
  const _CalendarSheet({required this.initialDate});
  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}
class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate;
    _focusedDay  = widget.initialDate;
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: Material(
        color: Colors.black,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //── Header Row ──────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _arrowBtn(Icons.chevron_left, () {
                      setState(() => _focusedDay =
                          DateTime(_focusedDay.year, _focusedDay.month - 1, 1));
                    }),
                    Column(
                      children: [
                        Text(DateFormat.MMMM().format(_focusedDay),
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(_focusedDay.year.toString(),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[400])),
                      ],
                    ),
                    _arrowBtn(Icons.chevron_right, () {
                      setState(() => _focusedDay =
                          DateTime(_focusedDay.year, _focusedDay.month + 1, 1));
                    }),
                  ],
                ),
                const SizedBox(height: 12),
                TableCalendar(
                  firstDay: DateTime.utc(2020),
                  lastDay : DateTime.utc(2035),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                  headerVisible: false,
                  calendarFormat: CalendarFormat.month,
                  availableGestures: AvailableGestures.horizontalSwipe,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    defaultTextStyle:
                    const TextStyle(color: Colors.white70, fontSize: 15),
                    weekendTextStyle:
                    const TextStyle(color: Colors.white70, fontSize: 15),
                    todayDecoration: BoxDecoration(
                      border: Border.all(color: Appcolors.theme),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Appcolors.theme,
                      shape: BoxShape.circle,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.grey),
                    weekendStyle: TextStyle(color: Colors.grey),
                  ),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay  = focused;
                    });
                  },
                ),

                const SizedBox(height: 20),
                //── Bottom Action Bar ───────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CLOSE",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDay = DateTime.now();
                          _focusedDay  = DateTime.now();
                        });
                      },
                      child: const Text("TODAY",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(28),
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[850],
      ),
      child: Icon(icon, color: Appcolors.theme),
    ),
  );

  @override
  void dispose() {
    // return selected date to caller
    Navigator.pop(context, _selectedDay);
    super.dispose();
  }
}
