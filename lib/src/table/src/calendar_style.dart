// ignore_for_file: constant_identifier_names
part of '../table_calendar.dart';

///
///
/// [OnDaySelected], ...
/// [PredicateCell], ...
/// [EventBuilder], ...
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
typedef DateLocaleBuilder = Widget Function(DateTime date, dynamic locale);
typedef DateBuilder = Widget Function(DateTime date);
typedef DateRowCellBuilder = Widget Function(DateTime date, double? height);

typedef PageStepperBuilder = Widget Function(PageStepper stepper);

typedef ConstraintsRangeBuilder =
    Widget Function(RangeState3 state, BoxConstraints constraints);

//
typedef CellBuilder =
    Widget Function(
      DateTime date,
      DateTime focusedDate,
      dynamic locale,
      BoxConstraints constraints,
    );

typedef CalendarCellContainer =
    Map<CalendarCellType, (Predicator<DateTime>, CellBuilder)>;

typedef BoxConstraintsDouble = double Function(BoxConstraints constraints);

typedef HighlightWidthFrom<T> = BoxConstraintsDouble Function(T style);

//
typedef EventBuilder<T> = Widget? Function(DateTime dateTime, T event);

typedef EventsBuilder<T> =
    Widget? Function(DateTime dateTime, List<T> events, EventBuilder<T> mark);

typedef EventMark<T> =
    EventBuilder<T> Function(
      BoxConstraints constraints,
      CalendarStyleCellMark style,
    );
typedef EventsLayoutMark<T> =
    EventsBuilder<T> Function(
      BoxConstraints constraints,
      CalendarStyleCellMark style,
    );
typedef EventLoader<T> = List<T> Function(DateTime date);

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

  ///
  ///
  ///
  final CalendarStyleDayOfWeek? styleDayOfWeek;
  final CalendarStyleWeekNumber? styleWeekNumber;
  final CalendarStyleCellMark? styleCellMark;
  final CalendarStyleCellRange? styleCellRange;

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
  final CellBuilder? builderPrioritized;
  final CellBuilder? _bWeekday;
  final CellBuilder? _bWeekend;
  final CellBuilder? _bOutside;
  final CellBuilder? _bToday;
  final CellBuilder? _bHoliday;
  final CellBuilder? _bDisabled;
  final CellBuilder? _bSelected;

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
    DateTime Function(DateTime, int)? paging,
    this.pageStepDuration = DurationExtension.milli300,
    this.pageStepCurve = Curves.easeOut,
    this.horizontalScroll = const PageScrollPhysics(),
    this.verticalScrollAble = true,
    this.verticalFlex = 1, // 1 expand, 0 shrink
    ///
    ///
    ///
    this.styleDayOfWeek = const CalendarStyleDayOfWeek(),
    this.styleWeekNumber = const CalendarStyleWeekNumber(),
    this.styleCellMark = const CalendarStyleCellMark(),
    // this.styleCellRange = const CalendarStyleCellRange(),
    this.styleCellRange,

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
    CellBuilder? builderWeekday,
    CellBuilder? builderWeekend,
    CellBuilder? builderOutside,
    CellBuilder? builderToday,
    CellBuilder? builderHoliday,
    CellBuilder? builderDisabled,
    CellBuilder? builderSelected,
  }) : _domain = domain,
       _bWeekday = builderWeekday,
       _bWeekend = builderWeekend,
       _bOutside = builderOutside,
       _bToday = builderToday,
       _bHoliday = builderHoliday,
       _bDisabled = builderDisabled,
       _bSelected = builderSelected,
       _tableColumnWidth = tableColumnWidth;

  ///
  ///
  ///
  static const int weeksPerPage_6 = 6;
  static const int weeksPerPage_2 = 2;
  static const int weeksPerPage_1 = 1;
  static const List<int> weeksPerPage_all = [
    weeksPerPage_6,
    weeksPerPage_2,
    weeksPerPage_1,
  ];

  ///
  ///
  ///
  static String _dateTextFormater(DateTime date, dynamic locale) =>
      '${date.day}';

  DateTimeRange domain([DateTime? focusedDate]) {
    final domain = _domain;
    if (domain != null) return domain;
    return DTRExt.scopeMonthsFrom(
      focusedDate ?? DateTime.now(),
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

  static CellBuilder _builderWeekday(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.weekdayDecoration,
        textStyle: style.weekdayTextStyle,
      );

  static CellBuilder _builderWeekend(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.weekendDecoration,
        textStyle: style.weekendTextStyle,
      );

  static CellBuilder _builderOutside(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.outsideDecoration,
        textStyle: style.outsideTextStyle,
      );

  static CellBuilder _builderToday(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.todayDecoration,
        textStyle: style.todayTextStyle,
      );

  static CellBuilder _builderHoliday(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.holidayDecoration,
        textStyle: style.holidayTextStyle,
      );

  static CellBuilder _builderDisabled(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.disabledDecoration,
        textStyle: style.disabledTextStyle,
      );

  static CellBuilder _builderSelected(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.selectedDecoration,
        textStyle: style.selectedTextStyle,
      );

  CellBuilder get buildSelected => _bSelected ?? _builderSelected(this);

  CellBuilder get buildDisabled => _bDisabled ?? _builderDisabled(this);

  CellBuilder get buildHoliday => _bHoliday ?? _builderHoliday(this);

  CellBuilder get buildToday => _bToday ?? _builderToday(this);

  CellBuilder get buildOutside => _bOutside ?? _builderOutside(this);

  CellBuilder get buildWeekend => _bWeekend ?? _builderWeekend(this);

  CellBuilder get buildWeekday => _bWeekday ?? _builderWeekday(this);

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
  ConstraintsBuilder layoutCellStack(ConstraintsChildrenBuilder build) =>
      (context, constraints) => Stack(
        alignment: cellStackAlignment,
        clipBehavior: cellStackClip,
        children: build(context, constraints),
      );

  Widget buildCellLayout({
    required DateTime date,
    required DateTime focusedDate,
    required dynamic locale,
    required CellBuilder builder,
    required ConstraintsBuilder? buildHighlight,
    required ConstraintsBuilder? buildMarks,
  }) => LayoutBuilder(
    builder:
        buildHighlight == null
            ? (buildMarks == null
                ? (_, constraints) =>
                    builder(date, focusedDate, locale, constraints)
                : layoutCellStack(
                  (context, constraints) => [
                    builder(date, focusedDate, locale, constraints),
                    buildMarks(context, constraints),
                  ],
                ))
            : (buildMarks == null
                ? layoutCellStack(
                  (context, constraints) => [
                    buildHighlight(context, constraints),
                    builder(date, focusedDate, locale, constraints),
                  ],
                )
                : layoutCellStack(
                  (context, constraints) => [
                    buildHighlight(context, constraints),
                    builder(date, focusedDate, locale, constraints),
                    buildMarks(context, constraints),
                  ],
                )),
  );

  // TODO: enable range builder
  List<CalendarCellType> get cellBuilderOrder => [
    CalendarCellType.disabled,
    CalendarCellType.selected,
    CalendarCellType.today,
    CalendarCellType.outside,
    CalendarCellType.weekend,
    CalendarCellType.holiday,
    CalendarCellType.weekday,
  ];

  Widget conditionCell<T>({
    required CalendarCellContainer configuration,
    required DateTime date,
    required DateTime focusedDate,
    required dynamic locale,
    required GestureTapCallback onTap,
    required GestureLongPressCallback onLongPress,
    required EventsLayoutMark<T>? eventsLayoutMark,
    required EventMark<T>? eventMark,
    required EventLoader<T>? eventLoader,
  }) {
    for (var current in cellBuilderOrder) {
      final entry = configuration[current]!;
      if (!entry.$1(date)) continue;
      final styleMark = styleCellMark;
      final styleRange = styleCellRange;
      final builder = entry.$2;
      return switch (current) {
        CalendarCellType.disabled => buildCellLayout(
          date: date,
          focusedDate: focusedDate,
          locale: locale,
          builder: builder,
          buildMarks: styleMark?.builderFrom(
            date: date,
            eventLoader: eventLoader,
            eventsLayoutMark: eventsLayoutMark,
            eventMark: eventMark,
            disable: styleMark.disableDisabledCell,
          ),
          buildHighlight: styleRange?.builderFrom(
            style: this,
            date: date,
            isBackground: true,
            disable: styleRange.disableDisabledCell,
          ),
        ),
        _ => GestureDetector(
          behavior: cellHitTestBehavior,
          onTap: onTap,
          onLongPress: onLongPress,
          child: buildCellLayout(
            date: date,
            focusedDate: focusedDate,
            locale: locale,
            builder: builder,
            buildMarks: styleMark?.builderFrom(
              date: date,
              eventLoader: eventLoader,
              eventsLayoutMark: eventsLayoutMark,
              eventMark: eventMark,
              disable: false,
            ),
            buildHighlight: styleRange?.builderFrom(
              style: this,
              date: date,
              isBackground: true,
              disable: false,
            ),
          ),
        ),
      };
    }
    throw StateError('unknown builder for date($date)');
  }

  TableRow tableRow(List<Widget> children) =>
      TableRow(decoration: rowDecoration, children: children);

  Widget Function(List<DateTime> dates) table(
    DateBuilder buildCell, {
    required Predicator<DateTime> predicateBlock,
    required double? heightRow,
    required TableRow Function(List<DateTime> dates)? daysOfWeek,
    required DateRowCellBuilder? builderWeekNumber,
  }) {
    const daysPerWeek = DateTime.daysPerWeek;
    List<Widget> row(List<DateTime> dates, int iRow) =>
        List.generate(daysPerWeek, (iCol) {
          final date = dates[iRow * daysPerWeek + iCol];
          return SizedBox(
            height: heightRow,
            child: predicateBlock(date) ? Container() : buildCell(date),
          );
        });

    final rowWeekNumber =
        builderWeekNumber == null
            ? (List<DateTime> dates, int iRow) => row(dates, iRow)
            : (List<DateTime> dates, int iRow) => [
              builderWeekNumber(dates[daysPerWeek * iRow], heightRow),
              ...row(dates, iRow),
            ];

    final rows =
        daysOfWeek == null
            ? (List<DateTime> dates) => List.generate(
              dates.length ~/ daysPerWeek,
              (iRow) => tableRow(rowWeekNumber(dates, iRow)),
            )
            : (List<DateTime> dates) => [
              daysOfWeek(dates),
              ...List.generate(
                dates.length ~/ daysPerWeek,
                (iRow) => tableRow(rowWeekNumber(dates, iRow)),
              ),
            ];

    return (dates) => Padding(
      padding: tablePadding,
      child: Table(
        border: tableBorder,
        columnWidths: tableColumnWidth,
        children: rows(dates),
      ),
    );
  }
}
