import 'package:flutter/material.dart';
import 'package:kavendar/src/custom/calendar.dart';
import 'package:kavendar/src/custom/damath.dart';
import 'package:kavendar/src/table/src/calendar_style.dart';

///
///
/// [CalendarCore]
///
///
class CalendarCore extends StatelessWidget {
  final DateTime? focusedDay;
  final DateTimeRange domain;
  final int weeksPerPage;
  final DayBuilder? dowBuilder;
  final DayBuilder? weekNumberBuilder;
  final FocusedDayBuilder dayBuilder;
  final bool dowVisible;
  final bool weekNumbersVisible;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;
  final EdgeInsets? tablePadding;
  final double? dowHeight;
  final double? rowHeight;
  final BoxConstraints constraints;
  final int? previousIndex;
  final int startingWeekday; // see DateTime.sunday, monday, ...
  final PageController? pageController;
  final ScrollPhysics? scrollPhysics;
  final void Function(int index, DateTime focusedDay) onPageChanged;

  const CalendarCore({
    super.key,
    this.dowBuilder,
    required this.dayBuilder,
    required this.onPageChanged,
    required this.domain,
    required this.constraints,
    this.dowHeight,
    this.rowHeight,
    this.startingWeekday = DateTime.sunday,
    this.weeksPerPage = 6,
    this.pageController,
    this.focusedDay,
    this.previousIndex,
    this.dowVisible = true,
    this.weekNumberBuilder,
    required this.weekNumbersVisible,
    this.dowDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.tablePadding,
    this.scrollPhysics,
  }) : assert(!dowVisible || (dowHeight != null && dowBuilder != null)),
       assert(!weekNumbersVisible || weekNumberBuilder != null);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      physics: scrollPhysics,
      itemCount: DateTimeRangeExtension.scopesOf(
        domain,
        startingWeekday,
        DateTime.daysPerWeek * weeksPerPage,
      ),
      itemBuilder: (context, index) {
        final visibleDays = DateTimeRangeExtension.daysIn(
          DateTimeRangeExtension.weeksFrom(_getBaseDay(index), weeksPerPage),
        );
        return Padding(
          padding: tablePadding ?? EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (weekNumbersVisible) _builderWeekNumbers(visibleDays),
              Expanded(
                child: Table(
                  border: tableBorder,
                  children: [
                    if (dowVisible) _builderWeekends(visibleDays),
                    ..._builderWeekdays(visibleDays),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      onPageChanged:
          (index) => onPageChanged(index, _getBaseOrFocusedDay(index)),
    );
  }

  DateTime _focusDay(DateTime prevFocusedDay, int i) => switch (weeksPerPage) {
    6 => DateTime.utc(prevFocusedDay.year, prevFocusedDay.month + i),
    2 => DateTime.utc(
      prevFocusedDay.year,
      prevFocusedDay.month,
      prevFocusedDay.day + i * 14,
    ),
    1 => DateTime.utc(
      prevFocusedDay.year,
      prevFocusedDay.month,
      prevFocusedDay.day + i * 7,
    ),
    _ => throw UnimplementedError('unimplement weeks: $weeksPerPage'),
  };

  DateTime _getFocusedDay(DateTime prevFocusedDay, int pageIndex) {
    if (pageIndex == previousIndex) return prevFocusedDay;
    return DateTimeExtension.clamp(
      _focusDay(prevFocusedDay, pageIndex - previousIndex!),
      domain.start,
      domain.end,
    );
  }

  DateTime _getBaseDay(int pageIndex) => DateTimeExtension.clamp(
    _focusDay(domain.start, pageIndex),
    domain.start,
    domain.end,
  );

  DateTime _getBaseOrFocusedDay(int index) {
    final previousFocusedDay = focusedDay;
    return (previousFocusedDay == null || previousIndex == null)
        ? _getBaseDay(index)
        : _getFocusedDay(previousFocusedDay, index);
  }

  ///
  ///
  ///
  double? get constrainedRowHeight =>
      constraints.hasBoundedHeight
          ? (constraints.maxHeight - (dowVisible ? dowHeight! : 0.0)) /
              weeksPerPage
          : rowHeight;

  Widget _builderWeekNumbers(List<DateTime> visibleDays) => Column(
    children: [
      if (dowVisible) SizedBox(height: dowHeight ?? 0),
      ...List.generate(
        visibleDays.length ~/ 7,
        (index) => Expanded(
          child: SizedBox(
            height: constrainedRowHeight,
            child: weekNumberBuilder?.call(visibleDays[index * 7]),
          ),
        ),
      ),
    ],
  );

  TableRow _builderWeekends(List<DateTime> visibleDays) => TableRow(
    decoration: dowDecoration,
    children: List.generate(
      7,
      (index) => SizedBox(
        height: dowHeight,
        child: dowBuilder?.call(visibleDays[index]),
      ),
    ),
  );

  List<TableRow> _builderWeekdays(List<DateTime> visibleDays) => List.generate(
    visibleDays.length ~/ DateTime.daysPerWeek,
    (index) => TableRow(
      decoration: rowDecoration,
      children: List.generate(
        DateTime.daysPerWeek,
        (id) => SizedBox(
          height: constrainedRowHeight,
          child: dayBuilder(
            visibleDays[index * 7 + id],
            _getBaseOrFocusedDay(index),
          ),
        ),
      ),
    ),
  );
}
