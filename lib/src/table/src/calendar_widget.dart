part of '../table_calendar.dart';

///
///
/// [Calendar]
///
///
class Calendar<T> extends StatefulWidget {
  final dynamic locale;
  final DateTime? focusedDate;
  final int weeksPerPage;

  ///
  ///
  ///
  final CalendarStyle style;
  final Intersector<DateTime>? onNewDateFocused;
  final EventsLayoutMark<T>? eventsLayoutMark;
  final EventElementMark<T>? eventLayoutSingleMark;
  final EventLoader<T>? eventLoader;

  Calendar({
    super.key,
    this.locale,
    this.focusedDate,
    this.weeksPerPage = CalendarStyle.weeksPerPage_6,

    //
    this.style = const CalendarStyle(),
    this.onNewDateFocused,
    this.eventsLayoutMark,
    this.eventLayoutSingleMark,
    this.eventLoader,
  }) : assert(style.formatAvailables.contains(weeksPerPage)),
       assert(
         style.formatAvailables.length <= CalendarStyle.weeksPerPage_all.length,
       ),
       assert(() {
         if (focusedDate == null) return true;
         final domain = style.formatDomain;
         if (domain == null) return true;
         return focusedDate.isAfter(domain.start) &&
             focusedDate.isBefore(domain.end);
       }(), 'focusedDay($focusedDate) must between domain(${style.domain})');

  @override
  State<Calendar<T>> createState() => _CalendarState<T>();
}

///
///
///
class _CalendarState<T> extends State<Calendar<T>> {
  late final PageController _pageController;
  late final ValueNotifier<double> _pageHeight;
  late final ValueNotifier<int> _pageWeeks;

  // DateTime? _selectedDate;
  late int _pageCount;
  late int _indexPrevious;

  late double _cellHeight;
  late DateTimeRange _domain;
  late CalendarFocus _focus;
  late Generator<DateTime> _paging;
  late CalendarStyle _style;
  late TableRowsBuilder _tableBuilder;
  late DateBuilder _builder;
  BoxConstraints? _constraintsBody;

  ///
  /// [dispose], [initState], [didUpdateWidget]
  ///
  @override
  void dispose() {
    _pageController.dispose();
    _pageHeight.dispose();
    _pageWeeks.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focus = CalendarFocus(widget);
    final dateFocused = _focus.dateFocused;
    final style = widget.style;
    final domain = style.domain(dateFocused);
    final domainStart = domain.start;
    final domainEnd = domain.end;
    final wPP = widget.weeksPerPage;

    _style = style;
    _domain = domain;
    _pageCount = DTExt.pageFrom(domainStart, domainEnd, wPP).ceil();
    _pageHeight = ValueNotifier(double.infinity);
    _pageWeeks = ValueNotifier(wPP);
    _pageController = style.pageControllerInitializer(domain, wPP, dateFocused);
    _indexPrevious = _pageController.initialPage;
    _paging = style._pageFirstDateFrom(domainStart, domainEnd, wPP);
    _builder = style._initCalendarBuilder(
      bodyLayout: _layout,
      pageController: _pageController,
      locale: widget.locale,
      pageWeeks: _pageWeeks,
      updateFormatIndex: _updateFormatIndex,
    );
  }

  @override
  void didUpdateWidget(Calendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final style = widget.style;
    if (style != oldWidget.style) {
      // todo: update entire calendar style by updating widget
      _style = style;
      return;
    }
    final next = widget.focusedDate;
    if (next == null) return;
    if (_focus.dateFocused != next) {
      final i = DTExt.pageFrom(_domain.start, next, _pageWeeks.value).floor();
      if (i == _indexPrevious || i == 0 || i == _pageCount - 1) return;
      if ((i - _indexPrevious).abs() > 1) {
        _pageController.jumpToPage(i > _indexPrevious ? i - 1 : i + 1);
      }
      _pageController.animateToPage(
        i,
        duration: style.pagingDuration,
        curve: style.pagingCurve,
      );
      _indexPrevious = i;
    }
  }

  ///
  /// [_onPageChanged]
  /// [_updateFormatIndex]
  ///
  void _onPageChanged(int index) {
    if (index == _indexPrevious) return;
    final indexPrevious = _indexPrevious;
    final style = _style;
    final next = style._pageNextFocus(_pageWeeks.value, index, indexPrevious);
    if (next != null) _focus.dateFocused = next;

    _indexPrevious = index;
    style.pageOnChanged?.call(index, indexPrevious, next ?? _focus.dateFocused);
  }

  void _updateFormatIndex(int index) {
    final style = widget.style;
    final weeksPerPage = style.formatAvailables[index];
    if (weeksPerPage == _pageWeeks.value) return;
    _pageWeeks.value = weeksPerPage;
    _pageHeight.value = _constraintsBody!.maxHeight;
    style.formatOnChanged?.call(weeksPerPage);
  }

  ///
  /// [_predicateBlocked]
  /// [_dateBuilder]
  ///
  bool _predicateBlocked(DateTime date) {
    final domain = _domain;
    return date.isBefore(domain.start) || date.isAfter(domain.end);
  }

  DateBuilder get _dateBuilder {
    final style = _style;
    final prioritization = style.cellPrioritizeWith(_focus._predicators);
    final buildCellStack = style._initCellStackBuilder(
      eventLoader: widget.eventLoader,
      eventsLayoutMark: widget.eventsLayoutMark,
      eventLayoutSingleMark: widget.eventLayoutSingleMark,
    );
    final buildCell = style._buildCell;

    // gesture
    final onTap = _focus.onFocusDate;
    final hitTestBehavior = style.cellHitTestBehavior;
    Widget active({
      required bool isDisable,
      required DateTime date,
      required Widget child,
    }) =>
        isDisable
            ? child
            : GestureDetector(
              behavior: hitTestBehavior,
              onTap: onTap(setState, date),
              child: child,
            );
    return (date) {
      if (_predicateBlocked(date)) return _layoutCell(null);
      for (var current in prioritization) {
        final predicate = current.$1;
        if (predicate != null && !predicate(date)) continue;
        final cellType = current.$2;
        return _layoutCell(
          LayoutBuilder(
            builder: (context, constraints) {
              return active(
                isDisable: cellType == CalendarCellType.disabled,
                date: date,
                child: buildCellStack(
                  date,
                  _focus.dateFocused,
                  cellType,
                  constraints,
                  buildCell(
                    date,
                    widget.locale,
                    current.$3(context),
                    current.$4(context),
                  ),
                ),
              );
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
      SizedBox(height: _cellHeight, child: child);

  Widget _layoutPage(IndexedWidgetBuilder itemBuilder) =>
      ValueListenableBuilder<double>(
        valueListenable: _pageHeight,
        builder: _style._buildBodyPage,
        child: PageView.builder(
          onPageChanged: _onPageChanged,
          controller: _pageController,
          physics: _style.horizontalScroll,
          itemCount: _pageCount,
          itemBuilder: itemBuilder,
        ),
      );

  Widget _layout(BuildContext context, BoxConstraints constraints) {
    final style = _style;
    final weeksPerPage = _pageWeeks.value;
    if (_constraintsBody != constraints) {
      _constraintsBody = constraints;
      final height = style._heightBody(constraints) / weeksPerPage;
      _cellHeight = height;
      _tableBuilder = style._initTableRowsBuilder(
        widget.locale,
        height,
        _predicateBlocked,
      );
    }
    final tableBuilder = _tableBuilder;
    final dateBuilder = _dateBuilder;
    final firstDateOfPage = _paging;
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
