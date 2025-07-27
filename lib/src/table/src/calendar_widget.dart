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
  final MarkConfiguration<T>? eventMarkConfiguration;

  Calendar({
    super.key,
    this.locale,
    this.style = const CalendarStyle(),
    this.focusedDate,
    this.weeksPerPage = CalendarStyle.weeksPerPage_6,
    this.eventsLayoutMark,
    this.eventLayoutSingleMark,
    this.eventLoader,
    this.eventMarkConfiguration,
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
  late DateTimeRange _domain;
  late CalendarStyle _style;
  late DateTime _focusedDate;
  late double _cellHeight;
  late TableRowsBuilder _tableBuilder;
  late IndexingDate _paging;
  late DateBuilder _cellBuilder;
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
    final style = widget.style;
    final focusedDate = widget.focusedDate ?? DateTime.now();
    final domain = style.domain(focusedDate);
    final domainStart = domain.start;
    final domainEnd = domain.end;
    _style = style;
    _domain = domain;
    _focusedDate = focusedDate;

    final wPP = widget.weeksPerPage;
    final indexInitial = DTExt.pageFrom(domainStart, focusedDate, wPP).floor();
    _indexPrevious = indexInitial;

    _pageCount = DTExt.pageFrom(domainStart, domainEnd, wPP).ceil();
    _pageHeight = ValueNotifier(double.infinity);
    _pageWeeks = ValueNotifier(wPP);
    _pageController = PageController(initialPage: indexInitial);
    _paging = style._pageFirstDateFrom(domainStart, domainEnd, wPP);
    _cellBuilder = style._initCellBuilder(
      locale: widget.locale,
      configuration: {
        CalendarCellType.disabled: style.predicateDisable,
        CalendarCellType.holiday: style.predicateHoliday,
        CalendarCellType.weekend: style.predicateWeekend,
        CalendarCellType.weekday: style.predicateWeekday,
        CalendarCellType.focused: _predicateSelected,
        CalendarCellType.outside: _predicateOutside,
        CalendarCellType.today: DTExt.predicateToday,
      },
      onTap: _onDateTapped,
      getHeight: () => _cellHeight,
      getFocusedDate: () => _focusedDate,
      predicateBlocked: _predicateBlocked,
      eventLoader: widget.eventLoader,
      eventsLayoutMark: widget.eventsLayoutMark,
      eventLayoutSingleMark: widget.eventLayoutSingleMark,
      eventMarkConfiguration: widget.eventMarkConfiguration,
    );
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

    style.onCalendarInited?.call(_pageController);
  }

  @override
  void didUpdateWidget(Calendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final style = widget.style;
    if (style != oldWidget.style) {
      // TODO: update entire calendar style by updating widget
      _style = style;
      return;
    }
    final next = widget.focusedDate;
    if (next == null) return;
    if (_focusedDate != next) {
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
  /// [_onDateTapped]
  /// [_onPageChanged]
  /// [_updateFormatIndex]
  ///
  void _onDateTapped(DateTime date) {
    final focusedDate = _focusedDate;
    if (date == focusedDate) {
      // TODO: update to date selected
      // TODO: update to date range start, highlight, end
      ///
      ///
      ///
      // if (_selectedDate == null) {
      //   _selectedDate = date;
      //   widget.onRangeSelected!(_selectedDate, null, _focusedDate);
      // } else {
      //   if (date.isAfter(_selectedDate!)) {
      //     widget.onRangeSelected!(_selectedDate, date, _focusedDate);
      //     _selectedDate = null;
      //   } else if (date.isBefore(_selectedDate!)) {
      //     widget.onRangeSelected!(date, _selectedDate, _focusedDate);
      //     _selectedDate = null;
      //   }
      // }
      //
      // widget.onDateSelected?.call(date, _focusedDate);
      return;
    }
    setState(() => _focusedDate = date);
    _style.onDateFocused?.call(date, focusedDate);
  }

  void _onPageChanged(int index) {
    if (index == _indexPrevious) return;
    final indexPrevious = _indexPrevious;
    final style = _style;
    final next = style._pageNextFocus(_pageWeeks.value, index, indexPrevious);
    if (next != null) _focusedDate = next;

    _indexPrevious = index;
    style.onPageChanged?.call(index, indexPrevious, next ?? _focusedDate);
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
  /// [_predicateSelected]
  /// [_predicateOutside]
  /// [_predicateBlocked]
  ///
  bool _predicateSelected(DateTime date) => date.isSameDate(_focusedDate);

  bool _predicateOutside(DateTime date) => date.month != _focusedDate.month;

  bool _predicateBlocked(DateTime date) {
    final domain = _domain;
    return date.isBefore(domain.start) || date.isAfter(domain.end);
  }

  ///
  /// [_layout]
  /// [_layoutPage]
  ///
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
    final table = _tableBuilder;
    final firstDateOfPage = _paging;
    final datesPerPage = DateTime.daysPerWeek * weeksPerPage;
    final cellBuilder = _cellBuilder;
    return _layoutPage(
      (context, index) => table(
        firstDateOfPage(index).datesGenerate(datesPerPage),
        cellBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _builder(_focusedDate);
}
