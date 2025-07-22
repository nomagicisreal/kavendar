part of '../table_calendar.dart';

///
///
/// [Calendar]
/// [_TableCalendarVerticalDrag]
/// [_TableCalendarRange]
///
///
class Calendar<T> extends StatefulWidget {
  final dynamic locale;
  final DateTime? _focusedDate;
  final bool pageJumpingEnabled;
  final bool pageAnimationEnabled;
  final int initialWeeksPerPage;
  final Duration formatAnimationDuration;
  final Curve formatAnimationCurve;
  final HitTestBehavior dateHitTestBehavior;

  ///
  ///
  ///
  final CalendarStyle style;
  final CalendarStyleHeader? styleHeader;
  final EventsLayoutMark<T>? eventsLayoutMark;
  final EventMark<T>? eventMark;
  final EventLoader<T>? eventLoader;

  ///
  ///
  ///
  // final RangeSelectionMode rangeSelectionMode;
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

  Calendar({
    super.key,
    DateTime? focusedDate,
    this.locale,
    this.initialWeeksPerPage = CalendarStyle.weeksPerPage_6,
    this.pageJumpingEnabled = true,
    this.pageAnimationEnabled = true,
    this.formatAnimationDuration = DurationExtension.milli200,
    this.formatAnimationCurve = Curves.linear,
    this.dateHitTestBehavior = HitTestBehavior.opaque,

    ///
    ///
    ///
    this.style = const CalendarStyle(),
    this.styleHeader = const CalendarStyleHeader(),
    this.eventsLayoutMark,
    this.eventMark,

    ///
    ///
    ///
    // this.rangeSelectionMode = RangeSelectionMode.toggledOff,
    this.eventLoader,
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
  }) : _focusedDate = focusedDate,
       assert(style.availableWeeksPerPage.contains(initialWeeksPerPage)),
       assert(
         style.availableWeeksPerPage.length <=
             CalendarStyle.weeksPerPage_all.length,
       ),
       assert(() {
         if (focusedDate == null) return true;
         final domain = style._domain;
         if (domain == null) return true;
         return focusedDate.isAfter(domain.start) &&
             focusedDate.isBefore(domain.end);
       }(), 'focusedDay($focusedDate) must between domain(${style.domain})'),
       assert(() {
         var date = DateTime.now();
         for (var i = 0; i < 7; i++) {
           if (predicateWeekend(date) == predicateWeekday(date)) return false;
         }
         return true;
       }());

  @override
  State<Calendar<T>> createState() => _CalendarState<T>();

  DateTime get focusedDate => _focusedDate ?? DateTime.now();

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
}

///
///
///
class _CalendarState<T> extends State<Calendar<T>> {
  late final CalendarCellContainer _configuration;
  late final PageController _pageController;
  late final ValueNotifier<double> _pageHeight;
  late final ValueNotifier<int> _indexWeeksPerPage;

  // late final ValueNotifier<DateTime> _focusedDate;
  late final int _indexEnd;
  late int _indexPrevious;
  late bool _pageCallbackDisabled;
  late DateTimeRange _domain;
  late DateTime _focusedDate;

  // late RangeSelectionMode _rangeSelectionMode;

  // DateTime? _selectedDate;

  @override
  void dispose() {
    _pageController.dispose();
    _pageHeight.dispose();
    _indexWeeksPerPage.dispose();
    // _focusedDate.dispose();
    super.dispose();
  }

  ///
  ///
  ///
  int _indexPage(DateTime from, DateTime target, int weeksPerPage) {
    final style = widget.style;
    final starting = style.startingWeekday;
    final weeks =
        (target
                .lastDateOfWeek(starting)
                .difference(from.firstDateOfWeek(starting))
                .inDays +
            1) ~/
        DateTime.daysPerWeek;

    return (weeks / weeksPerPage).ceil();
  }

  @override
  void initState() {
    super.initState();
    final focusedDate = widget.focusedDate;
    final style = widget.style;
    final wPP = widget.initialWeeksPerPage;
    final domain = style.domain(focusedDate);
    _domain = domain;
    _focusedDate = focusedDate;

    final indexPageInitial = _indexPage(domain.start, focusedDate, wPP);
    _indexPrevious = indexPageInitial;
    _indexEnd = _indexPage(domain.start, domain.end, wPP);
    _indexWeeksPerPage = ValueNotifier(
      style.availableWeeksPerPage.indexOf(wPP),
    );

    // _rangeSelectionMode = widget.rangeSelectionMode;
    _pageHeight = ValueNotifier(double.infinity);
    _pageController = PageController(initialPage: indexPageInitial);
    _pageCallbackDisabled = false;

    _configuration = {
      CalendarCellType.disabled: (widget.predicateDisable, style.buildDisabled),
      CalendarCellType.holiday: (widget.predicateHoliday, style.buildHoliday),
      CalendarCellType.weekend: (widget.predicateWeekend, style.buildWeekend),
      CalendarCellType.weekday: (widget.predicateWeekday, style.buildWeekday),
      CalendarCellType.selected: (_predicateSelected, style.buildSelected),
      CalendarCellType.outside: (_predicateOutside, style.buildOutside),
      CalendarCellType.today: (_predicateToday, style.buildToday),
    };

    widget.onCalendarCreated?.call(_pageController);
  }

  ///
  ///
  ///
  void _updatePage(bool shouldAnimate) {
    final style = widget.style;
    final indexCurrent = _indexPage(
      _domain.start,
      _focusedDate,
      style.availableWeeksPerPage[_indexWeeksPerPage.value],
    );

    if (indexCurrent != _indexPrevious ||
        indexCurrent == 0 ||
        indexCurrent == _indexEnd) {
      _pageCallbackDisabled = true;
      return;
    }

    // if (shouldAnimate) {
    //   if ((indexCurrent - _indexPrevious).abs() > 1) {
    //     _pageController.jumpToPage(
    //       indexCurrent > _indexPrevious ? indexCurrent - 1 : indexCurrent + 1,
    //     );
    //   }
    //
    //   final style = widget.style;
    //   _pageController.animateToPage(
    //     indexCurrent,
    //     duration: style.pageStepDuration,
    //     curve: style.pageStepCurve,
    //   );
    // } else {
    //   _pageController.jumpToPage(indexCurrent);
    // }

    _indexPrevious = indexCurrent;
    _pageCallbackDisabled = false;
  }

  @override
  void didUpdateWidget(Calendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusedDate != widget.focusedDate || widget.style != oldWidget.style) {
      _focusedDate = widget.focusedDate;
      _updatePage(widget.pageAnimationEnabled);
    }

    // if (_rangeSelectionMode != widget.rangeSelectionMode) {
    //   _rangeSelectionMode = widget.rangeSelectionMode;
    // }

    // if (rangeStart == null && rangeEnd == null) {
    //   _selectedDate = null;
    // }
  }

  ///
  ///
  ///
  void _onDateTapped(DateTime date) {
    if (widget.predicateDisable(date)) {
      return widget.onDisabledDayTapped?.call(date);
    }

    _updateFocusOnTap(date);

    // if (_rangeSelectionMode.isSelectionOn && widget.onRangeSelected != null) {
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
    // } else {
    //   widget.onDaySelected?.call(date, _focusedDate);
    // }
  }

  void _onDateLongPressed(DateTime date) {
    if (widget.predicateDisable(date)) {
      return widget.onDisabledDayLongPressed?.call(date);
    }

    if (widget.onDateLongPressed != null) {
      _updateFocusOnTap(date);
      return widget.onDateLongPressed!(date, _focusedDate);
    }

    if (widget.onRangeSelected != null) {
      // if (_rangeSelectionMode.isToggleAble) {
      //   _updateFocusOnTap(date);
      //   _rangeSelectionMode =
      //       _rangeSelectionMode == RangeSelectionMode.toggledOn
      //           ? RangeSelectionMode.toggledOff
      //           : RangeSelectionMode.toggledOn;
      //
      //   if (_rangeSelectionMode.isSelectionOn) {
      //     _selectedDate = date;
      //     widget.onRangeSelected!(_selectedDate, null, _focusedDate);
      //   } else {
      //     _selectedDate = null;
      //     widget.onDaySelected?.call(date, _focusedDate);
      //   }
      // }
    }
  }

  ///
  ///
  ///
  void _updateFocusOnTap(DateTime date) {
    // print('focused: ${_focusedDate}, date: $date');
    if (widget.pageJumpingEnabled) {
      _focusedDate = date;
      setState(() {});
      // TODO: instead of setState, using ValueListenableBuilder
      return;
    }

    final focusedDate = _focusedDate;
    if (widget.initialWeeksPerPage == CalendarStyle.weeksPerPage_6) {
      if (date.month < focusedDate.month) {
        _focusedDate = focusedDate.firstDateOfMonth;
      } else if (date.month > focusedDate.month) {
        _focusedDate = focusedDate.lastDateOfMonth;
      } else {
        _focusedDate = date;
      }
    } else {
      _focusedDate = date;
    }
  }

  ///
  ///
  ///
  // Widget _builderDate({
  //   required DateTime date,
  //   required CellBuilder build,
  //   required ConstraintsBuilder? buildHighlight,
  //   required ConstraintsBuilder? buildMarks,
  // }) => LayoutBuilder(
  //   builder:
  //       buildHighlight == null
  //           ? (buildMarks == null
  //               ? (_, constraints) =>
  //                   build(date, _focusedDate, widget.locale, constraints)
  //               : widget.style.layoutCellStack(
  //                 (context, constraints) => [
  //                   build(date, _focusedDate, widget.locale, constraints),
  //                   buildMarks(context, constraints),
  //                 ],
  //               ))
  //           : (buildMarks == null
  //               ? widget.style.layoutCellStack(
  //                 (context, constraints) => [
  //                   buildHighlight(context, constraints),
  //                   build(date, _focusedDate, widget.locale, constraints),
  //                 ],
  //               )
  //               : widget.style.layoutCellStack(
  //                 (context, constraints) => [
  //                   buildHighlight(context, constraints),
  //                   build(date, _focusedDate, widget.locale, constraints),
  //                   buildMarks(context, constraints),
  //                 ],
  //               )),
  // );

  ///
  ///
  ///
  bool _predicateToday(DateTime date) => date.isSameDate(DateTime.now());

  bool _predicateSelected(DateTime date) => date.isSameDate(_focusedDate);

  bool _predicateOutside(DateTime date) => date.month != _focusedDate.month;

  ///
  ///
  ///
  DateTime _paging(int times) {
    final domain = _domain;
    final domainStart = domain.start;
    final domainEnd = domain.end;
    final date = DateTime(
      domainStart.year,
      domainStart.month,
      domainStart.day + DateTime.daysPerWeek * times,
    );
    return date.isAfter(domainEnd) ? domainEnd : date;
  }

  void _layoutPageOnChange(int index) {
    if (!_pageCallbackDisabled) {
      final style = widget.style;
      final next =
          index == _indexPrevious
              ? _focusedDate
              : _paging(
                (index - _indexPrevious) *
                    style.availableWeeksPerPage[_indexWeeksPerPage.value],
              ).clamp(_domain.start, _domain.end);

      if (!_focusedDate.isSameDate(next)) {
        _focusedDate = next;
      }
      _indexPrevious = index;
      widget.onPageChanged?.call(index, next);
    }

    _pageCallbackDisabled = false;
  }

  BoxConstraints? _constraintsBody;

  double get heightRow {
    final style = widget.style;
    return (_constraintsBody!.maxHeight -
            style.tablePadding.vertical -
            (style.styleDayOfWeek?.height ?? 0.0)) /
        // weeksPerPage;
        style.availableWeeksPerPage[_indexWeeksPerPage.value];
  }

  Widget _buildPage(BuildContext context, double value, Widget? child) =>
      AnimatedSize(
        duration: widget.formatAnimationDuration,
        curve: widget.formatAnimationCurve,
        alignment: Alignment.topCenter,
        child: SizedBox(height: value, child: child),
      );

  Predicator<DateTime> get predicateBlock {
    final domain = widget.style.domain(widget.focusedDate);
    return (date) => date.isBefore(domain.start) || date.isAfter(domain.end);
  }

  ///
  ///
  ///
  NullableIndexedWidgetBuilder _builderPageItem() {
    final eventsLayoutMark = widget.eventsLayoutMark;
    final eventMark = widget.eventMark;
    final eventLoader = widget.eventLoader;

    final locale = widget.locale;
    final style = widget.style;
    final configuration = _configuration;

    final table = style.table(
      (date) => style.conditionCell(
        date: date,
        configuration: configuration,
        focusedDate: _focusedDate,
        locale: locale,
        eventsLayoutMark: eventsLayoutMark,
        eventMark: eventMark,
        eventLoader: eventLoader,
        onTap: () => _onDateTapped(date),
        onLongPress: () => _onDateLongPressed(date),
      ),
      heightRow: heightRow,
      predicateBlock: predicateBlock,

      // TODO: hide these
      daysOfWeek: style.styleDayOfWeek?.buildTableRow(
        predicateWeekend: widget.predicateWeekend,
        date: _focusedDate,
        locale: locale,
        constraints: _constraintsBody!,
        weekNumberTitle: style.styleWeekNumber?.buildTitle(
          style.styleDayOfWeek?.height,
        ),
      ),
      builderWeekNumber: style.styleWeekNumber?.builderFrom(predicateBlock),
    );

    // TODO: preload cells builders

    final pageDays =
        DateTime.daysPerWeek *
        style.availableWeeksPerPage[_indexWeeksPerPage.value];
    final paging = _paging;
    return (context, index) {
      final start = paging(index * pageDays);
      return table(
        List.generate(
          pageDays,
          (index) => DateTime(start.year, start.month, start.day + index),
        ),
      );
    };
  }

  ///
  ///
  ///
  void _updateFormatIndex(int index) {
    if (index == _indexWeeksPerPage.value) return;
    final style = widget.style;
    _indexWeeksPerPage.value = index;
    final weeksPerPage = style.availableWeeksPerPage[index];
    _pageHeight.value = heightRow;
    style.onFormatChanged?.call(weeksPerPage);
  }

  Widget buildHeader(BuildContext context, CalendarStyleHeader style) {
    final buildFormatButton = style.styleFormatButton?.buildFrom(
      widget.style,
      _indexWeeksPerPage,
      (index) => _updateFormatIndex(index),
    );
    final buildChevron = style.styleChevrons?.buildFrom;
    return Container(
      decoration: style.headerDecoration,
      margin: style.headerMargin,
      padding: style.headerPadding,
      child: Row(
        children: [
          if (buildChevron != null)
            buildChevron(
              DirectionIn4.left,
              iconOnTap: _pageController.previousPage,
              duration: widget.style.pageStepDuration,
              curve: widget.style.pageStepCurve,
            ),
          style.buildTitle(_focusedDate, widget.locale),
          if (buildFormatButton != null) buildFormatButton(context),
          if (buildChevron != null)
            buildChevron(
              DirectionIn4.right,
              iconOnTap: _pageController.nextPage,
              duration: widget.style.pageStepDuration,
              curve: widget.style.pageStepCurve,
            ),
        ],
      ),
    );
  }

  Widget _buildBodyVerticalDragAble(
    BuildContext context,
    int value,
    Widget? child,
  ) => _TableCalendarVerticalDrag(
    currentIndex: value,
    maxIndex: widget.style.availableWeeksPerPage.length - 1,
    onNextFormatIndex: _updateFormatIndex,
    child: child,
  );

  ///
  ///
  ///
  Widget _layout(BuildContext context, BoxConstraints constraints) {
    _constraintsBody = constraints;
    return ValueListenableBuilder<double>(
      valueListenable: _pageHeight,
      builder: _buildPage,
      child: PageView.builder(
        onPageChanged: _layoutPageOnChange,
        controller: _pageController,
        physics: widget.style.horizontalScroll,
        itemCount: _indexEnd,
        itemBuilder: _builderPageItem(),
      ),
    );
  }

  Widget _layoutDragAble(BuildContext context, BoxConstraints constraints) =>
      ValueListenableBuilder<int>(
        valueListenable: _indexWeeksPerPage,
        builder: _buildBodyVerticalDragAble,
        child: _layout(context, constraints),
      );

  @override
  Widget build(BuildContext context) {
    final styleHeader = widget.styleHeader;
    final style = widget.style;
    return Column(
      children: [
        if (styleHeader != null) buildHeader(context, styleHeader),
        Flexible(
          flex: style.verticalFlex,
          child: LayoutBuilder(
            builder: style.verticalScrollAble ? _layoutDragAble : _layout,
          ),
        ),
      ],
    );
  }
}

///
///
///
class _TableCalendarVerticalDrag extends StatefulWidget {
  const _TableCalendarVerticalDrag({
    required this.currentIndex,
    required this.maxIndex,
    required this.onNextFormatIndex,
    required this.child,
  });

  final ValueChanged<int> onNextFormatIndex;
  final int currentIndex;
  final int maxIndex;
  final Widget? child;

  @override
  State<_TableCalendarVerticalDrag> createState() =>
      _TableCalendarVerticalDragState();
}

class _TableCalendarVerticalDragState extends State<_TableCalendarVerticalDrag>
    with GestureDetectorDragMixin<_TableCalendarVerticalDrag> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onVerticalDragStart: onDragStart,
      onVerticalDragUpdate: onDragUpdateFrom(),
      onVerticalDragEnd: onDragEndFrom(
        difference: OffsetExtension.differenceVertical,
        threshold: 25.0,
        direction: DirectionIn4.verticalForward,
        onDrag: FValueChanged.indexingByVerticalDrag(
          onIndex: widget.onNextFormatIndex,
          currentIndex: widget.currentIndex,
          maxIndex: widget.maxIndex,
        ),
      ),
      child: widget.child,
    );
  }
}

///
///
///
class _TableCalendarRange extends StatefulWidget {
  const _TableCalendarRange({
    required this.style,
    required this.styleCellRange,
    required this.constraints,
    required this.range,
  });

  final CalendarStyle style;
  final CalendarStyleCellRange styleCellRange;
  final BoxConstraints constraints;
  final ValueNotifier<(DateTime?, DateTime?)> range;

  @override
  State<_TableCalendarRange> createState() => _TableCalendarRangeState();
}

class _TableCalendarRangeState extends State<_TableCalendarRange> {
  DateTime? rangeStart;
  DateTime? rangeEnd;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
