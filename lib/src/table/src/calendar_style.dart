// ignore_for_file: constant_identifier_names
part of '../table_calendar.dart';

///
///
/// [CalendarStyle] layout depends on parent constrains, it's better not to specify height
///
/// [domain], ...
/// [_heightBody], ...
/// [_buildCell], ...
/// [_initCellStackBuilder], ...
///
///
class CalendarStyle {
  final DateTimeFormatter dateTextFormatter;
  final CalendarFocusInitializer focusInitializer;
  final int verticalFlex;
  final FlexFit verticalFlexFit;
  final ScrollPhysics? horizontalScroll;

  ///
  ///
  ///
  // final CalendarFormatPage format;
  final DateTimeRange? formatDomain;
  final int formatStartingWeekday;
  final List<int> formatAvailables;
  final ValueChanged<int>? formatOnChanged;
  final Duration formatAnimationDuration;
  final Curve formatAnimationCurve;
  final CalendarPageNext? formatPagingToWhere;
  final Duration pagingDuration;
  final Curve pagingCurve;
  final CalendarPageControllerInitializer pageControllerInitializer;

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
  final List<CalendarCell> cellPrioritization;
  final HitTestBehavior cellHitTestBehavior;
  final EdgeInsets cellMargin;
  final EdgeInsets cellPadding;
  final AlignmentGeometry cellAlignment;
  final Duration cellAnimationDuration;
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
  final OnDateChanged? onDateFocused;
  final OnPageChanged? onPageChanged;
  final void Function(PageController pageController)? onInitState;

  const CalendarStyle({
    this.dateTextFormatter = _dateTextFormater,
    // this.focusInitializer = CalendarFocus.withSelection,
    this.focusInitializer = CalendarFocus.onlyFocus,
    this.verticalFlex = 1, // 1 expand, 0 shrink
    this.verticalFlexFit = FlexFit.loose,
    this.horizontalScroll = const PageScrollPhysics(),

    //
    // this.format = CalendarFormatPage.month,
    this.formatDomain,
    this.formatAvailables = weeksPerPage_all,
    this.formatStartingWeekday = DateTime.sunday,
    this.formatOnChanged,
    this.formatPagingToWhere,
    this.formatAnimationDuration = DurationExtension.milli200,
    this.formatAnimationCurve = Curves.linear,
    this.pagingDuration = DurationExtension.milli300,
    this.pagingCurve = Curves.easeOut,
    this.pageControllerInitializer = _pageController,

    //
    this.styleHeader = const CalendarStyleHeader(),
    this.styleDayOfWeek = const CalendarStyleDayOfWeek(),
    this.styleWeekNumber,
    this.styleCellStack,

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
    this.cellPrioritization = const [
      (
        CalendarCellType.disabled,
        (BoxShape.circle, MaterialColorRole.transparent, null),
        (
          MaterialTextTheme.bodyMedium,
          MaterialColorRole.onSurface,
          MaterialEmphasisLevel.inactive,
        ),
      ),
      (
        CalendarCellType.focused,
        (BoxShape.circle, MaterialColorRole.primary, null),
        (
          MaterialTextTheme.bodyLarge,
          MaterialColorRole.onPrimary,
          MaterialEmphasisLevel.primary,
        ),
      ),
      (
        CalendarCellType.outside,
        (BoxShape.circle, MaterialColorRole.surface, null),
        (
          MaterialTextTheme.bodyMedium,
          MaterialColorRole.onSurface,
          MaterialEmphasisLevel.interactive,
        ),
      ),
      (
        CalendarCellType.holiday,
        (
          BoxShape.circle,
          MaterialColorRole.surface,
          MaterialColorRole.outlineVariant,
        ),
        (
          MaterialTextTheme.bodyMedium,
          MaterialColorRole.onSurface,
          MaterialEmphasisLevel.primary,
        ),
      ),
      (
        CalendarCellType.today,
        (BoxShape.circle, MaterialColorRole.surface, MaterialColorRole.outline),
        (
          MaterialTextTheme.bodyLarge,
          MaterialColorRole.onSurface,
          MaterialEmphasisLevel.primary,
        ),
      ),
      (
        CalendarCellType.normal,
        (BoxShape.circle, MaterialColorRole.surface, null),
        (
          MaterialTextTheme.bodyMedium,
          MaterialColorRole.onSurface,
          MaterialEmphasisLevel.primary,
        ),
      ),
    ],

    ///
    ///
    ///
    this.predicateDisable = DTExt.predicateFalse,
    this.predicateHoliday = DTExt.predicateFalse,
    this.predicateWeekend = DTExt.predicateWeekend,
    this.onDateFocused,
    this.onPageChanged,
    this.onInitState,
  }) : _tableColumnWidth = tableColumnWidth;

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

  static PageController _pageController(
    DateTimeRange domain,
    int weeksPerPage,
    DateTime dateFocused,
  ) => PageController(
    initialPage:
        DTExt.pageFrom(domain.start, dateFocused, weeksPerPage).floor(),
  );

  ///
  ///
  ///
  static String _dateTextFormater(DateTime date, dynamic locale) =>
      '${date.day}';

  ///
  /// [domain]
  /// [tableColumnWidth]
  ///
  DateTimeRange domain([DateTime? focusedDate]) {
    final domain = formatDomain;
    if (domain != null) return domain;
    return DTRExt.scopeMonthsFrom(
      (focusedDate ?? DateTime.now()).dateOnly,
      before: 3,
      after: 3,
    );
  }

  Map<int, TableColumnWidth>? get tableColumnWidth =>
      _tableColumnWidth ??
      (styleWeekNumber == null
          ? null
          : {0: FixedColumnWidth(styleWeekNumber!.flexOnRow)});

  ///
  /// [_heightBody]
  /// [_pageNextFocus]
  /// [_pageFirstDateFrom]
  ///
  double _heightBody(BoxConstraints constraints) =>
      constraints.maxHeight -
      tablePadding.vertical -
      (styleDayOfWeek?.height ?? 0) -
      (styleHeader?.height ?? 0);

  // todo: page next focus
  DateTime? _pageNextFocus(int weeksPerPage, int index, int indexPrevious) {
    if (weeksPerPage == CalendarStyle.weeksPerPage_6) {
      return switch (formatPagingToWhere) {
        null => null,
        CalendarPageNext.correspondingDay => throw UnimplementedError(),
        CalendarPageNext.correspondingWeekAndDay => throw UnimplementedError(),
        CalendarPageNext.firstDateOfMonth => throw UnimplementedError(),
        CalendarPageNext.firstDateOfFirstWeek => throw UnimplementedError(),
        CalendarPageNext.lastDateOfMonth => throw UnimplementedError(),
        CalendarPageNext.lastDateOfLastWeek => throw UnimplementedError(),
      };
    } else {
      throw UnimplementedError();
    }
  }

  IndexingDate _pageFirstDateFrom(
    DateTime domainStart,
    DateTime domainEnd,
    int weeksPerPage,
  ) => switch (weeksPerPage) {
    weeksPerPage_6 => DTExt.daysToDateClampFrom(
      domainStart,
      domainEnd,
      startingWeekday: formatStartingWeekday,
      times: DateTime.daysPerWeek * weeksPerPage,
    ),
    _ => throw UnimplementedError(),
  };

  ///
  /// [_buildCell]
  /// [_buildTableWeekDates]
  /// [_buildTableRow], [_buildTable]
  /// [_buildBodyPage], [_buildBody]
  ///
  Widget _buildCell(
    DateTime date,
    dynamic locale,
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
  /// [_initCellStackBuilder]
  /// [_initTableRowsBuilder]
  /// [_initCalendarBuilder]
  ///
  CellBuilder _initCellStackBuilder<T>({
    required EventLoader<T>? eventLoader,
    required EventsLayoutMark<T>? eventsLayoutMark,
    required EventElementMark<T>? eventLayoutSingleMark,
  }) {
    final styleCellStack = this.styleCellStack;
    if (styleCellStack == null) return (_, __, ___, ____, child) => child;
    final buildBackground = styleCellStack.styleBackground?.builderFrom(
      style: this,
      isBackground: true,
    );
    final buildOverlay = styleCellStack.styleOverlay.builderFrom(
      eventLoader: eventLoader,
      eventsLayoutMark: eventsLayoutMark,
      eventLayoutSingleMark: eventLayoutSingleMark,
    );
    final build = styleCellStack._build;

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
              return build([child, if (overlay != null) overlay]);
            })
        : (buildOverlay == null
            ? (date, focusedDate, cellType, constraints, child) {
              final background = buildBackground(
                date,
                focusedDate,
                cellType,
                constraints,
              );
              return build([if (background != null) background, child]);
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
              return build([
                if (background != null) background,
                child,
                if (overlay != null) overlay,
              ]);
            });
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
      predicateWeekend: predicateWeekend,
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
    final headerBuilder = styleHeader.initBuilder(
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
