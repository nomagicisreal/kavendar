part of '../table_calendar.dart';

///
///
/// [Calendar]
/// [VerticalDragIndexing]
/// [_TableCalendarRange]
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
  final EventsLayoutMark<T>? eventsLayoutMark;
  final EventElementMark<T>? eventLayoutSingleMark;
  final EventLoader<T>? eventLoader;

  Calendar({
    super.key,
    this.locale,
    this.style = const CalendarStyle(),
    this.focusedDate,
    this.weeksPerPage = CalendarStyle.weeksPerPage_6,
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
       }(), 'focusedDay($focusedDate) must between domain(${style.domain})'),
       assert(() {
         final weekend = style.predicateWeekend;
         final weekday = style.predicateWeekday;
         var date = DateTime.now();
         for (var i = 0; i < 7; i++) {
           if (weekend(date) == weekday(date)) return false;
         }
         return true;
       }());

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
  late _CalendarFocus _focus;
  late IndexingDate _paging;
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
    _focus = _CalendarFocus(widget);
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
    _builder = style._initColumnBuilder(
      headerBuilder: style.styleHeader?.initBuilder(
        pageController: _pageController,
        style: style,
        locale: widget.locale,
        weeksPerPage: _pageWeeks,
        updateFormatIndex: _updateFormatIndex,
      ),
      bodyLayout: _layout,
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
    style.onPageChanged?.call(index, indexPrevious, next ?? _focus.dateFocused);
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
  /// [_predicateFocused]
  /// [_predicateOutside]
  /// [_predicateBlocked]
  ///
  bool _predicateFocused(DateTime date) => date.isSameDate(_focus.dateFocused);

  bool _predicateOutside(DateTime date) =>
      date.month != _focus.dateFocused.month;

  bool _predicateBlocked(DateTime date) {
    final domain = _domain;
    return date.isBefore(domain.start) || date.isAfter(domain.end);
  }

  ///
  /// [_layout]
  /// [_layoutPage]
  ///
  DateBuilder get _initDateBuilder {
    final style = _style;
    final cellSetup = style.cellSetup;
    final cellHitTestBehavior = style.cellHitTestBehavior;
    final configuration = {
      CalendarCellType.disabled: style.predicateDisable,
      CalendarCellType.holiday: style.predicateHoliday,
      CalendarCellType.weekend: style.predicateWeekend,
      CalendarCellType.weekday: style.predicateWeekday,
      CalendarCellType.focused: _predicateFocused,
      CalendarCellType.outside: _predicateOutside,
      CalendarCellType.today: DTExt.predicateToday,
    };
    final buildCellStack = style._initCellStackBuilder(
      eventLoader: widget.eventLoader,
      eventsLayoutMark: widget.eventsLayoutMark,
      eventLayoutSingleMark: widget.eventLayoutSingleMark,
    );
    final buildCell = style._buildCell;
    return (date) {
      Widget? child;
      if (!_predicateBlocked(date)) {
        for (var current in cellSetup) {
          final cellType = current.$1;
          final predicate = configuration[cellType]!;
          if (!predicate(date)) continue;
          child = LayoutBuilder(
            builder: (context, constraints) {
              final child = buildCellStack(
                date,
                _focus.dateFocused,
                cellType,
                constraints,
                buildCell(date, widget.locale, current.$2),
              );
              return cellType == CalendarCellType.disabled
                  ? child
                  : GestureDetector(
                    behavior: cellHitTestBehavior,
                    onTap: _focus.onFocusDate(
                      setState,
                      date,
                      style.onDateFocused,
                    ),
                    child: child,
                  );
            },
          );
          break;
        }
        if (child == null) {
          throw StateError('unknown builder for date($date)');
        }
      }
      return SizedBox(height: _cellHeight, child: child);
    };
  }

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
      _tableBuilder = style._initTableBuilder(
        widget.locale,
        height,
        _predicateBlocked,
      );
    }
    final tableBuilder = _tableBuilder;
    final dateBuilder = _initDateBuilder;
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
