// ignore_for_file: constant_identifier_names
part of '../table_calendar.dart';

///
///
/// [OnDateSelected], ...
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
typedef OnPageChanged = void Function(int index, DateTime focusedDate);

typedef OnDateSelected =
    void Function(DateTime selectedDate, DateTime focusedDate);

typedef OnRangeSelected =
    void Function(DateTime? start, DateTime? end, DateTime focusedDate);

///
///
///
typedef DateBuilder = Widget? Function(DateTime date);
typedef DateLocaleBuilder = Widget Function(DateTime date, dynamic locale);
typedef CellMetaBuilder =
    Widget? Function(
      DateTime date,
      DateTime focusedDate,
      CalendarCellType cellType,
      BoxConstraints constraints,
    );

typedef CellPlan =
    Widget Function(
      DateTime date,
      DateTime focusedDate,
      CalendarCellType cellType,
      BoxConstraints constraints,
      Widget child,
    );

typedef CalendarRowsGenerator =
    List<TableRow> Function(List<DateTime> dates, DateBuilder buildCell);

///
///
///
typedef ConstraintsRangeBuilder =
    Widget Function(RangeState3 state, BoxConstraints constraints);

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

///
///
///
typedef CalendarCellConfiguration = Map<CalendarCellType, Predicator<DateTime>>;

typedef MarkConfiguration<T> =
    Map<CalendarCellType, (EventsLayoutMark<T>?, EventElementMark<T>?)>;

///
///
/// [CalendarStyle] layout depends on parent constrains, it's better not to specify height
///
///
class CalendarStyle {
  final DateTimeFormatter dateTextFormatter;
  final DateTimeRange? _domain;
  final int startingWeekday;
  final bool verticalScrollAble;
  final int verticalFlex;
  final ScrollPhysics? horizontalScroll;

  ///
  ///
  ///
  // final CalendarFormatPage format;
  final List<int> formatAvailables;
  final ValueChanged<int>? formatOnChanged;
  final Duration formatAnimationDuration;
  final Curve formatAnimationCurve;
  final Duration pageStepDuration;
  final Curve pageStepCurve;
  final bool pageJumpingEnabled;
  final bool pageAnimationEnabled;

  ///
  ///
  ///
  final CalendarStyleHeader? styleHeader;
  final CalendarStyleDayOfWeek? styleDayOfWeek;
  final CalendarStyleWeekNumber? styleWeekNumber;
  final CalendarStyleCellMark? styleCellMark;
  final CalendarStyleCellRange? styleCellRangeHighlight;

  ///
  ///
  ///
  final List<MapEntry<CalendarCellType, DecorationTextStyle>> cellSetup;
  final HitTestBehavior cellHitTestBehavior;
  final EdgeInsets cellMargin;
  final EdgeInsets cellPadding;
  final AlignmentGeometry cellAlignment;
  final AlignmentGeometry cellStackAlignment;
  final Duration cellAnimationDuration;
  final Clip cellStackClip;
  final Decoration tableRowDecoration;
  final TableBorder tableBorder;
  final EdgeInsets tablePadding;
  final Map<int, TableColumnWidth>? _tableColumnWidth;

  ///
  ///
  ///
  final Predicator<DateTime> predicateDisable;
  final Predicator<DateTime> predicateHoliday;
  final Predicator<DateTime> predicateWeekend;
  final Predicator<DateTime> predicateWeekday;
  final OnRangeSelected? onRangeSelected;
  final OnDateSelected? onDaySelected;
  final OnDateSelected? onDateLongPressed;
  final OnPageChanged? onPageChanged;
  final void Function(PageController pageController)? onCalendarCreated;

  const CalendarStyle({
    this.dateTextFormatter = _dateTextFormater,
    DateTimeRange? domain,

    ///
    ///
    ///
    // this.format = CalendarFormatPage.month,
    this.formatAvailables = weeksPerPage_all,
    this.startingWeekday = DateTime.sunday,
    this.formatOnChanged,
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
    this.styleHeader = const CalendarStyleHeader(),
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
    this.tableRowDecoration = const BoxDecoration(),
    this.tableBorder = const TableBorder(),
    this.tablePadding = EdgeInsets.zero,
    Map<int, TableColumnWidth>? tableColumnWidth,

    ///
    /// TODO: enable range decoration, text style
    ///
    this.cellSetup = const [
      MapEntry(
        CalendarCellType.disabled,
        DecorationTextStyle(
          BoxDecoration(shape: BoxShape.circle),
          TextStyle(color: Color(0xFFDFDFDF)),
        ),
      ),
      MapEntry(
        CalendarCellType.focused,
        DecorationTextStyle(
          BoxDecoration(color: Color(0xFF5C6BC0), shape: BoxShape.circle),
          TextStyle(color: Color(0xFFFAFAFA), fontSize: 16.0),
        ),
      ),
      MapEntry(
        CalendarCellType.today,
        DecorationTextStyle(
          BoxDecoration(color: Color(0xFF9FA8DA), shape: BoxShape.circle),
          TextStyle(color: Color(0xFFFAFAFA), fontSize: 16.0),
        ),
      ),
      MapEntry(
        CalendarCellType.outside,
        DecorationTextStyle(
          BoxDecoration(shape: BoxShape.circle),
          TextStyle(color: Color(0xFFAEAEAE)),
        ),
      ),
      MapEntry(
        CalendarCellType.weekend,
        DecorationTextStyle(
          BoxDecoration(shape: BoxShape.circle),
          TextStyle(color: Color(0xFF5A5A5A)),
        ),
      ),
      MapEntry(
        CalendarCellType.holiday,
        DecorationTextStyle(
          BoxDecoration(
            border: Border.fromBorderSide(
              BorderSide(color: Color(0xFF9FA8DA), width: 1.4),
            ),
            shape: BoxShape.circle,
          ),
          TextStyle(color: Color(0xFF5C6BC0)),
        ),
      ),
      MapEntry(
        CalendarCellType.weekday,
        DecorationTextStyle(BoxDecoration(shape: BoxShape.circle), TextStyle()),
      ),
    ],

    ///
    ///
    ///
    this.predicateDisable = _datePredicateFalse,
    this.predicateHoliday = _datePredicateFalse,
    this.predicateWeekend = _datePredicateWeekend,
    this.predicateWeekday = _datePredicateWeekday,
    this.onRangeSelected,
    this.onDaySelected,
    this.onDateLongPressed,
    this.onPageChanged,
    this.onCalendarCreated,
  }) : _domain = domain,
       _tableColumnWidth = tableColumnWidth;

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
  static String _dateTextFormater(DateTime date, dynamic locale) =>
      '${date.day}';

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
  /// todo: instead of maybe unused function creating a property (with stack | without stack)
  ///
  Widget _cellStack(List<Widget> children) => Stack(
    alignment: cellStackAlignment,
    clipBehavior: cellStackClip,
    children: children,
  );

  CellPlan _cellPlanFrom<T>({
    required DateTime focusedDate,
    required dynamic locale,
    required EventLoader<T>? eventLoader,
    required EventsLayoutMark<T>? eventsLayoutMark,
    required EventElementMark<T>? eventLayoutSingleMark,
    required MarkConfiguration<T>? customMark,
  }) {
    final buildBackground = styleCellRangeHighlight?.builderFrom(
      style: this,
      isBackground: true,
    );
    final buildOverlay = styleCellMark?.builderFrom(
      eventLoader: eventLoader,
      eventsLayoutMark: eventsLayoutMark,
      eventLayoutSingleMark: eventLayoutSingleMark,
      customMark: customMark,
    );

    return buildBackground == null
        ? (buildOverlay == null
            ? (_, __, ___, ____, child) => child
            : (date, focusedDate, cellType, constraints, child) {
              final overlay = buildOverlay(
                date,
                focusedDate,
                cellType,
                constraints,
              );
              return _cellStack([child, if (overlay != null) overlay]);
            })
        : (buildOverlay == null
            ? (date, focusedDate, cellType, constraints, child) {
              final background = buildBackground(
                date,
                focusedDate,
                cellType,
                constraints,
              );
              return _cellStack([if (background != null) background, child]);
            }
            : (date, focusedDate, cellType, constraints, child) {
              final overlay = buildOverlay(
                date,
                focusedDate,
                cellType,
                constraints,
              );
              final background = buildBackground(
                date,
                focusedDate,
                cellType,
                constraints,
              );
              return _cellStack([
                if (background != null) background,
                child,
                if (overlay != null) overlay,
              ]);
            });
  }

  ///
  ///
  ///
  static List<Widget> _rowGenerateFrom(
    List<DateTime> dates,
    double? height,
    int iRow,
    DateBuilder buildCell,
  ) => List.generate(
    DateTime.daysPerWeek,
    (iCol) => SizedBox(
      height: height,
      child: buildCell(dates[DateTime.daysPerWeek * iRow + iCol]),
    ),
  );

  CalendarRowsGenerator _rowGeneratorFrom(
    dynamic locale,
    double heightRow,
    Predicator<DateTime> predicateBlock,
  ) {
    final styleWeekNumber = this.styleWeekNumber;
    final firstColumn = styleWeekNumber?.builderFrom(predicateBlock, heightRow);
    final rowBody =
        firstColumn == null
            ? (dates, iRow, buildCell) =>
                _rowGenerateFrom(dates, heightRow, iRow, buildCell)
            : (dates, iRow, buildCell) {
              final first = firstColumn(dates[DateTime.daysPerWeek * iRow]);
              return [
                if (first != null) first,
                ..._rowGenerateFrom(dates, heightRow, iRow, buildCell),
              ];
            };

    final styleDayOfWeek = this.styleDayOfWeek;
    final rowHead = styleDayOfWeek?.buildFrom(
      predicateWeekend: predicateWeekend,
      locale: locale,
      weekNumberTitle: styleWeekNumber?.buildTitle(styleDayOfWeek.height),
    );
    return rowHead == null
        ? (dates, buildCell) => List.generate(
          dates.length ~/ DateTime.daysPerWeek,
          (iRow) => _tableRow(rowBody(dates, iRow, buildCell)),
        )
        : (dates, buildCell) => [
          rowHead(dates),
          ...List.generate(
            dates.length ~/ DateTime.daysPerWeek,
            (iRow) => _tableRow(rowBody(dates, iRow, buildCell)),
          ),
        ];
  }

  ///
  ///
  ///
  DateBuilder _dateBuilderFrom({
    required CalendarCellConfiguration configuration,
    required ValueChanged<DateTime> onTap,
    required ValueChanged<DateTime> onLongPress,
    required Predicator<DateTime> predicateBlock,
    required DateTime focusedDate,
    required dynamic locale,
    required CellPlan plan,
  }) => (date) {
    if (predicateBlock(date)) return null;
    for (var current in cellSetup) {
      final cellType = current.key;
      final predicate = configuration[cellType]!;
      if (!predicate(date)) continue;
      return LayoutBuilder(
        builder: (context, constraints) {
          final child = plan(
            date,
            focusedDate,
            cellType,
            constraints,
            _tableRowCell(date, locale, current.value),
          );
          return cellType == CalendarCellType.disabled
              ? child
              : GestureDetector(
                behavior: cellHitTestBehavior,
                onTap: () => onTap(date),
                onLongPress: () => onLongPress(date),
                child: child,
              );
        },
      );
    }
    throw StateError('unknown builder for date($date)');
  };

  ///
  /// [_tableRowCell]
  /// [_tableRow]
  /// [_table]
  ///
  Widget _tableRowCell(
    DateTime date,
    dynamic locale,
    DecorationTextStyle style,
  ) => Semantics(
    key: ValueKey('Cell-${date.year}-${date.month}-${date.day}'),
    label:
        '${DateFormat.EEEE(locale).format(date)}, '
        '${DateFormat.yMMMMd(locale).format(date)}',
    excludeSemantics: true,
    child: AnimatedContainer(
      duration: cellAnimationDuration,
      margin: cellMargin,
      padding: cellPadding,
      decoration: style.decoration,
      alignment: cellAlignment,
      child: Text(dateTextFormatter(date, locale), style: style.textStyle),
    ),
  );

  TableRow _tableRow(List<Widget> children) =>
      TableRow(decoration: tableRowDecoration, children: children);

  Widget _table(List<TableRow> rows) {
    final styleWeekNumber = this.styleWeekNumber;
    return Padding(
      padding: tablePadding,
      child: Table(
        border: tableBorder,
        columnWidths:
            _tableColumnWidth ??
            (styleWeekNumber == null
                ? null
                : {0: FlexColumnWidth(styleWeekNumber.flexOnRow)}),
        children: rows,
      ),
    );
  }

  ///
  /// [_pageBuilder]
  /// [pageHeightWithoutBody]
  ///
  Widget _pageBuilder(BuildContext context, double value, Widget? child) =>
      AnimatedSize(
        duration: formatAnimationDuration,
        curve: formatAnimationCurve,
        alignment: Alignment.topCenter,
        child: SizedBox(height: value, child: child),
      );

  double get pageHeightWithoutBody =>
      tablePadding.vertical +
      (styleDayOfWeek?.height ?? 0) +
      (styleHeader?.height ?? 0);
}
