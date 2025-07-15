// ignore_for_file: constant_identifier_names
part of '../table_calendar.dart';

///
///
/// [TableCalendarHeader]
/// [TableCalendarCell]
///
///
class TableCalendarHeader extends StatelessWidget {
  final dynamic locale;
  final DateTime focusedDate;
  final int weeksPerPage;
  final HeaderStyle? headerStyle;
  final VoidCallback onLeftChevronTap;
  final VoidCallback onRightChevronTap;
  final List<int> availableWeeksPerPage;
  final DateBuilder? headerTitleBuilder;

  const TableCalendarHeader({
    super.key,
    this.locale,
    required this.focusedDate,
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
      margin: headerStyle.margin,
      padding: headerStyle.padding,
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
                headerTitleBuilder?.call(focusedDate) ??
                GestureDetector(
                  onTap: () => headerStyle.onTap?.call(focusedDate),
                  onLongPress: () => headerStyle.onLongPress?.call(focusedDate),
                  child: Text(
                    headerStyle.titleTextFormatter?.call(focusedDate, locale) ??
                        DateFormat.yMMMM(locale).format(focusedDate),
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

///
///
///
enum TableCalendarCellType {
  weekday,
  weekend,
  outside,
  today,
  holiday,
  disabled,
  highlighted,
  selected,
  rangeStart,
  rangeWithin,
  rangeEnd;

  bool? get rangeHighlightState => switch (this) {
    TableCalendarCellType.rangeStart => true,
    TableCalendarCellType.rangeEnd => false,
    TableCalendarCellType.rangeWithin => null,
    _ => throw StateError(message_noHighlight),
  };

  static const String message_noHighlight = 'cell type no range highlight';
}

typedef StyleLocaleWidgetBuilder<T> = Widget Function(T style, dynamic locale);

class TableCalendarCell extends StatelessWidget {
  final dynamic locale;
  final DateTime date;
  final DateTime focusedDate;
  final CalendarStyle style;
  final TableCalendarCellType cellType;

  const TableCalendarCell({
    super.key,
    this.locale,
    required this.date,
    required this.focusedDate,
    required this.style,
    required this.cellType,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${DateFormat.EEEE(locale).format(date)}, '
          '${DateFormat.yMMMMd(locale).format(date)}',
      excludeSemantics: true,
      child:
          style.builderPrioritized?.call(date, focusedDate, locale) ??
          switch (cellType) {
            TableCalendarCellType.weekday => style.builderWeekday,
            TableCalendarCellType.weekend => style.builderWeekend,
            TableCalendarCellType.outside => style.builderOutside,
            TableCalendarCellType.today => style.builderToday,
            TableCalendarCellType.holiday => style.builderHoliday,
            TableCalendarCellType.disabled => style.builderDisabled,
            TableCalendarCellType.highlighted => throw UnimplementedError(),
            TableCalendarCellType.selected => style.builderSelected,
            TableCalendarCellType.rangeStart => style.builderRangeStart,
            TableCalendarCellType.rangeWithin => style.builderRangeIn,
            TableCalendarCellType.rangeEnd => style.builderRangeEnd,
          }(date, focusedDate, locale),
    );
  }
}
