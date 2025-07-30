// ignore_for_file: constant_identifier_names
part of '../table_calendar.dart';

///
///
/// [CalendarStyle] layout depends on parent constrains, it's better not to specify height
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
  final CalendarStyleCellOverlay? styleCellOverlay;
  final CalendarStyleCellBackground? styleCellBackground;

  ///
  ///
  ///
  final List<(CalendarCellType, DecorationTextStyle)> cellSetup;
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
  final OnDateChanged? onDateFocused;
  final OnPageChanged? onPageChanged;
  final void Function(PageController pageController)? onInitState;

  const CalendarStyle({
    this.dateTextFormatter = _dateTextFormater,
    this.verticalFlex = 1, // 1 expand, 0 shrink
    this.verticalFlexFit = FlexFit.loose,
    this.horizontalScroll = const PageScrollPhysics(),

    ///
    ///
    ///
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

    ///
    ///
    ///
    this.styleHeader = const CalendarStyleHeader(),
    this.styleDayOfWeek = const CalendarStyleDayOfWeek(),
    this.styleWeekNumber,
    this.styleCellOverlay = const CalendarStyleCellOverlay(),
    this.styleCellBackground,

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
    /// TODO: defin my custom style
    ///
    this.cellSetup = const [
      (
        CalendarCellType.disabled,
        DecorationTextStyle(
          BoxDecoration(shape: BoxShape.circle),
          TextStyle(color: Color(0xFFDFDFDF)),
        ),
      ),
      (
        CalendarCellType.focused,
        DecorationTextStyle(
          BoxDecoration(color: Color(0xFF5C6BC0), shape: BoxShape.circle),
          TextStyle(color: Color(0xFFFAFAFA), fontSize: 16.0),
        ),
      ),
      (
        CalendarCellType.today,
        DecorationTextStyle(
          BoxDecoration(color: Color(0xFF9FA8DA), shape: BoxShape.circle),
          TextStyle(color: Color(0xFFFAFAFA), fontSize: 16.0),
        ),
      ),
      (
        CalendarCellType.outside,
        DecorationTextStyle(
          BoxDecoration(shape: BoxShape.circle),
          TextStyle(color: Color(0xFFAEAEAE)),
        ),
      ),
      (
        CalendarCellType.weekend,
        DecorationTextStyle(
          BoxDecoration(shape: BoxShape.circle),
          TextStyle(color: Color(0xFF5A5A5A)),
        ),
      ),
      (
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
      (
        CalendarCellType.weekday,
        DecorationTextStyle(BoxDecoration(shape: BoxShape.circle), TextStyle()),
      ),
    ],

    ///
    ///
    ///
    this.predicateDisable = DTExt.predicateFalse,
    this.predicateHoliday = DTExt.predicateFalse,
    this.predicateWeekend = DTExt.predicateWeekend,
    this.predicateWeekday = DTExt.predicateWeekday,
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

  DateTime? _pageNextFocus(int weeksPerPage, int index, int indexPrevious) {
    if (weeksPerPage == CalendarStyle.weeksPerPage_6) {
      return switch (formatPagingToWhere) {
        null => null,
        CalendarPageNext.correspondingDay => throw UnimplementedError(),
        CalendarPageNext.correspondingWeekAndDay =>
          throw UnimplementedError(),
        CalendarPageNext.firstDateOfMonth => throw UnimplementedError(),
        CalendarPageNext.firstDateOfFirstWeek =>
          throw UnimplementedError(),
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
  /// [_buildCellStack]
  /// [buildTableWeekDates]
  /// [_buildTableRow], [_buildTable]
  /// [_buildBodyPage], [_buildBody]
  ///
  Widget _buildCell(DateTime date, dynamic locale, DecorationTextStyle style) =>
      Semantics(
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

  // todo: instead of being a maybe unused function, create a property (with stack | without stack)
  Widget _buildCellStack(List<Widget> children) => Stack(
    alignment: cellStackAlignment,
    clipBehavior: cellStackClip,
    children: children,
  );

  static List<Widget> buildTableWeekDates(
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
  /// [_initColumnBuilder]
  /// [_initTableBuilder]
  /// [_initCellStackBuilder]
  ///
  DateBuilder _initColumnBuilder({
    required DateBuilder? headerBuilder,
    required ConstraintsBuilder bodyLayout,
  }) =>
      headerBuilder == null
          ? (_) => _buildBody(bodyLayout)
          : (date) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [headerBuilder(date), _buildBody(bodyLayout)],
          );

  TableRowsBuilder _initTableBuilder(
    dynamic locale,
    double heightRow,
    Predicator<DateTime> predicateBlock,
  ) {
    final styleWeekNumber = this.styleWeekNumber;
    final firstColumn = styleWeekNumber?.builderFrom(predicateBlock, heightRow);
    final List<Widget> Function(List<DateTime>, int, DateBuilder) rowBody =
        firstColumn == null
            ? (dates, iRow, buildCell) =>
                buildTableWeekDates(dates, iRow, buildCell)
            : (dates, iRow, buildCell) => [
              firstColumn(dates[DateTime.daysPerWeek * iRow]),
              ...buildTableWeekDates(dates, iRow, buildCell),
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

  CellBuilder _initCellStackBuilder<T>({
    required EventLoader<T>? eventLoader,
    required EventsLayoutMark<T>? eventsLayoutMark,
    required EventElementMark<T>? eventLayoutSingleMark,
  }) {
    final buildBackground = styleCellBackground?.builderFrom(
      style: this,
      isBackground: true,
    );
    final buildOverlay = styleCellOverlay?.builderFrom(
      eventLoader: eventLoader,
      eventsLayoutMark: eventsLayoutMark,
      eventLayoutSingleMark: eventLayoutSingleMark,
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
              return _buildCellStack([child, if (overlay != null) overlay]);
            })
        : (buildOverlay == null
            ? (date, focusedDate, cellType, constraints, child) {
              final background = buildBackground(
                date,
                focusedDate,
                cellType,
                constraints,
              );
              return _buildCellStack([
                if (background != null) background,
                child,
              ]);
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
              return _buildCellStack([
                if (background != null) background,
                child,
                if (overlay != null) overlay,
              ]);
            });
  }
}
