// ignore_for_file: constant_identifier_names
part of '../table_calendar.dart';

///
///
/// [OnDaySelected], ...
/// [PredicateCell], ...
/// [EventSingleBuilder], ...
/// [RangeSelectionMode], ...
///
/// [CalendarStyle]
///
///

///
///
///
typedef OnPageChanged = void Function(int index, DateTime focusedDay);

typedef OnDaySelected =
    void Function(DateTime selectedDay, DateTime focusedDay);

typedef OnRangeSelected =
    void Function(DateTime? start, DateTime? end, DateTime focusedDay);

//
typedef PredicateCalendarCell =
    bool Function(DateTime date, DateTime dateFocused);

//
typedef PageStepper =
    Future<void> Function({required Duration duration, required Curve curve});

//
typedef DateBuilder = Widget Function(DateTime date);
typedef DateLocaleBuilder = Widget Function(DateTime date, dynamic locale);
typedef DateHeightBuilder = Widget Function(DateTime date, double? height);

typedef PageStepperBuilder = Widget Function(PageStepper stepper);

typedef ConstraintsRangeBuilder =
    Widget Function(RangeState3 state, BoxConstraints constraints);

//
typedef CellConstraintsBuilder =
    Widget Function(
      DateTime date,
      DateTime focusedDate,
      dynamic locale,
      BoxConstraints constraints,
    );

typedef CellBuilder =
    Widget Function(DateTime date, DateTime focusedDate, dynamic locale);

typedef CalendarCellContainer =
    Map<CalendarCellType, (Predicator<DateTime>, CellConstraintsBuilder)>;

typedef BoxConstraintsDouble = double Function(BoxConstraints constraints);

typedef HighlightWidthFrom<T> = BoxConstraintsDouble Function(T style);

//
typedef EventSingleBuilder<T> = Widget? Function(DateTime dateTime, T event);

typedef EventsBuilder<T> =
    Widget? Function(
      BoxConstraints constraints,
      DateTime dateTime,
      List<T> events,
      EventSingleBuilder<T> mark,
    );

typedef EventLoader<T> = List<T> Function(DateTime date);
typedef EventElementMark<T> =
    EventSingleBuilder<T> Function(
      BoxConstraints constraints,
      CalendarStyleCellMark style,
    );
typedef EventsLayoutMark<T> =
    EventsBuilder<T> Function(
      BoxConstraints constraints,
      CalendarStyleCellMark style,
    );

typedef MarkConfiguration<T> =
    Map<CalendarCellType, (EventsLayoutMark<T>?, EventElementMark<T>?)>;

///
///
///

///
/// [CalendarStyle] layout depends on parent constrains, don't specify height
///
/// [dateTextFormatter], ...
/// [_buildContainer], ...
/// [_pagingFrom], ...
///
class CalendarStyle {
  ///
  ///
  ///
  final DateTimeFormatter dateTextFormatter;

  // final CalendarFormatPage format;
  final DateTimeRange? _domain;
  final int startingWeekday;
  final List<int> availableWeeksPerPage;
  final ValueChanged<int>? onFormatChanged;
  final Duration pageStepDuration;
  final Curve pageStepCurve;
  final bool verticalScrollAble;
  final ScrollPhysics? horizontalScroll;
  final int verticalFlex;
  final bool pageJumpingEnabled;
  final bool pageAnimationEnabled;
  final Duration formatAnimationDuration;
  final Curve formatAnimationCurve;

  ///
  ///
  ///
  final CalendarStyleDayOfWeek? styleDayOfWeek;
  final CalendarStyleWeekNumber? styleWeekNumber;
  final CalendarStyleCellMark? styleCellMark;
  final CalendarStyleCellRange? styleCellRangeHighlight;

  ///
  ///
  ///
  final HitTestBehavior cellHitTestBehavior;
  final EdgeInsets cellMargin;
  final EdgeInsets cellPadding;
  final AlignmentGeometry cellAlignment;
  final AlignmentGeometry cellStackAlignment;
  final Duration cellAnimationDuration;
  final Clip cellStackClip;
  final Decoration rowDecoration;
  final TableBorder tableBorder;
  final EdgeInsets tablePadding;
  final Map<int, TableColumnWidth>? _tableColumnWidth;

  ///
  ///
  ///
  final List<CalendarCellType> cellBuilderOrder;
  final TextStyle? todayTextStyle;
  final Decoration? todayDecoration;
  final TextStyle? weekdayTextStyle;
  final Decoration? weekdayDecoration;
  final TextStyle? holidayTextStyle;
  final Decoration? holidayDecoration;
  final TextStyle? weekendTextStyle;
  final Decoration? weekendDecoration;
  final TextStyle? outsideTextStyle;
  final Decoration? outsideDecoration;
  final TextStyle? disabledTextStyle;
  final Decoration? disabledDecoration;
  final TextStyle? selectedTextStyle;
  final Decoration? selectedDecoration;

  ///
  ///
  ///
  final CellConstraintsBuilder? builderPrioritized;
  final CellConstraintsBuilder? _bWeekday;
  final CellConstraintsBuilder? _bWeekend;
  final CellConstraintsBuilder? _bOutside;
  final CellConstraintsBuilder? _bToday;
  final CellConstraintsBuilder? _bHoliday;
  final CellConstraintsBuilder? _bDisabled;
  final CellConstraintsBuilder? _bSelected;

  final Predicator<DateTime> predicateDisable;
  final Predicator<DateTime> predicateHoliday;
  final Predicator<DateTime> predicateWeekend;
  final Predicator<DateTime> predicateWeekday;
  final OnRangeSelected? onRangeSelected;
  final OnDaySelected? onDaySelected;
  final OnDaySelected? onDateLongPressed;
  final OnPageChanged? onPageChanged;
  final void Function(DateTime date)? onDisabledDayTapped;
  final void Function(DateTime date)? onDisabledDayLongPressed;
  final void Function(PageController pageController)? onCalendarCreated;

  const CalendarStyle({
    this.dateTextFormatter = _dateTextFormater,
    DateTimeRange? domain,

    ///
    ///
    ///
    // this.format = CalendarFormatPage.month,
    this.availableWeeksPerPage = weeksPerPage_all,
    this.startingWeekday = DateTime.sunday,
    this.onFormatChanged,
    this.pageStepDuration = DurationExtension.milli300,
    this.pageStepCurve = Curves.easeOut,
    this.horizontalScroll = const PageScrollPhysics(),
    this.verticalScrollAble = true,
    this.verticalFlex = 1, // 1 expand, 0 shrink
    ///
    ///
    ///
    this.pageJumpingEnabled = true,
    this.pageAnimationEnabled = true,
    this.formatAnimationDuration = DurationExtension.milli200,
    this.formatAnimationCurve = Curves.linear,

    ///
    ///
    ///
    this.styleDayOfWeek = const CalendarStyleDayOfWeek(),
    this.styleWeekNumber,
    this.styleCellMark = const CalendarStyleCellMark(),
    this.styleCellRangeHighlight,

    ///
    ///
    ///
    this.cellHitTestBehavior = HitTestBehavior.opaque,
    this.cellMargin = const EdgeInsets.all(6.0),
    this.cellPadding = EdgeInsets.zero,
    this.cellAlignment = Alignment.center,
    this.cellStackAlignment = Alignment.bottomCenter,
    this.cellStackClip = Clip.none,
    this.cellAnimationDuration = Durations.medium1,
    this.rowDecoration = const BoxDecoration(),
    this.tableBorder = const TableBorder(),
    this.tablePadding = EdgeInsets.zero,
    Map<int, TableColumnWidth>? tableColumnWidth,

    ///
    ///
    ///
    this.cellBuilderOrder = const [
      CalendarCellType.disabled,
      CalendarCellType.selected,
      CalendarCellType.today,
      CalendarCellType.outside,
      CalendarCellType.weekend,
      CalendarCellType.holiday,
      CalendarCellType.weekday,
    ],
    this.todayTextStyle = const TextStyle(
      color: Color(0xFFFAFAFA),
      fontSize: 16.0,
    ), //
    this.todayDecoration = const BoxDecoration(
      color: Color(0xFF9FA8DA),
      shape: BoxShape.circle,
    ),
    this.selectedTextStyle = const TextStyle(
      color: Color(0xFFFAFAFA),
      fontSize: 16.0,
    ),
    this.selectedDecoration = const BoxDecoration(
      color: Color(0xFF5C6BC0),
      shape: BoxShape.circle,
    ),
    this.outsideTextStyle = const TextStyle(color: Color(0xFFAEAEAE)),
    this.outsideDecoration = const BoxDecoration(shape: BoxShape.circle),
    this.disabledTextStyle = const TextStyle(color: Color(0xFFDFDFDF)),
    this.disabledDecoration = const BoxDecoration(shape: BoxShape.circle),
    this.holidayTextStyle = const TextStyle(color: Color(0xFF5C6BC0)),
    this.holidayDecoration = const BoxDecoration(
      border: Border.fromBorderSide(
        BorderSide(color: Color(0xFF9FA8DA), width: 1.4),
      ),
      shape: BoxShape.circle,
    ),
    this.weekendTextStyle = const TextStyle(color: Color(0xFF5A5A5A)),
    this.weekendDecoration = const BoxDecoration(shape: BoxShape.circle),
    this.weekdayTextStyle = const TextStyle(),
    this.weekdayDecoration = const BoxDecoration(shape: BoxShape.circle),

    ///
    ///
    ///
    this.builderPrioritized,
    CellConstraintsBuilder? builderWeekday,
    CellConstraintsBuilder? builderWeekend,
    CellConstraintsBuilder? builderOutside,
    CellConstraintsBuilder? builderToday,
    CellConstraintsBuilder? builderHoliday,
    CellConstraintsBuilder? builderDisabled,
    CellConstraintsBuilder? builderSelected,

    this.predicateDisable = _datePredicateFalse,
    this.predicateHoliday = _datePredicateFalse,
    this.predicateWeekend = _datePredicateWeekend,
    this.predicateWeekday = _datePredicateWeekday,
    this.onRangeSelected,
    this.onDaySelected,
    this.onDateLongPressed,
    this.onDisabledDayTapped,
    this.onDisabledDayLongPressed,
    this.onPageChanged,
    this.onCalendarCreated,
  }) : _domain = domain,
       _tableColumnWidth = tableColumnWidth,
       _bWeekday = builderWeekday,
       _bWeekend = builderWeekend,
       _bOutside = builderOutside,
       _bToday = builderToday,
       _bHoliday = builderHoliday,
       _bDisabled = builderDisabled,
       _bSelected = builderSelected;

  ///
  ///
  ///
  static const int weeksPerPage_6 = 6;
  static const int weeksPerPage_2 = 2;
  static const int weeksPerPage_1 = 1;
  static const List<int> weeksPerPage_all = [
    weeksPerPage_1,
    weeksPerPage_2,
    weeksPerPage_6,
  ];

  ///
  ///
  ///
  static bool _datePredicateFalse(DateTime date) => false;

  static bool _datePredicateWeekend(DateTime date) {
    final day = date.weekday;
    return day == DateTime.sunday || day == DateTime.saturday;
  }

  static bool _datePredicateWeekday(DateTime date) {
    final day = date.weekday;
    return day == DateTime.monday ||
        day == DateTime.tuesday ||
        day == DateTime.wednesday ||
        day == DateTime.thursday ||
        day == DateTime.friday;
  }

  ///
  ///
  ///
  static String _dateTextFormater(DateTime date, dynamic locale) =>
      '${date.day}';

  DateTimeRange domain([DateTime? focusedDate]) {
    final domain = _domain;
    if (domain != null) return domain;
    return DTRExt.scopeMonthsFrom(
      (focusedDate ?? DateTime.now()).dateOnly,
      before: 3,
      after: 3,
    );
  }

  ///
  ///
  ///
  static Widget _buildContainer({
    required DateTime date,
    required CalendarStyle style,
    required dynamic locale,
    required Decoration? decoration,
    required TextStyle? textStyle,
  }) => Semantics(
    key: ValueKey('Cell-${date.year}-${date.month}-${date.day}'),
    label:
        '${DateFormat.EEEE(locale).format(date)}, '
        '${DateFormat.yMMMMd(locale).format(date)}',
    excludeSemantics: true,
    child: AnimatedContainer(
      duration: style.cellAnimationDuration,
      margin: style.cellMargin,
      padding: style.cellPadding,
      decoration: decoration,
      alignment: style.cellAlignment,
      child: Text(style.dateTextFormatter(date, locale), style: textStyle),
    ),
  );

  static CellConstraintsBuilder _builderWeekday(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.weekdayDecoration,
        textStyle: style.weekdayTextStyle,
      );

  static CellConstraintsBuilder _builderWeekend(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.weekendDecoration,
        textStyle: style.weekendTextStyle,
      );

  static CellConstraintsBuilder _builderOutside(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.outsideDecoration,
        textStyle: style.outsideTextStyle,
      );

  static CellConstraintsBuilder _builderToday(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.todayDecoration,
        textStyle: style.todayTextStyle,
      );

  static CellConstraintsBuilder _builderHoliday(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.holidayDecoration,
        textStyle: style.holidayTextStyle,
      );

  static CellConstraintsBuilder _builderDisabled(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.disabledDecoration,
        textStyle: style.disabledTextStyle,
      );

  static CellConstraintsBuilder _builderSelected(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.selectedDecoration,
        textStyle: style.selectedTextStyle,
      );

  CellConstraintsBuilder get buildSelected =>
      _bSelected ?? _builderSelected(this);

  CellConstraintsBuilder get buildDisabled =>
      _bDisabled ?? _builderDisabled(this);

  CellConstraintsBuilder get buildHoliday => _bHoliday ?? _builderHoliday(this);

  CellConstraintsBuilder get buildToday => _bToday ?? _builderToday(this);

  CellConstraintsBuilder get buildOutside => _bOutside ?? _builderOutside(this);

  CellConstraintsBuilder get buildWeekend => _bWeekend ?? _builderWeekend(this);

  CellConstraintsBuilder get buildWeekday => _bWeekday ?? _builderWeekday(this);

  Map<int, TableColumnWidth>? get tableColumnWidth {
    final width = _tableColumnWidth;
    if (width != null) return width;
    final styleWeekNumber = this.styleWeekNumber;
    return styleWeekNumber == null
        ? null
        : {0: FlexColumnWidth(styleWeekNumber.flexOnRow)};
  }

  //
  // (Decoration?, TextStyle?) get builderSelected => (selectedDecoration, selectedTextStyle);
  //
  // (Decoration?, TextStyle?) get builderDisabled => (disabledDecoration, disabledTextStyle);
  //
  // (Decoration?, TextStyle?) get builderHoliday => (holidayDecoration, holidayTextStyle);
  //
  // (Decoration?, TextStyle?) get builderToday => (todayDecoration, todayTextStyle);
  //
  // (Decoration?, TextStyle?) get builderOutside => (outsideDecoration, outsideTextStyle);
  //
  // (Decoration?, TextStyle?) get builderWeekend => (weekendDecoration, weekdayTextStyle);
  //
  // (Decoration?, TextStyle?) get builderWeekday => (weekdayDecoration, weekdayTextStyle);

  ///
  ///
  ///
  Widget _buildPage(BuildContext context, double value, Widget? child) =>
      AnimatedSize(
        duration: formatAnimationDuration,
        curve: formatAnimationCurve,
        alignment: Alignment.topCenter,
        child: SizedBox(height: value, child: child),
      );

  Widget _cellStack(List<Widget> children) => Stack(
    alignment: cellStackAlignment,
    clipBehavior: cellStackClip,
    children: children,
  );

  // TODO: enable range builder
  // TODO: preload cells builders
  CellBuilder _cellFrom<T>({
    required CalendarCellContainer configuration,
    required ValueChanged<DateTime> onTap,
    required ValueChanged<DateTime> onLongPress,
    required ConstraintsDateCellTypeBuilder? buildMarks,
    required ConstraintsDateBuilder? buildRangeHighlight,
  }) {
    CellConstraintsBuilder builderOf(
      CalendarCellType cellType,
      CellConstraintsBuilder builder,
    ) =>
        buildRangeHighlight == null
            ? (buildMarks == null
                ? (date, focusedDate, locale, constraints) =>
                    builder(date, focusedDate, locale, constraints)
                : (date, focusedDate, locale, constraints) {
                  final mark = buildMarks(constraints, date, cellType);
                  return _cellStack([
                    builder(date, focusedDate, locale, constraints),
                    if (mark != null) mark,
                  ]);
                })
            : (buildMarks == null
                ? (date, focusedDate, locale, constraints) => _cellStack([
                  buildRangeHighlight(constraints, date),
                  builder(date, focusedDate, locale, constraints),
                ])
                : (date, focusedDate, locale, constraints) {
                  final mark = buildMarks(constraints, date, cellType);
                  return _cellStack([
                    buildRangeHighlight(constraints, date),
                    builder(date, focusedDate, locale, constraints),
                    if (mark != null) mark,
                  ]);
                });

    return (date, focusedDate, locale) {
      for (var current in cellBuilderOrder) {
        final entry = configuration[current]!;
        if (!entry.$1(date)) continue;
        final builder = builderOf(current, entry.$2);
        return LayoutBuilder(
          builder:
              (context, constraints) =>
                  current == CalendarCellType.disabled
                      ? builder(date, focusedDate, locale, constraints)
                      : GestureDetector(
                        behavior: cellHitTestBehavior,
                        onTap: () => onTap(date),
                        onLongPress: () => onLongPress(date),
                        child: builder(date, focusedDate, locale, constraints),
                      ),
        );
      }
      throw StateError('unknown builder for date($date)');
    };
  }

  Widget Function(List<DateTime> dates) _tableFrom(
    CellBuilder buildCell, {
    required Predicator<DateTime> predicateBlock,
    required double? heightRow,
    required DateTime focusedDate,
    required dynamic locale,
    required BoxConstraints constraints,
  }) {
    const daysPerWeek = DateTime.daysPerWeek;
    List<Widget> week(List<DateTime> dates, int iRow) =>
        List.generate(daysPerWeek, (iCol) {
          final date = dates[daysPerWeek * iRow + iCol];
          return SizedBox(
            height: heightRow,
            child:
                predicateBlock(date)
                    ? Container()
                    : buildCell(date, focusedDate, locale),
          );
        });

    ///
    ///
    ///
    final styleWeekNumber = this.styleWeekNumber;
    final firstColumn = styleWeekNumber?.builderFrom(predicateBlock);
    final weekIng =
        firstColumn == null
            ? (List<DateTime> dates, int iRow) => week(dates, iRow)
            : (List<DateTime> dates, int iRow) => [
              firstColumn(dates[daysPerWeek * iRow], heightRow),
              ...week(dates, iRow),
            ];

    ///
    ///
    ///
    final styleDayOfWeek = this.styleDayOfWeek;
    final firstRow = styleDayOfWeek?.buildFrom(
      predicateWeekend: predicateWeekend,
      focusedDate: focusedDate,
      locale: locale,
      constraints: constraints,
      weekNumberTitle: styleWeekNumber?.buildTitle(styleDayOfWeek.height),
    );
    final body =
        firstRow == null
            ? (List<DateTime> dates) => List.generate(
              dates.length ~/ daysPerWeek,
              (iRow) => _tableRow(weekIng(dates, iRow)),
            )
            : (List<DateTime> dates) => [
              firstRow(dates),
              ...List.generate(
                dates.length ~/ daysPerWeek,
                (iRow) => _tableRow(weekIng(dates, iRow)),
              ),
            ];

    return (dates) => _table(body(dates));
  }

  TableRow _tableRow(List<Widget> children) =>
      TableRow(decoration: rowDecoration, children: children);

  Widget _table(List<TableRow> rows) => Padding(
    padding: tablePadding,
    child: Table(
      border: tableBorder,
      columnWidths: tableColumnWidth,
      children: rows,
    ),
  );
}
