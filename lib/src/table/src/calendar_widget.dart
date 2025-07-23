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
  final int weeksPerPage;

  ///
  ///
  ///
  final CalendarStyle style;
  final CalendarStyleHeader? styleHeader;
  final EventsLayoutMark<T>? eventsLayoutMark;
  final EventElementMark<T>? eventLayoutSingleMark;
  final EventLoader<T>? eventLoader;
  final MarkConfiguration<T>? customMark;

  ///
  ///
  ///
  // final RangeSelectionMode rangeSelectionMode;

  Calendar({
    super.key,
    DateTime? focusedDate,
    this.locale,
    this.weeksPerPage = CalendarStyle.weeksPerPage_6,
    this.style = const CalendarStyle(),
    this.styleHeader = const CalendarStyleHeader(),
    this.eventsLayoutMark,
    this.eventLayoutSingleMark,
    this.eventLoader,
    this.customMark,

    // this.rangeSelectionMode = RangeSelectionMode.toggledOff,
  }) : _focusedDate = focusedDate,
       assert(style.availableWeeksPerPage.contains(weeksPerPage)),
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

  DateTime get focusedDate => _focusedDate ?? DateTime.now();
}

///
///
///
class _CalendarState<T> extends State<Calendar<T>> {
  late CalendarStyle _style;
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
    final style = widget.style;
    final focusedDate = widget.focusedDate;
    final domain = style.domain(focusedDate);
    _style = style;
    _domain = domain;
    _focusedDate = focusedDate;

    final wPP = widget.weeksPerPage;
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
      CalendarCellType.disabled: (style.predicateDisable, style.buildDisabled),
      CalendarCellType.holiday: (style.predicateHoliday, style.buildHoliday),
      CalendarCellType.weekend: (style.predicateWeekend, style.buildWeekend),
      CalendarCellType.weekday: (style.predicateWeekday, style.buildWeekday),
      CalendarCellType.selected: (_predicateSelected, style.buildSelected),
      CalendarCellType.outside: (_predicateOutside, style.buildOutside),
      CalendarCellType.today: (_predicateToday, style.buildToday),
    };

    style.onCalendarCreated?.call(_pageController);
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
    final style = widget.style;
    if (style != oldWidget.style) {
      _style = style;
    }
    if (_focusedDate != widget.focusedDate || style != oldWidget.style) {
      _focusedDate = widget.focusedDate;
      _updatePage(style.pageAnimationEnabled);
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
    final style = _style;
    if (style.predicateDisable(date)) {
      return style.onDisabledDayTapped?.call(date);
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
    final style = _style;
    if (style.predicateDisable(date)) {
      return style.onDisabledDayLongPressed?.call(date);
    }

    if (style.onDateLongPressed != null) {
      _updateFocusOnTap(date);
      return style.onDateLongPressed!(date, _focusedDate);
    }

    if (style.onRangeSelected != null) {
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
    final style = _style;
    if (style.pageJumpingEnabled) {
      _focusedDate = date;
      setState(() {});
      // TODO: instead of setState, using ValueListenableBuilder
      return;
    }

    final focusedDate = _focusedDate;
    if (widget.weeksPerPage == CalendarStyle.weeksPerPage_6) {
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
  bool _predicateToday(DateTime date) => date.isSameDate(DateTime.now());

  bool _predicateSelected(DateTime date) => date.isSameDate(_focusedDate);

  bool _predicateOutside(DateTime date) => date.month != _focusedDate.month;

  ///
  ///
  ///
  DateTime Function(int days) get _paging {
    final style = _style;
    final wPP = style.availableWeeksPerPage[_indexWeeksPerPage.value];
    late final DateTime domainStart;
    late final DateTime domainEnd;
    final domain = _domain;
    if (wPP == CalendarStyle.weeksPerPage_6) {
      domainStart = domain.start.firstDateOfMonth.firstDateOfWeek(
        style.startingWeekday,
      );
      domainEnd = domain.end.firstDateOfMonth.firstDateOfWeek(
        style.startingWeekday,
      );
    } else {
      throw UnimplementedError();
    }
    return (days) {
      final date = DateTime(
        domainStart.year,
        domainStart.month,
        domainStart.day + days,
      );
      return date.isAfter(domainEnd) ? domainEnd : date;
    };
  }

  void _layoutPageOnChange(int index) {
    if (!_pageCallbackDisabled) {
      final style = _style;
      final next =
          index == _indexPrevious
              ? _focusedDate
              : _paging(
                (index - _indexPrevious) *
                    DateTime.daysPerWeek *
                    style.availableWeeksPerPage[_indexWeeksPerPage.value],
              );

      if (!_focusedDate.isSameDate(next)) {
        _focusedDate = next;
      }
      _indexPrevious = index;
      style.onPageChanged?.call(index, next);
    }

    _pageCallbackDisabled = false;
  }

  BoxConstraints? _constraintsBody;

  double get heightRow {
    final style = _style;
    return (_constraintsBody!.maxHeight -
            style.tablePadding.vertical -
            (style.styleDayOfWeek?.height ?? 0.0)) /
        style.availableWeeksPerPage[_indexWeeksPerPage.value];
  }

  Predicator<DateTime> get predicateBlock {
    final domain = widget.style.domain(widget.focusedDate);
    return (date) => date.isBefore(domain.start) || date.isAfter(domain.end);
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

  ///
  /// TODO: enable format button
  ///
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

  ///
  /// TODO: has weekNumber -> vertical dragAble to switch page
  ///
  Widget _buildBodyVerticalDragAble(
    BuildContext context,
    int value,
    Widget? child,
  ) => _TableCalendarVerticalDrag(
    currentIndex: value,
    maxIndex: _style.availableWeeksPerPage.length - 1,
    onNextFormatIndex: _updateFormatIndex,
    child: child,
  );

  ///
  ///
  ///
  Widget _layout(BuildContext context, BoxConstraints constraints) {
    _constraintsBody = constraints;
    final style = _style;
    final table = style._tableFrom(
      style._cellFrom(
        configuration: _configuration,
        onTap: _onDateTapped,
        onLongPress: _onDateLongPressed,
        buildMarks: style.styleCellMark?.builderFrom(
          eventLoader: widget.eventLoader,
          layoutAll: widget.eventsLayoutMark,
          layoutElement: widget.eventLayoutSingleMark,
          customMark: widget.customMark,
        ),
        buildRangeHighlight: style.styleCellRangeHighlight?.builderFrom(
          style: style,
          isBackground: true,
        ),
      ),
      locale: widget.locale,
      heightRow: heightRow,
      predicateBlock: predicateBlock,
      focusedDate: _focusedDate,
      constraints: constraints,
    );

    final paging = _paging;
    final dPP =
        DateTime.daysPerWeek *
        style.availableWeeksPerPage[_indexWeeksPerPage.value];
    return ValueListenableBuilder<double>(
      valueListenable: _pageHeight,
      builder: style._buildPage,
      child: PageView.builder(
        onPageChanged: _layoutPageOnChange,
        controller: _pageController,
        physics: widget.style.horizontalScroll,
        itemCount: _indexEnd,
        itemBuilder: (_, i) => table(paging(dPP * i).datesFromNow(dPP)),
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
