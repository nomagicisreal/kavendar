// ignore_for_file: constant_identifier_names
part of '../table_calendar.dart';

///
///
/// [CalendarStyle] layout depends on parent constrains, it's better not to specify height
///
/// [dateTextFormatter], ...
/// [weeksPerPage_1], ...
/// [_dateTextFormater], ...
/// [tableColumnWidth], ...
/// [_buildCell], ..., [_initCellPrioritization], ...
///
///
class CalendarStyle {
  final DateTimeFormatter dateTextFormatter;
  final int verticalFlex;
  final FlexFit verticalFlexFit;
  final ScrollPhysics? horizontalScroll;

  ///
  ///
  ///
  // final CalendarFormatPage format;
  final int formatStartingWeekday;
  final List<int> formatAvailables;
  final ValueChanged<int>? formatOnChanged;
  final Duration formatAnimationDuration;
  final Curve formatAnimationCurve;

  ///
  /// todo: move page related field into [CalendarPageState]
  ///
  final Duration pagingDuration;
  final Curve pagingCurve;
  final CalendarPageControllerInitializer pageControllerInitializer;
  final OnPageChanged? pageOnChanged;
  final CalendarPageNext? pageToWhere;

  ///
  ///
  ///
  final CalendarStyleHeader? styleHeader;
  final CalendarStyleDayOfWeek? styleDayOfWeek;
  final CalendarStyleWeekNumber? styleWeekNumber;
  final CalendarStyleCellStack? styleCellStack;

  ///
  ///
  ///
  final HitTestBehavior cellHitTestBehavior;
  final EdgeInsets cellMargin;
  final EdgeInsets cellPadding;
  final AlignmentGeometry cellAlignment;
  final Duration cellAnimationDuration;
  final Curve cellAnimationCurve;
  final Decoration tableRowDecoration;
  final TableBorder tableBorder;
  final EdgeInsets tablePadding;
  final Map<int, TableColumnWidth>? _tableColumnWidth;

  ///
  ///
  ///
  final CalendarFocusInitializer focusInitializer;
  final List<CalendarCellStyle> focusStyle;
  final CalendarCellStyle focusStyleDefault;

  const CalendarStyle({
    this.dateTextFormatter = _dateTextFormater,
    this.verticalFlex = 1, // 1 expand, 0 shrink
    this.verticalFlexFit = FlexFit.loose,
    this.horizontalScroll = const PageScrollPhysics(),

    //
    // this.format = CalendarFormatPage.month,
    this.formatAvailables = weeksPerPage_all,
    this.formatStartingWeekday = DateTime.sunday,
    this.formatOnChanged,
    this.formatAnimationDuration = DurationExtension.milli200,
    this.formatAnimationCurve = Curves.linear,

    //
    this.pagingDuration = DurationExtension.milli300,
    this.pagingCurve = Curves.easeOut,
    this.pageControllerInitializer = CalendarPageState.initializer,
    this.pageOnChanged,
    this.pageToWhere,

    //
    this.styleHeader = const CalendarStyleHeader(),
    this.styleDayOfWeek = const CalendarStyleDayOfWeek(),
    this.styleCellStack = const CalendarStyleCellStack(),
    this.styleWeekNumber,

    //
    this.tableRowDecoration = const BoxDecoration(),
    this.tableBorder = const TableBorder(),
    this.tablePadding = EdgeInsets.zero,
    Map<int, TableColumnWidth>? tableColumnWidth,

    //
    this.cellHitTestBehavior = HitTestBehavior.opaque,
    this.cellMargin = const EdgeInsets.all(6.0),
    this.cellPadding = EdgeInsets.zero,
    this.cellAlignment = Alignment.center,
    this.cellAnimationDuration = Durations.medium1,
    this.cellAnimationCurve = Curves.linear,

    //
    this.focusInitializer = CalendarFocus.focusAndSelection,
    this.focusStyle = CalendarFocus.pSelectionAndReady,
    this.focusStyleDefault = CalendarFocus.styleDefault,
  }) : _tableColumnWidth = tableColumnWidth;

  ///
  /// [weeksPerPage_1], [weeksPerPage_2], [weeksPerPage_6], [weeksPerPage_all]
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
  /// [_dateTextFormater]
  ///
  static String _dateTextFormater(DateTime date, dynamic locale) =>
      '${date.day}';

  ///
  /// [tableColumnWidth]
  /// [_heightBody]
  ///
  Map<int, TableColumnWidth>? get tableColumnWidth =>
      _tableColumnWidth ??
      (styleWeekNumber == null
          ? null
          : {0: FixedColumnWidth(styleWeekNumber!.flexOnRow)});

  double _heightBody(BoxConstraints constraints) =>
      constraints.maxHeight -
      tablePadding.vertical -
      (styleDayOfWeek?.height ?? 0) -
      (styleHeader?.height ?? 0);

  ///
  /// [_buildCell]
  /// [_buildTableWeekDates]
  /// [_buildTableRow], [_buildTable]
  /// [_buildBodyPage], [_buildBody]
  ///
  Widget _buildCell(
    BuildContext context,
    BoxConstraints constraints,
    dynamic locale,
    DateTime date,
    Decoration decoration,
    TextStyle textStyle,
  ) => Semantics(
    key: ValueKey('Cell-${date.year}-${date.month}-${date.day}'),
    label:
        '${DateFormat.EEEE(locale).format(date)}, '
        '${DateFormat.yMMMMd(locale).format(date)}',
    excludeSemantics: true,
    child: AnimatedContainer(
      duration: cellAnimationDuration,
      curve: cellAnimationCurve,
      margin: cellMargin,
      padding: cellPadding,
      decoration: decoration,
      alignment: cellAlignment,
      child: Text(dateTextFormatter(date, locale), style: textStyle),
    ),
  );

  static List<Widget> _buildTableWeekDates(
    List<DateTime> dates,
    int iRow,
    DateBuilder buildCell,
  ) => List.generate(
    DateTime.daysPerWeek,
    (iCol) => buildCell(dates[DateTime.daysPerWeek * iRow + iCol]),
  );

  TableRow _buildTableRow(List<Widget> children) =>
      TableRow(decoration: tableRowDecoration, children: children);

  Widget _buildTable(List<TableRow> rows) => Padding(
    padding: tablePadding,
    child: Table(
      border: tableBorder,
      columnWidths: tableColumnWidth,
      children: rows,
    ),
  );

  Widget _buildBodyPage(BuildContext context, double value, Widget? child) =>
      AnimatedSize(
        duration: formatAnimationDuration,
        curve: formatAnimationCurve,
        alignment: Alignment.topCenter,
        child: SizedBox(height: value, child: child),
      );

  Widget _buildBody(ConstraintsBuilder layout) => Flexible(
    flex: verticalFlex,
    fit: verticalFlexFit,
    child: LayoutBuilder(builder: layout),
  );

  ///
  /// [_initCellPrioritization]
  /// [_initTableRowsBuilder]
  /// [_initCalendarBuilder]
  ///
  List<CalendarCellPrioritization> _initCellPrioritization(
    Map<CalendarCellType, Predicator<DateTime>?> predicators,
  ) {
    final prioritization = [...focusStyle, focusStyleDefault];
    if (predicators.keys.isVariantTo(prioritization.map((s) => s.$1))) {
      throw ArgumentError(
        'predicators (${predicators.length}) '
        'not corresponding to '
        'prioritization (${focusStyle.length})',
      );
    }

    //
    final decorationDefault = focusStyleDefault.$2!;
    final dBoxShape = decorationDefault.$1!;
    final dBorderRadius = decorationDefault.$2;
    final dBoxShadow = decorationDefault.$3;
    final dGradient = decorationDefault.$4;
    final dBlendMode = decorationDefault.$5;
    final dColorEmphasis = decorationDefault.$6!;
    final dBackgroundColor = dColorEmphasis.$1!;
    final dBackgroundEmphasis = dColorEmphasis.$2!;
    final dBorder = decorationDefault.$7;
    final textStyleDefault = focusStyleDefault.$3!;
    final tTheme = textStyleDefault.$1!;
    final tStyleColor = textStyleDefault.$2!;
    final tStyleAlpha = textStyleDefault.$3!;

    CalendarCellPrioritization contexting(CalendarCellStyle p) {
      final type = p.$1;
      final decoration = p.$2;
      final textStyle = p.$3;
      final background = decoration?.$6;
      return (
        predicators[type],
        type != CalendarCellType.disabled,
        FContexting.decorationBox(
          shape: decoration?.$1 ?? dBoxShape,
          borderRadius: decoration?.$2 ?? dBorderRadius,
          boxShadow: decoration?.$3 ?? dBoxShadow,
          gradient: decoration?.$4 ?? dGradient,
          blendMode: decoration?.$5 ?? dBlendMode,
          background: background?.$1 ?? dBackgroundColor,
          backgroundEmphasis: background?.$2 ?? dBackgroundEmphasis,
          border: decoration?.$7 ?? dBorder,
        ),
        Contexting.textStyle(
          theme: textStyle?.$1 ?? tTheme,
          styleColor: textStyle?.$2 ?? tStyleColor,
          styleAlpha: textStyle?.$3 ?? tStyleAlpha,
        ),
      );
    }

    return [...focusStyle.mapToList(contexting), contexting(focusStyleDefault)];
  }

  TableRowsBuilder _initTableRowsBuilder(
    dynamic locale,
    double heightRow,
    Predicator<DateTime> predicateBlock,
  ) {
    final styleWeekNumber = this.styleWeekNumber;
    final firstColumn = styleWeekNumber?.builderFrom(predicateBlock, heightRow);
    final List<Widget> Function(List<DateTime>, int, DateBuilder) rowBody =
        firstColumn == null
            ? (dates, iRow, buildCell) =>
                _buildTableWeekDates(dates, iRow, buildCell)
            : (dates, iRow, buildCell) => [
              firstColumn(dates[DateTime.daysPerWeek * iRow]),
              ..._buildTableWeekDates(dates, iRow, buildCell),
            ];

    final styleDayOfWeek = this.styleDayOfWeek;
    final rowHead = styleDayOfWeek?.buildFrom(
      locale: locale,
      weekNumberTitle: styleWeekNumber?.buildTitle(styleDayOfWeek.height),
    );
    return rowHead == null
        ? (dates, buildCell) => _buildTable(
          List.generate(
            dates.length ~/ DateTime.daysPerWeek,
            (iRow) => _buildTableRow(rowBody(dates, iRow, buildCell)),
          ),
        )
        : (dates, buildCell) => _buildTable([
          rowHead(dates),
          ...List.generate(
            dates.length ~/ DateTime.daysPerWeek,
            (iRow) => _buildTableRow(rowBody(dates, iRow, buildCell)),
          ),
        ]);
  }

  DateBuilder _initCalendarBuilder({
    required ConstraintsBuilder bodyLayout,
    required PageController pageController,
    required dynamic locale,
    required ValueNotifier<int> pageWeeks,
    required ValueChanged<int> updateFormatIndex,
  }) {
    final styleHeader = this.styleHeader;
    if (styleHeader == null) return (_) => _buildBody(bodyLayout);
    final headerBuilder = styleHeader._initBuilder(
      pageController: pageController,
      style: this,
      locale: locale,
      pageWeeks: pageWeeks,
      updateFormatIndex: updateFormatIndex,
    );
    return (date) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [headerBuilder(date), _buildBody(bodyLayout)],
    );
  }
}
