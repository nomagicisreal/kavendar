part of '../table_calendar.dart';

///
/// [CalendarStyleHeader]
/// [CalendarStyleWeekNumber]
/// [CalendarStyleDayOfWeek]
///
///

///
///
///
class CalendarStyleHeader {
  final void Function(DateTime focusedDay)? onTap;
  final void Function(DateTime focusedDay)? onLongPress;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BoxDecoration decoration;

  ///
  ///
  ///
  final bool titleCentered;
  final DateTimeFormatter? titleTextFormatter;
  final TextStyle titleTextStyle;
  final DateLocaleBuilder? _bTitle;

  ///
  ///
  ///
  final StyleTextButton? styleFormatButton;
  final StyleChevrons? styleChevrons;

  const CalendarStyleHeader({
    this.onTap,
    this.onLongPress,
    this.decoration = const BoxDecoration(),
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
    this.titleCentered = false,
    this.titleTextFormatter,
    this.titleTextStyle = const TextStyle(fontSize: 17.0),
    this.styleFormatButton,
    this.styleChevrons = const StyleChevrons(),

    DateLocaleBuilder? builderTitle,
    WidgetBuilder Function(
      CalendarStyle style,
      CalendarStyleHeader styleHeader,
    )?
    builderFormatButton,
  }) : _bTitle = builderTitle;

  static DateLocaleBuilder _builderTitle(CalendarStyleHeader style) =>
      (focusedDate, locale) => Expanded(
        child: GestureDetector(
          onTap: () => style.onTap?.call(focusedDate),
          onLongPress: () => style.onLongPress?.call(focusedDate),
          child: Text(
            style.titleTextFormatter?.call(focusedDate, locale) ??
                DateFormat.yMMMM(locale).format(focusedDate),
            style: style.titleTextStyle,
            textAlign: style.titleCentered ? TextAlign.center : TextAlign.start,
          ),
        ),
      );

  DateLocaleBuilder get buildTitle => _bTitle ?? _builderTitle(this);

  // todo: know the default fontSize if textStyle == null
  double get height =>
      margin.vertical + padding.vertical + titleTextStyle.fontSize!;

  ///
  /// todo: enable format button
  ///
  DateBuilder initBuilder({
    required PageController pageController,
    required CalendarStyle style,
    required dynamic locale,
    required ValueNotifier<int> pageWeeks,
    required ValueChanged<int> updateFormatIndex,
  }) {
    final buildFormatButton = styleFormatButton?.builderFrom(
      style.formatAvailables,
      updateFormatIndex,
    );
    final buildChevron = styleChevrons?.builder;
    return (focusedDate) => Container(
      decoration: decoration,
      margin: margin,
      padding: padding,
      child: Row(
        children: [
          if (buildChevron != null)
            buildChevron(
              DirectionIn4.left,
              iconOnTap: pageController.previousPage,
              duration: style.pagingDuration,
              curve: style.pagingCurve,
            ),
          buildTitle(focusedDate, locale),
          if (buildFormatButton != null) buildFormatButton(pageWeeks),
          if (buildChevron != null)
            buildChevron(
              DirectionIn4.right,
              iconOnTap: pageController.nextPage,
              duration: style.pagingDuration,
              curve: style.pagingCurve,
            ),
        ],
      ),
    );
  }
}

///
/// todo: has weekNumber -> vertical drag to switch page
///
class CalendarStyleWeekNumber {
  final String title;
  final double flexOnRow;
  final TextStyle? textStyle;

  const CalendarStyleWeekNumber({
    this.title = '',
    this.flexOnRow = 0.4,
    this.textStyle = const TextStyle(fontSize: 12, color: Color(0xFFBFBFBF)),
  });

  DateBuilder builderFrom(
    Predicator<DateTime> predicateBlock,
    double heightRow,
  ) =>
      (startingDate) =>
          !predicateBlock(startingDate) ||
                  !predicateBlock(
                    startingDate.add(
                      DurationExtension.day1 * (DateTime.daysPerWeek - 1),
                    ),
                  )
              ? SizedBox(
                height: heightRow,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    startingDate
                        .yearWeekNumber(startingDate.weekday)
                        .toString(),
                    style: textStyle,
                  ),
                ),
              )
              : Container();

  Widget buildTitle(double? heightDayOfWeek) => SizedBox(
    height: heightDayOfWeek,
    child: Align(
      alignment: Alignment.centerRight,
      child: Text(title, style: textStyle),
    ),
  );
}

///
///
///
class CalendarStyleDayOfWeek {
  final double? height;
  final DateTimeFormatter textFormatter;
  final Decoration decoration;
  final TextStyle weekdayStyle;
  final TextStyle weekendStyle;
  final DateLocaleBuilder? _b;

  const CalendarStyleDayOfWeek({
    this.height = 16.0,
    this.textFormatter = _formatter,
    this.decoration = const BoxDecoration(),
    this.weekdayStyle = const TextStyle(color: Color(0xFF4F4F4F)),
    this.weekendStyle = const TextStyle(color: Color(0xFF6A6A6A)),
    DateLocaleBuilder? builderDayOfWeek,
  }) : _b = builderDayOfWeek;

  // Defaults to simple `'E'` format (i.e. Mon, Tue, Wed, etc.).
  static String _formatter(DateTime date, dynamic locale) =>
      DateFormat.E(locale).format(date);

  static DateLocaleBuilder _builder(
    Predicator<DateTime> predicateWeekend,
    CalendarStyleDayOfWeek styleDayOfWeek,
  ) =>
      (date, locale) => Center(
        child: ExcludeSemantics(
          child: Text(
            styleDayOfWeek.textFormatter(date, locale),
            style:
                predicateWeekend(date)
                    ? styleDayOfWeek.weekendStyle
                    : styleDayOfWeek.weekdayStyle,
          ),
        ),
      );

  TableRow Function(List<DateTime> dates) buildFrom({
    required Predicator<DateTime> predicateWeekend,
    required dynamic locale,
    required Widget? weekNumberTitle,
  }) {
    final builder = _b ?? _builder(predicateWeekend, this);
    final height = this.height;

    List<Widget> children(List<DateTime> dates) => List.generate(
      DateTime.daysPerWeek,
      (index) => SizedBox(height: height, child: builder(dates[index], locale)),
    );
    final row =
        weekNumberTitle == null
            ? children
            : (dates) => [
              SizedBox(height: height, child: weekNumberTitle),
              ...children(dates),
            ];

    final decoration = this.decoration;
    return (dates) => TableRow(decoration: decoration, children: row(dates));
  }
}

