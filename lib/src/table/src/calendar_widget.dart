part of '../table_calendar.dart';

///
///
///
/// [Calendar]
///
///
///

///
/// [style], ...
/// [updaterDefault], ...
///
class Calendar<T> extends StatefulWidget {
  final CalendarStyle style;
  final CalendarUpdater? updater;
  final EventsLayoutMark<T>? eventsLayoutMark;
  final EventElementMark<T>? eventLayoutSingleMark;
  final EventLoader<T>? eventLoader;
  final dynamic locale;
  final int weeksPerPage;
  final DateTime? dateFocused;

  Calendar({
    super.key,
    this.style = const CalendarStyle(),
    this.updater,
    this.eventsLayoutMark,
    this.eventLayoutSingleMark,
    this.eventLoader,
    this.locale,
    this.dateFocused,
    this.weeksPerPage = CalendarStyle.weeksPerPage_6,
  }) : assert(style.formatAvailables.contains(weeksPerPage)),
       assert(
         style.formatAvailables.length <= CalendarStyle.weeksPerPage_all.length,
       );

  @override
  State<Calendar<T>> createState() => _CalendarState<T>();

  ///
  ///
  ///
  static CalendarStyle updaterDefault<T>(
    CalendarPageState pageState,
    CalendarFocus focus,
    Calendar<T> oldWidget,
    Calendar<T> widget,
  ) {
    final style = widget.style;
    final next = widget.dateFocused;
    if (next == null) return style;
    if (focus.dateFocused != next) {
      final i =
          CalendarPageState.measure(
            focus.domain.start,
            next,
            pageState.weeks.value,
          ).floor();
      final indexPrevious = pageState.indexPrevious;
      if (i == indexPrevious || i == 0 || i == pageState.count - 1) {
        return style;
      }
      final pageController = pageState.controller;
      if ((i - indexPrevious).abs() > 1) {
        pageController.jumpToPage(i > indexPrevious ? i - 1 : i + 1);
      }
      pageController.animateToPage(
        i,
        duration: style.pagingDuration,
        curve: style.pagingCurve,
      );
      pageState.indexPrevious = i;
    }
    return style;
  }
}

class _CalendarState<T> extends State<Calendar<T>> {
  ///
  /// [_focus], [_page], [_style]
  /// [dispose], [initState], [didUpdateWidget]
  ///
  late CalendarStyle _style;
  late final CalendarFocus _focus;
  late final CalendarPageState _page;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final focus = CalendarFocus(widget);
    final dateFocused = focus.dateFocused;
    final d = focus.domain;
    final start = d.start;
    final end = d.end;
    final wPP = widget.weeksPerPage;
    final style = widget.style;
    _style = style;
    _focus = focus;
    _page = CalendarPageState(
      controller: style.pageControllerInitializer(d, wPP, dateFocused),
      height: ValueNotifier(double.infinity),
      weeks: ValueNotifier(wPP),
      count: CalendarPageState.measure(start, end, wPP).ceil(),
      findDate: CalendarPageState.finderFrom(
        start,
        end,
        wPP,
        style.formatStartingWeekday,
      ),
    );
    initialize(style, focus);
  }

  @override
  void didUpdateWidget(Calendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final style = widget.updater?.call(_page, _focus, oldWidget, widget);
    if (style == null) return;
    if (style != _style) {
      _style = style;
      initialize(style, _focus);
    }
  }

  ///
  /// [_onPageChanged], [_cellPrioritization]
  /// [_cellBuilder], [_builder], [initialize]
  ///
  late ValueChanged<int> _onPageChanged;
  late List<CalendarCellPrioritization> _cellPrioritization;
  late CellBuilder _cellBuilder;
  late DateBuilder _builder;

  void initialize(CalendarStyle style, CalendarFocus focus) {
    _onPageChanged = _page._indexFinderFrom(style, focus);
    _cellPrioritization = style._initCellPrioritization(focus._predicators);
    _cellBuilder =
        style.styleCellStack?._initCellStackBuilder(
          style: style,
          focus: focus,
          eventLoader: widget.eventLoader,
          eventsLayoutMark: widget.eventsLayoutMark,
          eventLayoutSingleMark: widget.eventLayoutSingleMark,
        ) ??
        style._buildCell;
    _builder = style._initCalendarBuilder(
      bodyLayout: _layout,
      pageController: _page.controller,
      locale: widget.locale,
      pageWeeks: _page.weeks,
      updateFormatIndex: _updateFormatIndex,
    );
  }

  ///
  /// [_updateFormatIndex]
  ///
  BoxConstraints? _constraintsTableBody;
  late TableRowsBuilder _constraintsTableBuilder;
  late double _constraintsCellHeight;

  void _updateFormatIndex(int index) {
    final style = _style;
    final weeksPerPage = style.formatAvailables[index];
    if (weeksPerPage == _page.weeks.value) return;
    _page.weeks.value = weeksPerPage;
    _page.height.value = _constraintsTableBody!.maxHeight;
    style.formatOnChanged?.call(weeksPerPage);
  }

  ///
  /// [_dateBuilder]
  ///
  DateBuilder get _dateBuilder {
    final prioritization = _cellPrioritization;

    // gesture
    final style = _style;
    final onTap = _focus.onFocusDate;
    final hitTestBehavior = style.cellHitTestBehavior;

    final predicateBlocked = _focus.predicateBlocked;
    final build = _cellBuilder;
    return (date) {
      if (predicateBlocked(date)) return _layoutCell(null);
      for (var p in prioritization) {
        final predicate = p.$1;
        if (predicate != null && !predicate(date)) continue;
        return _layoutCell(
          LayoutBuilder(
            builder: (context, constraints) {
              final child = build(
                context,
                constraints,
                widget.locale,
                date,
                p.$3(context),
                p.$4(context),
              );
              return p.$2
                  ? GestureDetector(
                    behavior: hitTestBehavior,
                    onTap: onTap(setState, date),
                    child: child,
                  )
                  : child;
            },
          ),
        );
      }
      throw StateError('unknown cell type for date:$date');
    };
  }

  ///
  /// [_layoutCell]
  /// [_layout]
  /// [_layoutPage]
  ///
  Widget _layoutCell(Widget? child) =>
      SizedBox(height: _constraintsCellHeight, child: child);

  Widget _layoutPage(IndexedWidgetBuilder itemBuilder) =>
      ValueListenableBuilder<double>(
        valueListenable: _page.height,
        builder: _style._buildBodyPage,
        child: PageView.builder(
          onPageChanged: _onPageChanged,
          controller: _page.controller,
          physics: _style.horizontalScroll,
          itemCount: _page.count,
          itemBuilder: itemBuilder,
        ),
      );

  Widget _layout(BuildContext context, BoxConstraints constraints) {
    final style = _style;
    final weeksPerPage = _page.weeks.value;
    if (_constraintsTableBody != constraints) {
      _constraintsTableBody = constraints;
      final height = style._heightBody(constraints) / weeksPerPage;
      _constraintsCellHeight = height;
      _constraintsTableBuilder = style._initTableRowsBuilder(
        widget.locale,
        height,
        _focus.predicateBlocked,
      );
    }
    final tableBuilder = _constraintsTableBuilder;
    final dateBuilder = _dateBuilder;
    final firstDateOfPage = _page.findDate;
    final datesPerPage = DateTime.daysPerWeek * weeksPerPage;
    return _layoutPage(
      (context, index) => tableBuilder(
        firstDateOfPage(index).datesGenerate(datesPerPage),
        dateBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _builder(_focus.dateFocused);
}
