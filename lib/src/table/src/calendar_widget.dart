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
  final DateTime? initialFocusedDate;
  final int initialWeeksPerPage;

  ///
  ///
  ///
  final CalendarStyle style;
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
    this.initialWeeksPerPage = CalendarStyle.weeksPerPage_6,
    this.style = const CalendarStyle(),
    this.eventsLayoutMark,
    this.eventLayoutSingleMark,
    this.eventLoader,
    this.customMark,

    // this.rangeSelectionMode = RangeSelectionMode.toggledOff,
  }) : initialFocusedDate = focusedDate,
       assert(style.formatAvailables.contains(initialWeeksPerPage)),
       assert(
         style.formatAvailables.length <= CalendarStyle.weeksPerPage_all.length,
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
}

///
///
///
class _CalendarState<T> extends State<Calendar<T>> {
  late CalendarStyle _style;
  late final CalendarCellConfiguration _configuration;
  late final PageController _pageController;
  late final ValueNotifier<double> _pageHeight;
  late final ValueNotifier<int> _weeksPerPage;

  // late RangeSelectionMode _rangeSelectionMode;
  // DateTime? _selectedDate;
  late final int _indexEnd;
  late int _indexPrevious;

  // late bool _pageCallbackDisabled;
  late DateTimeRange _domain;
  late DateTime _focusedDate;
  late CalendarRowsGenerator _rowGenerator;
  late CellPlan _cellPlan;
  BoxConstraints? _constraintsBody;

  ///
  ///
  ///
  static int _pageIndexOf(DateTime start, DateTime target, int weeksPerPage) =>
      (target.difference(start).inDays + 1) ~/
      (DateTime.daysPerWeek * weeksPerPage);

  static bool _predicateToday(DateTime date) => date.isSameDate(DateTime.now());

  bool _predicateSelected(DateTime date) => date.isSameDate(_focusedDate);

  bool _predicateOutside(DateTime date) => date.month != _focusedDate.month;

  @override
  void dispose() {
    _pageController.dispose();
    _pageHeight.dispose();
    _weeksPerPage.dispose();
    // _focusedDate.dispose();
    super.dispose();
  }

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    final style = widget.style;
    final focusedDate = widget.initialFocusedDate ?? DateTime.now();
    final domain = style.domain(focusedDate);
    _style = style;
    _domain = domain;
    _focusedDate = focusedDate;

    final wPP = widget.initialWeeksPerPage;
    final indexInitial = _pageIndexOf(domain.start, focusedDate, wPP);
    _indexPrevious = indexInitial;
    _indexEnd = _pageIndexOf(domain.start, domain.end, wPP);
    _weeksPerPage = ValueNotifier(wPP);

    // _rangeSelectionMode = widget.rangeSelectionMode;
    _pageHeight = ValueNotifier(double.infinity);
    _pageController = PageController(initialPage: indexInitial);
    // _pageCallbackDisabled = false;

    _cellPlan = _style._cellPlanFrom(
      focusedDate: focusedDate,
      locale: widget.locale,
      eventLoader: widget.eventLoader,
      eventsLayoutMark: widget.eventsLayoutMark,
      eventLayoutSingleMark: widget.eventLayoutSingleMark,
      customMark: widget.customMark,
    );
    _configuration = {
      CalendarCellType.disabled: style.predicateDisable,
      CalendarCellType.holiday: style.predicateHoliday,
      CalendarCellType.weekend: style.predicateWeekend,
      CalendarCellType.weekday: style.predicateWeekday,
      CalendarCellType.focused: _predicateSelected,
      CalendarCellType.outside: _predicateOutside,
      CalendarCellType.today: _predicateToday,
    };
    style.onCalendarCreated?.call(_pageController);
  }

  ///
  ///
  ///
  void _updatePage(bool shouldAnimate) {
    final indexCurrent = _pageIndexOf(
      _domain.start,
      _focusedDate,
      _weeksPerPage.value,
    );

    if (indexCurrent != _indexPrevious ||
        indexCurrent == 0 ||
        indexCurrent == _indexEnd) {
      // _pageCallbackDisabled = true;
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
    // _pageCallbackDisabled = false;
  }

  @override
  void didUpdateWidget(Calendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final style = widget.style;
    if (style != oldWidget.style) {
      // TODO: update entire calendar style by updating widget
      _style = style;
    }
    if (_focusedDate != widget.initialFocusedDate || style != oldWidget.style) {
      _focusedDate = widget.initialFocusedDate ?? DateTime.now();
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
  void _updateFocusedDate(DateTime date) {
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

  void _onDateTapped(DateTime date) {
    if (date == _focusedDate) {
      final style = _style;
      if (style.pageJumpingEnabled) {
        _focusedDate = date;
        setState(() {});
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
      return;
    }
    _updateFocusedDate(date);
  }

  void _onDateLongPressed(DateTime date) {
    final style = _style;
    if (style.onDateLongPressed != null) {
      _updateFocusedDate(date);
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
  DateTime Function(int days) get _pagingFirstDate {
    final style = _style;
    final wPP = _weeksPerPage.value;
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
    // if (!_pageCallbackDisabled) {
    //   final style = _style;
    //   final next =
    //       index == _indexPrevious
    //           ? _focusedDate
    //           : _pagingFirstDate(
    //             (index - _indexPrevious) *
    //                 DateTime.daysPerWeek *
    //                 _weeksPerPage.value,
    //           );
    //
    //   if (!_focusedDate.isSameDate(next)) {
    //     _focusedDate = next;
    //   }
    //   _indexPrevious = index;
    //   style.onPageChanged?.call(index, next);
    // }
    // _pageCallbackDisabled = false;
  }

  Predicator<DateTime> get predicateBlock {
    final domain = widget.style.domain(widget.initialFocusedDate);
    return (date) => date.isBefore(domain.start) || date.isAfter(domain.end);
  }

  ///
  /// [index] has been ensured to be a valid index
  ///
  void _updateFormatIndex(int index) {
    final style = widget.style;
    final weeksPerPage = style.formatAvailables[index];
    if (weeksPerPage == _weeksPerPage.value) return;
    _weeksPerPage.value = weeksPerPage;
    _pageHeight.value = _constraintsBody!.maxHeight;
    style.formatOnChanged?.call(weeksPerPage);
  }

  ///
  /// TODO: enable format button
  ///
  Widget buildHeader(BuildContext context, CalendarStyleHeader style) {
    final buildFormatButton = style.styleFormatButton?.buildFrom(
      widget.style,
      _weeksPerPage,
      _updateFormatIndex,
    );
    final buildChevron = style.styleChevrons?.buildFrom;
    return Container(
      decoration: style.decoration,
      margin: style.margin,
      padding: style.padding,
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
    maxIndex: _style.formatAvailables.length - 1,
    onNextFormatIndex: _updateFormatIndex,
    child: child,
  );

  ///
  ///
  ///
  Widget _layout(BuildContext context, BoxConstraints constraints) {
    final style = _style;
    final weeksPerPage = _weeksPerPage.value;
    if (_constraintsBody != constraints) {
      _constraintsBody = constraints;
      _rowGenerator = style._rowGeneratorFrom(
        widget.locale,
        (constraints.maxHeight - style.pageHeightWithoutBody) / weeksPerPage,
        predicateBlock,
      );
    }
    final table = style._table;
    final rows = _rowGenerator;
    final paging = _pagingFirstDate;
    final datesPerPage = weeksPerPage * DateTime.daysPerWeek;
    List<DateTime> datesFrom(int index) =>
        paging(datesPerPage * index).datesFromNowTo(datesPerPage);
    final cellBuilder = style._dateBuilderFrom(
      onTap: _onDateTapped,
      onLongPress: _onDateLongPressed,
      locale: widget.locale,
      configuration: _configuration,
      predicateBlock: predicateBlock,
      focusedDate: _focusedDate,
      plan: _cellPlan,
    );

    return ValueListenableBuilder<double>(
      valueListenable: _pageHeight,
      builder: style._pageBuilder,
      child: PageView.builder(
        onPageChanged: _layoutPageOnChange,
        controller: _pageController,
        physics: widget.style.horizontalScroll,
        itemCount: _indexEnd,
        itemBuilder:
            (context, i) => table(rows(datesFrom(i..printThis()), cellBuilder)),
      ),
    );
  }

  Widget _layoutDragAble(BuildContext context, BoxConstraints constraints) =>
      ValueListenableBuilder<int>(
        valueListenable: _weeksPerPage,
        builder: _buildBodyVerticalDragAble,
        child: _layout(context, constraints),
      );

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final styleHeader = style.styleHeader;
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
