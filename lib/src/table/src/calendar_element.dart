import 'package:damath/damath.dart';
import 'package:datter/datter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kavendar/src/table/table_calendar.dart';

import 'calendar_style.dart';

///
///
/// [TableCalendarHeader]
/// [TableCalendarCell]
///
///
class TableCalendarHeader extends StatelessWidget {
  final dynamic locale;
  final DateTime focusedDay;
  final int weeksPerPage;
  final HeaderStyle? headerStyle;
  final VoidCallback onLeftChevronTap;
  final VoidCallback onRightChevronTap;
  final List<int> availableWeeksPerPage;
  final DayBuilder? headerTitleBuilder;

  const TableCalendarHeader({
    super.key,
    this.locale,
    required this.focusedDay,
    required this.weeksPerPage,
    required this.headerStyle,
    required this.onLeftChevronTap,
    required this.onRightChevronTap,
    required this.availableWeeksPerPage,
    this.headerTitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final headerStyle = this.headerStyle;
    if (headerStyle == null) return Container();
    final onFormatChange = headerStyle.onFormatChanged;
    return Container(
      decoration: headerStyle.decoration,
      margin: headerStyle.headerMargin,
      padding: headerStyle.headerPadding,
      child: Row(
        children: [
          if (headerStyle.leftChevronVisible)
            Padding(
              padding: headerStyle.leftChevronMargin,
              child: InkWell(
                onTap: onLeftChevronTap,
                borderRadius: BorderRadius.circular(100.0),
                child: Padding(
                  padding: headerStyle.leftChevronPadding,
                  child: headerStyle.leftChevronIcon,
                ),
              ),
            ),
          Expanded(
            child:
                headerTitleBuilder?.call(focusedDay) ??
                GestureDetector(
                  onTap: () => headerStyle.onTap?.call(focusedDay),
                  onLongPress: () => headerStyle.onLongPress?.call(focusedDay),
                  child: Text(
                    headerStyle.titleTextFormatter?.call(focusedDay, locale) ??
                        DateFormat.yMMMM(locale).format(focusedDay),
                    style: headerStyle.titleTextStyle,
                    textAlign:
                        headerStyle.titleCentered
                            ? TextAlign.center
                            : TextAlign.start,
                  ),
                ),
          ),
          if (onFormatChange != null && availableWeeksPerPage.length > 1)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: InkWell(
                borderRadius: headerStyle.formatButtonDecoration.borderRadius
                    ?.resolve(context.textDirection),
                onTap: () => onFormatChange(_nextFormat),
                child: Container(
                  decoration: headerStyle.formatButtonDecoration,
                  padding: headerStyle.formatButtonPadding,
                  child: Text(
                    "${headerStyle.formatButtonShowsNext ? _nextFormat : weeksPerPage} weeks",
                    style: headerStyle.formatButtonTextStyle,
                  ),
                ),
              ),
            ),
          if (headerStyle.rightChevronVisible)
            Padding(
              padding: headerStyle.rightChevronMargin,
              child: InkWell(
                onTap: onRightChevronTap,
                borderRadius: BorderRadius.circular(100.0),
                child: Padding(
                  padding: headerStyle.rightChevronPadding,
                  child: headerStyle.rightChevronIcon,
                ),
              ),
            ),
        ],
      ),
    );
  }

  int get _nextFormat {
    int id = availableWeeksPerPage.indexOf(weeksPerPage);
    id = (id + 1) % availableWeeksPerPage.length;
    return availableWeeksPerPage[id];
  }
}

class TableCalendarCell extends StatelessWidget {
  final dynamic locale;
  final DateTime day;
  final DateTime focusedDay;
  final bool isTodayHighlighted;
  final bool isToday;
  final bool isSelected;
  final bool isRangeStart;
  final bool isRangeEnd;
  final bool isWithinRange;
  final bool isOutside;
  final bool isDisabled;
  final bool isHoliday;
  final bool isWeekend;
  final CalendarStyle calendarStyle;
  final CalendarBuilders calendarBuilders;

  const TableCalendarCell({
    super.key,
    required this.day,
    required this.focusedDay,
    required this.calendarStyle,
    required this.calendarBuilders,
    required this.isTodayHighlighted,
    required this.isToday,
    required this.isSelected,
    required this.isRangeStart,
    required this.isRangeEnd,
    required this.isWithinRange,
    required this.isOutside,
    required this.isDisabled,
    required this.isHoliday,
    required this.isWeekend,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final dowLabel = DateFormat.EEEE(locale).format(day);
    final dayLabel = DateFormat.yMMMMd(locale).format(day);
    return Semantics(
      label: '$dowLabel, $dayLabel',
      excludeSemantics: true,
      child:
          calendarBuilders.prioritizedBuilder?.call(day, focusedDay) ??
          cellOf(context),
    );
  }

  Widget cellOf(BuildContext context) {
    if (isDisabled) {
      return calendarBuilders.disabledBuilder?.call(day, focusedDay) ??
          AnimatedContainer(
            duration: DurationExtension.milli100 * 2.5,
            margin: calendarStyle.cellMargin,
            padding: calendarStyle.cellPadding,
            decoration: calendarStyle.disabledDecoration,
            alignment: calendarStyle.cellAlignment,
            child: Text(
              calendarStyle.dayTextFormatter?.call(day, locale) ?? '${day.day}',
              style: calendarStyle.disabledTextStyle,
            ),
          );
    } else if (isSelected) {
      return calendarBuilders.selectedBuilder?.call(day, focusedDay) ??
          AnimatedContainer(
            duration: DurationExtension.milli100 * 2.5,
            margin: calendarStyle.cellMargin,
            padding: calendarStyle.cellPadding,
            decoration: calendarStyle.selectedDecoration,
            alignment: calendarStyle.cellAlignment,
            child: Text(
              calendarStyle.dayTextFormatter?.call(day, locale) ?? '${day.day}',
              style: calendarStyle.selectedTextStyle,
            ),
          );
    } else if (isRangeStart) {
      return calendarBuilders.rangeStartBuilder?.call(day, focusedDay) ??
          AnimatedContainer(
            duration: DurationExtension.milli100 * 2.5,
            margin: calendarStyle.cellMargin,
            padding: calendarStyle.cellPadding,
            decoration: calendarStyle.rangeStartDecoration,
            alignment: calendarStyle.cellAlignment,
            child: Text(
              calendarStyle.dayTextFormatter?.call(day, locale) ?? '${day.day}',
              style: calendarStyle.rangeStartTextStyle,
            ),
          );
    } else if (isRangeEnd) {
      return calendarBuilders.rangeEndBuilder?.call(day, focusedDay) ??
          AnimatedContainer(
            duration: DurationExtension.milli100 * 2.5,
            margin: calendarStyle.cellMargin,
            padding: calendarStyle.cellPadding,
            decoration: calendarStyle.rangeEndDecoration,
            alignment: calendarStyle.cellAlignment,
            child: Text(
              calendarStyle.dayTextFormatter?.call(day, locale) ?? '${day.day}',
              style: calendarStyle.rangeEndTextStyle,
            ),
          );
    } else if (isToday && isTodayHighlighted) {
      return calendarBuilders.todayBuilder?.call(day, focusedDay) ??
          AnimatedContainer(
            duration: DurationExtension.milli100 * 2.5,
            margin: calendarStyle.cellMargin,
            padding: calendarStyle.cellPadding,
            decoration: calendarStyle.todayDecoration,
            alignment: calendarStyle.cellAlignment,
            child: Text(
              calendarStyle.dayTextFormatter?.call(day, locale) ?? '${day.day}',
              style: calendarStyle.todayTextStyle,
            ),
          );
    } else if (isHoliday) {
      return calendarBuilders.holidayBuilder?.call(day, focusedDay) ??
          AnimatedContainer(
            duration: DurationExtension.milli100 * 2.5,
            margin: calendarStyle.cellMargin,
            padding: calendarStyle.cellPadding,
            decoration: calendarStyle.holidayDecoration,
            alignment: calendarStyle.cellAlignment,
            child: Text(
              calendarStyle.dayTextFormatter?.call(day, locale) ?? '${day.day}',
              style: calendarStyle.holidayTextStyle,
            ),
          );
    } else if (isWithinRange) {
      return calendarBuilders.withinRangeBuilder?.call(day, focusedDay) ??
          AnimatedContainer(
            duration: DurationExtension.milli100 * 2.5,
            margin: calendarStyle.cellMargin,
            padding: calendarStyle.cellPadding,
            decoration: calendarStyle.withinRangeDecoration,
            alignment: calendarStyle.cellAlignment,
            child: Text(
              calendarStyle.dayTextFormatter?.call(day, locale) ?? '${day.day}',
              style: calendarStyle.withinRangeTextStyle,
            ),
          );
    } else if (isOutside) {
      return calendarBuilders.outsideBuilder?.call(day, focusedDay) ??
          AnimatedContainer(
            duration: DurationExtension.milli100 * 2.5,
            margin: calendarStyle.cellMargin,
            padding: calendarStyle.cellPadding,
            decoration: calendarStyle.outsideDecoration,
            alignment: calendarStyle.cellAlignment,
            child: Text(
              calendarStyle.dayTextFormatter?.call(day, locale) ?? '${day.day}',
              style: calendarStyle.outsideTextStyle,
            ),
          );
    } else {
      return calendarBuilders.defaultBuilder?.call(day, focusedDay) ??
          AnimatedContainer(
            duration: DurationExtension.milli100 * 2.5,
            margin: calendarStyle.cellMargin,
            padding: calendarStyle.cellPadding,
            decoration:
                isWeekend
                    ? calendarStyle.weekendDecoration
                    : calendarStyle.defaultDecoration,
            alignment: calendarStyle.cellAlignment,
            child: Text(
              calendarStyle.dayTextFormatter?.call(day, locale) ?? '${day.day}',
              style:
                  isWeekend
                      ? calendarStyle.weekendTextStyle
                      : calendarStyle.defaultTextStyle,
            ),
          );
    }
  }
}
