part of '../table_calendar.dart';

///
///
/// [Calendar]
/// [_TableCalendarVerticalDrag]
///
///
class Calendar<T> extends StatefulWidget {
  final dynamic locale;
  final DateTimeRange domain;
  final DateTime focusedDate;
  final DateTime? currentDate;
  final bool pageJumpingEnabled;
  final bool pageAnimationEnabled;
  final Duration formatAnimationDuration;
  final Curve formatAnimationCurve;
  final HitTestBehavior dayHitTestBehavior;

  ///
  ///
  ///
  final CalendarStyle style;
  final StyleHeader? styleHeader;
  final EventsLayoutMark<T>? _eventsLayoutMark;
  final EventMark<T>? _eventMark;
  final List<T> Function(DateTime day)? eventLoader;

  ///
  ///
  ///
  final RangeSelectionMode rangeSelectionMode;
  final bool Function(DateTime day)? enabledDayPredicate;
  final Predicator<DateTime> predicateSelect;
  final Predicator<DateTime> predicateHoliday;
  final OnRangeSelected? onRangeSelected;
  final OnDaySelected? onDaySelected;
  final OnDaySelected? onDayLongPressed;
  final OnPageChanged? onPageChanged;
  final void Function(DateTime date)? onDisabledDayTapped;
  final void Function(DateTime date)? onDisabledDayLongPressed;
  final void Function(PageController pageController)? onCalendarCreated;

  Calendar({
    super.key,
    required DateTime focusedDay,
    required DateTime firstDay,
    required DateTime lastDay,
    DateTime? currentDay,
    this.locale,
    this.pageJumpingEnabled = false,
    this.pageAnimationEnabled = true,
    this.formatAnimationDuration = DurationExtension.milli200,
    this.formatAnimationCurve = Curves.linear,
    this.dayHitTestBehavior = HitTestBehavior.opaque,

    ///
    ///
    ///
    this.style = const CalendarStyle(),
    this.styleHeader = const StyleHeader(),
    EventsLayoutMark<T>? eventsLayoutMark,
    EventMark<T>? eventMark,

    ///
    ///
    ///
    this.rangeSelectionMode = RangeSelectionMode.toggledOff,
    this.eventLoader,
    this.enabledDayPredicate,
    this.predicateSelect = _datePredicateFalse,
    this.predicateHoliday = _datePredicateFalse,
    this.onRangeSelected,
    this.onDaySelected,
    this.onDayLongPressed,
    this.onDisabledDayTapped,
    this.onDisabledDayLongPressed,
    this.onPageChanged,
    this.onCalendarCreated,
  }) : _eventsLayoutMark = eventsLayoutMark,
       _eventMark = eventMark,
       assert(style.availableWeeksPerPage.contains(style.initialWeeksPerPage)),
       assert(
         style.availableWeeksPerPage.length <=
             CalendarStyle.weeksPerPage_all.length,
       ),
       assert(
         dm.DateTimeExtension.predicateAfter(focusedDay, firstDay, true),
         'focusedDay($focusedDay) must be after firstDay($firstDay)',
       ),
       assert(
         dm.DateTimeExtension.predicateBefore(focusedDay, lastDay, true),
         'focusedDay($focusedDay) must be after lastDay($lastDay)',
       ),
       focusedDate = dm.DateTimeExtension.normalizeDate(focusedDay),
       domain = DateTimeRange(
         start: dm.DateTimeExtension.normalizeDate(firstDay),
         end: dm.DateTimeExtension.normalizeDate(lastDay),
       ),
       currentDate = currentDay ?? DateTime.now();

  static bool _datePredicateFalse(DateTime date) => false;

  @override
  State<Calendar<T>> createState() => _CalendarState<T>();

  EventsLayoutMark<T> get eventsLayoutMark =>
      _eventsLayoutMark ?? CalendarStyleCellMark._eventsAsPositionedRow<T>;

  EventMark<T> get eventMark =>
      _eventMark ?? CalendarStyleCellMark._singleDecoration<T>;
}

///
///
///
class _CalendarState<T> extends State<Calendar<T>> {
  late final PageController _pageController;
  late final ValueNotifier<double> _height;
  late final ValueNotifier<DateTime> _focusedDate;
  late RangeSelectionMode _rangeSelectionMode;
  DateTime? rangeStart;
  DateTime? rangeEnd;

  ///
  ///
  ///
  late bool _pageCallbackDisabled;
  late int _previousIndex;
  late final int _endIndex;
  late ValueNotifier<int> _indexFormat;
  DateTime? _firstSelectedDay;

  @override
  void dispose() {
    _focusedDate.dispose();
    _pageController.dispose();
    _height.dispose();
    super.dispose();
  }

  ///
  ///
  ///
  int _focusedPageIndex(DateTime from, DateTime target) =>
      DateTimeRangeExtension.scopesOf(
        DateTimeRange(start: from, end: target),
        widget.style.startingWeekday,
        DateTime.daysPerWeek * widget.style.initialWeeksPerPage,
      );

  double _getPageHeight([BoxConstraints? constraints]) {
    final style = widget.style;
    final height =
        (style.styleDayOfWeek?.height ?? 0.0) +
        style.initialWeeksPerPage * style.rowHeight +
        (style.tablePadding.vertical);
    if (constraints == null) return height;
    return constraints.hasBoundedHeight ? constraints.maxHeight : height;
  }

  @override
  void initState() {
    super.initState();
    final focusedDay = widget.focusedDate;
    _focusedDate = ValueNotifier(focusedDay);
    final initialPage = _focusedPageIndex(widget.domain.start, focusedDay);
    _previousIndex = initialPage;
    _endIndex = _focusedPageIndex(widget.domain.start, widget.domain.end);

    final style = widget.style;
    _indexFormat = ValueNotifier(
      style.availableWeeksPerPage.indexOf(style.initialWeeksPerPage),
    );
    _rangeSelectionMode = widget.rangeSelectionMode;
    _height = ValueNotifier(_getPageHeight());
    _pageController = PageController(initialPage: initialPage);
    _pageCallbackDisabled = false;

    widget.onCalendarCreated?.call(_pageController);
  }

  ///
  ///
  ///
  void _updatePage(bool shouldAnimate) {
    final currentIndex = _focusedPageIndex(
      widget.domain.start,
      _focusedDate.value,
    );

    if (currentIndex != _previousIndex ||
        currentIndex == 0 ||
        currentIndex == _endIndex) {
      _pageCallbackDisabled = true;
    }

    if (shouldAnimate) {
      if ((currentIndex - _previousIndex).abs() > 1) {
        _pageController.jumpToPage(
          currentIndex > _previousIndex ? currentIndex - 1 : currentIndex + 1,
        );
      }

      final style = widget.style;
      _pageController.animateToPage(
        currentIndex,
        duration: style.pageStepDuration,
        curve: style.pageStepCurve,
      );
    } else {
      _pageController.jumpToPage(currentIndex);
    }

    _previousIndex = currentIndex;
    _height.value = _getPageHeight();
    _pageCallbackDisabled = false;
  }

  @override
  void didUpdateWidget(Calendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldUpdate = _focusedDate.value != widget.focusedDate;
    final style = widget.style;
    final styleOld = oldWidget.style;
    if (shouldUpdate ||
        style.initialWeeksPerPage != styleOld.initialWeeksPerPage ||
        style.startingWeekday != styleOld.startingWeekday) {
      _focusedDate.value = widget.focusedDate;
      _updatePage(widget.pageAnimationEnabled && shouldUpdate);
    }

    if (style.rowHeight != styleOld.rowHeight ||
        style.styleDayOfWeek?.height != styleOld.styleDayOfWeek?.height) {
      _height.value = _getPageHeight();
    }

    if (_rangeSelectionMode != widget.rangeSelectionMode) {
      _rangeSelectionMode = widget.rangeSelectionMode;
    }

    if (rangeStart == null && rangeEnd == null) {
      _firstSelectedDay = null;
    }
  }

  ///
  ///
  ///
  bool get _shouldBlockOutsideDays =>
      widget.style.outsideDecoration == null &&
      widget.style.initialWeeksPerPage == 6;

  bool _isDayDisabled(DateTime day) {
    if (day.isBefore(widget.domain.start)) return true;
    if (day.isAfter(widget.domain.end)) return true;
    final enable = widget.enabledDayPredicate;
    if (enable == null) return false;
    return !enable(day);
  }

  ///
  ///
  ///
  void _onDateTapped(DateTime date) {
    final isOutside = date.month != _focusedDate.value.month;
    if (isOutside && _shouldBlockOutsideDays) return;
    if (_isDayDisabled(date)) return widget.onDisabledDayTapped?.call(date);

    _updateFocusOnTap(date);

    if (_rangeSelectionMode.isSelectionOn && widget.onRangeSelected != null) {
      if (_firstSelectedDay == null) {
        _firstSelectedDay = date;
        widget.onRangeSelected!(_firstSelectedDay, null, _focusedDate.value);
      } else {
        if (date.isAfter(_firstSelectedDay!)) {
          widget.onRangeSelected!(_firstSelectedDay, date, _focusedDate.value);
          _firstSelectedDay = null;
        } else if (date.isBefore(_firstSelectedDay!)) {
          widget.onRangeSelected!(date, _firstSelectedDay, _focusedDate.value);
          _firstSelectedDay = null;
        }
      }
    } else {
      widget.onDaySelected?.call(date, _focusedDate.value);
    }
  }

  void _onDateLongPressed(DateTime date) {
    final isOutside = date.month != _focusedDate.value.month;
    if (isOutside && _shouldBlockOutsideDays) return;

    if (_isDayDisabled(date)) {
      return widget.onDisabledDayLongPressed?.call(date);
    }

    if (widget.onDayLongPressed != null) {
      _updateFocusOnTap(date);
      return widget.onDayLongPressed!(date, _focusedDate.value);
    }

    if (widget.onRangeSelected != null) {
      if (_rangeSelectionMode.isToggleAble) {
        _updateFocusOnTap(date);
        _rangeSelectionMode =
            _rangeSelectionMode == RangeSelectionMode.toggledOn
                ? RangeSelectionMode.toggledOff
                : RangeSelectionMode.toggledOn;

        if (_rangeSelectionMode.isSelectionOn) {
          _firstSelectedDay = date;
          widget.onRangeSelected!(_firstSelectedDay, null, _focusedDate.value);
        } else {
          _firstSelectedDay = null;
          widget.onDaySelected?.call(date, _focusedDate.value);
        }
      }
    }
  }

  ///
  ///
  ///
  void _updateFocusOnTap(DateTime day) {
    if (widget.pageJumpingEnabled) {
      _focusedDate.value = day;
      return;
    }

    if (widget.style.initialWeeksPerPage == 6) {
      if (dm.DateTimeExtension.predicateBeforeMonth(day, _focusedDate.value)) {
        _focusedDate.value = dm.DateTimeExtension.firstDateOfMonth(
          _focusedDate.value,
        );
      } else if (dm.DateTimeExtension.predicateAfterMonth(
        day,
        _focusedDate.value,
      )) {
        _focusedDate.value = dm.DateTimeExtension.lastDateOfMonth(
          _focusedDate.value,
        );
      } else {
        _focusedDate.value = day;
      }
    } else {
      _focusedDate.value = day;
    }
  }

  ///
  ///
  ///
  ConstraintsBuilder? _builderMarks(DateTime date) {
    final events = widget.eventLoader?.call(date);
    if (events == null) return null;
    final styleMark = widget.style.styleMark;
    if (styleMark == null) return null;
    return (context, constraints) =>
        widget.eventsLayoutMark(constraints, styleMark)(
          date,
          events,
          widget.eventMark(constraints, styleMark),
        )!;
  }

  ConstraintsBuilder? _builderHighlightRange(DateTime date) {
    final rangeStart = this.rangeStart;
    if (rangeStart == null) return null;
    if (date.isBefore(rangeStart)) return null;
    if (date.isAfter(rangeStart)) {
      final rangeEnd = this.rangeEnd;
      if (rangeEnd == null) return null;
      if (date.isAfter(rangeEnd)) return null;
      if (date.isBefore(rangeEnd)) {
        return (_, c) =>
            widget.style.builderHighlightRange(date, RangeState.within, c);
      }
      return (_, c) =>
          widget.style.builderHighlightRange(date, RangeState.onEnd, c);
    }
    return (_, c) =>
        widget.style.builderHighlightRange(date, RangeState.onStart, c);
  }

  ///
  /// TODO: enable rangeStart, rangeEnd
  ///
  Widget _layoutCell({
    required DateTime date,
    required CellBuilder builder,
    required ConstraintsBuilder? builderMarks,
    required ConstraintsBuilder? buildHighlight,
  }) => LayoutBuilder(
    builder:
        (context, constraints) => Stack(
          alignment: widget.style.cellStackAlignment,
          clipBehavior: widget.style.cellStackClip,
          children: [
            if (buildHighlight != null) buildHighlight(context, constraints),
            Semantics(
              key: ValueKey('Cell-${date.year}-${date.month}-${date.day}'),
              label:
                  '${DateFormat.EEEE(widget.locale).format(date)}, '
                  '${DateFormat.yMMMMd(widget.locale).format(date)}',
              excludeSemantics: true,
              child: builder(date, _focusedDate.value, widget.locale),
            ),
            if (builderMarks != null) builderMarks(context, constraints),
          ],
        ),
  );

  Widget _activeCell({required DateTime date, required Widget child}) =>
      GestureDetector(
        behavior: widget.dayHitTestBehavior,
        onTap: () => _onDateTapped(date),
        onLongPress: () => _onDateLongPressed(date),
        child: child,
      );

  ///
  ///
  ///
  Widget _dateBuilder(DateTime date) {
    final style = widget.style;
    final isOutside = date.month != _focusedDate.value.month;

    // blocked
    if (isOutside && _shouldBlockOutsideDays) return Container();

    // disabled
    if (_isDayDisabled(date)) {
      return _layoutCell(
        date: date,
        builder: style.builderDisabled,
        builderMarks:
            (style.styleMark?.forDisabledCell ?? false)
                ? _builderMarks(date)
                : null,
        buildHighlight: _builderHighlightRange(date),
      );
    }

    late final CellBuilder builder;
    // selected
    if (widget.predicateSelect(date)) {
      builder = style.builderSelected;

      // outside
    } else if (isOutside) {
      builder = style.builderOutside;

      // today
    } else if (DateTimeExtension.predicateSameDate(date, widget.currentDate)) {
      builder = style.builderToday;

      // holiday
    } else if (widget.predicateHoliday(date)) {
      builder = style.builderHoliday;

      // weekend
    } else if (style.weekendDays.contains(date.weekday)) {
      builder = style.builderWeekend;

      // weekday
    } else {
      builder = style.builderWeekday;
    }

    return _activeCell(
      date: date,
      child: _layoutCell(
        date: date,
        builder: builder,
        builderMarks: _builderMarks(date),
        buildHighlight: _builderHighlightRange(date),
      ),
    );
  }

  ///
  ///
  ///
  ValueChanged<int> _layoutPageOnChange(BoxConstraints constraints) => (index) {
    if (!_pageCallbackDisabled) {
      final style = widget.style;
      final next =
          index == _previousIndex
              ? _focusedDate.value
              : dm.DateTimeExtension.clamp(
                style._paging(_indexFormat.value)(
                  _focusedDate.value,
                  index - _previousIndex,
                ),
                widget.domain.start,
                widget.domain.end,
              );

      if (!DateTimeExtension.predicateSameDate(_focusedDate.value, next)) {
        _focusedDate.value = next;
      }
      _height.value = _getPageHeight(constraints);
      _previousIndex = index;
      widget.onPageChanged?.call(index, next);
    }

    _pageCallbackDisabled = false;
  };

  Widget _buildPage(BuildContext context, double value, Widget? child) =>
      AnimatedSize(
        duration: widget.formatAnimationDuration,
        curve: widget.formatAnimationCurve,
        alignment: Alignment.topCenter,
        child: SizedBox(height: value, child: child),
      );

  ///
  ///
  ///
  double? _heightPageRow(BoxConstraints constraints) {
    final style = widget.style;
    return constraints.hasBoundedHeight
        ? (constraints.maxHeight - (style.styleDayOfWeek?.height ?? 0.0)) /
            style.initialWeeksPerPage
        : style.rowHeight;
  }

  NullableIndexedWidgetBuilder _builderPageItem(BoxConstraints constraints) => (
    BuildContext context,
    int index,
  ) {
    final style = widget.style;
    final dates = DateTimeRangeExtension.datesIn(
      DateTimeRangeExtension.weeksFrom(
        dm.DateTimeExtension.clamp(
          style._paging(_indexFormat.value)(widget.domain.start, index),
          widget.domain.start,
          widget.domain.end,
        ),
        count: style.initialWeeksPerPage,
      ),
    );
    final weekNumber = style.styleWeekNumber?.build(
      dates,
      _heightPageRow(constraints),
    );
    final daysOfWeek = style.styleDayOfWeek?.buildTableRow(
      style: style,
      days: dates,
      date: _focusedDate.value,
      locale: widget.locale,
    );

    return Padding(
      padding: style.tablePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (weekNumber != null) weekNumber,
          Expanded(
            child: Table(
              border: style.tableBorder,
              children: [
                if (daysOfWeek != null) daysOfWeek,
                ...List.generate(
                  dates.length ~/ DateTime.daysPerWeek,
                  (index) => TableRow(
                    decoration: style.rowDecoration,
                    children: List.generate(
                      DateTime.daysPerWeek,
                      (id) => SizedBox(
                        height: _heightPageRow(constraints),
                        child: _dateBuilder(
                          dates[index * DateTime.daysPerWeek + id],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  };

  ///
  ///
  ///
  Widget buildHeader(BuildContext context, StyleHeader style) {
    final buildFormatButton = style.styleFormatButton?.buildFrom(
      widget.style,
      _indexFormat,
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
          style.buildTitle(_focusedDate.value, widget.locale),
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
    onNextFormatIndex: (index) {
      if (index == _indexFormat.value) return;
      final style = widget.style;
      style.onFormatChanged?.call(style.availableWeeksPerPage[index]);
      _indexFormat.value = index;
    },
    child: child,
  );

  ///
  ///
  ///
  Widget _layout(BuildContext context, BoxConstraints constraints) {
    final style = widget.style;
    return ValueListenableBuilder<double>(
      valueListenable: _height,
      builder: _buildPage,
      child: PageView.builder(
        onPageChanged: _layoutPageOnChange(constraints),
        controller: _pageController,
        physics: style.horizontalScroll,
        itemCount: DateTimeRangeExtension.scopesOf(
          widget.domain,
          style.startingWeekday,
          DateTime.daysPerWeek * style.weeksPerPage(_indexFormat.value),
        ),
        itemBuilder: _builderPageItem(constraints),
      ),
    );
  }

  Widget _layoutDragAble(BuildContext context, BoxConstraints constraints) =>
      ValueListenableBuilder<int>(
        valueListenable: _indexFormat,
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
        difference: GestureDetectorDragMixin.verticalDifference,
        threshold: 25.0,
        direction: GestureDetectorDragMixin.verticalForward,
        onDrag: GestureDetectorDragMixin.indexingByVerticalDrag(
          onIndex: widget.onNextFormatIndex,
          currentIndex: widget.currentIndex,
          maxIndex: widget.maxIndex,
        ),
      ),
      child: widget.child,
    );
  }
}
