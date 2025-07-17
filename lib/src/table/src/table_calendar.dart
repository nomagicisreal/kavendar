part of '../table_calendar.dart';

///
///
/// [TableCalendar]
/// [_TableCalendarVerticalDrag]
///
///
class TableCalendar<T> extends StatefulWidget {
  final dynamic locale;
  final DateTimeRange domain;
  final DateTime focusedDay;
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
  final CalendarStyleDayOfWeek? styleDayOfWeek;
  final CalendarStyleWeekNumber? styleWeekNumbers;
  final CalendarStyleHeader? styleHeader;
  final CalendarStyleCellMark? styleMark;
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

  TableCalendar({
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
    this.styleDayOfWeek = const CalendarStyleDayOfWeek(),
    this.styleWeekNumbers = const CalendarStyleWeekNumber(),
    this.styleHeader = const CalendarStyleHeader(),
    this.styleMark = const CalendarStyleCellMark(),
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
       assert(style.availableWeeksPerPage.contains(style.weeksPerPage)),
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
       focusedDay = dm.DateTimeExtension.normalizeDate(focusedDay),
       domain = DateTimeRange(
         start: dm.DateTimeExtension.normalizeDate(firstDay),
         end: dm.DateTimeExtension.normalizeDate(lastDay),
       ),
       currentDate = currentDay ?? DateTime.now();

  static bool _datePredicateFalse(DateTime date) => false;

  @override
  State<TableCalendar<T>> createState() => _TableCalendarState<T>();

  EventsLayoutMark<T> get eventsLayoutMark =>
      _eventsLayoutMark ?? CalendarStyleCellMark._eventsAsPositionedRow<T>;

  EventMark<T> get eventMark =>
      _eventMark ?? CalendarStyleCellMark._singleDecoration<T>;
}

///
///
///
class _TableCalendarState<T> extends State<TableCalendar<T>> {
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
        DateTime.daysPerWeek * widget.style.weeksPerPage,
      );

  double get _pageHeight =>
      widget.styleDayOfWeek?.height ??
      0.0 +
          widget.style.weeksPerPage * widget.style.rowHeight +
          (widget.style.tablePadding.vertical);

  @override
  void initState() {
    super.initState();
    _endIndex = _focusedPageIndex(widget.domain.start, widget.domain.end);
    final focusedDay = widget.focusedDay;
    _focusedDate = ValueNotifier(focusedDay);
    _rangeSelectionMode = widget.rangeSelectionMode;
    _height = ValueNotifier(_pageHeight);
    final initialPage = _focusedPageIndex(widget.domain.start, focusedDay);
    _previousIndex = initialPage;
    _pageController = PageController(initialPage: initialPage);
    widget.onCalendarCreated?.call(_pageController);
    _pageCallbackDisabled = false;
  }

  ///
  ///
  ///
  bool get _shouldBlockOutsideDays =>
      widget.style.outsideDecoration == null && widget.style.weeksPerPage == 6;

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

    if (widget.style.weeksPerPage == 6) {
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
  ConstraintsBuilder? _marksBuilder(DateTime date) {
    final events = widget.eventLoader?.call(date);
    if (events == null) return null;
    final styleMark = widget.styleMark;
    if (styleMark == null) return null;
    return (context, constraints) =>
        widget.eventsLayoutMark(constraints, styleMark)(
          date,
          events,
          widget.eventMark(constraints, styleMark),
        )!;
  }

  ///
  /// see also the comment above [HighlightRangeBuilder]
  ///
  ConstraintsBuilder? _highlightRangeBuilder(DateTime date) {
    final rangeStart = this.rangeStart;
    if (rangeStart == null) return null;
    if (date.isBefore(rangeStart)) return null;
    if (date.isAfter(rangeStart)) {
      final rangeEnd = this.rangeEnd;
      if (rangeEnd == null) return null;
      if (date.isAfter(rangeEnd)) return null;

      // range in
      if (date.isBefore(rangeEnd)) {
        return (_, c) => widget.style.builderHighlightRange(date, null, c);
      }
      // range end
      return (_, c) => widget.style.builderHighlightRange(date, false, c);
    }
    // range start
    return (_, c) => widget.style.builderHighlightRange(date, true, c);
  }

  ///
  ///
  ///
  Widget _layoutCell({
    required DateTime date,
    required CellBuilder builder,
    required ConstraintsBuilder? builderMarks,
    required ConstraintsBuilder? builderHighlightRange,
  }) => LayoutBuilder(
    builder: (context, constraints) {
      final highlightRange = builderHighlightRange?.call(context, constraints);
      final marks = builderMarks?.call(context, constraints);
      return Stack(
        alignment: widget.style.cellStackAlignment,
        clipBehavior: widget.style.cellStackClip,
        children: [
          if (highlightRange != null) highlightRange,
          Semantics(
            key: ValueKey('Cell-${date.year}-${date.month}-${date.day}'),
            label:
                '${DateFormat.EEEE(widget.locale).format(date)}, '
                '${DateFormat.yMMMMd(widget.locale).format(date)}',
            excludeSemantics: true,
            child: builder(date, _focusedDate.value, widget.locale),
          ),
          if (marks != null) marks,
        ],
      );
    },
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
    final isOutside = date.month != _focusedDate.value.month;

    // blocked
    if (isOutside && _shouldBlockOutsideDays) return Container();

    // disabled
    if (_isDayDisabled(date)) {
      return _layoutCell(
        date: date,
        builder: widget.style.builderDisabled,
        builderMarks:
            (widget.styleMark?.forDisabledCell ?? false)
                ? _marksBuilder(date)
                : null,
        builderHighlightRange: _highlightRangeBuilder(date),
      );
    }

    late final CellBuilder builder;
    // outside
    if (isOutside) {
      builder = widget.style.builderOutside;

      // holiday
    } else if (widget.predicateHoliday(date)) {
      builder = widget.style.builderHoliday;

      // today
    } else if (DateTimeExtension.predicateSameDate(date, widget.currentDate)) {
      builder = widget.style.builderToday;

      // selected
    } else if (widget.predicateSelect(date)) {
      builder = widget.style.builderSelected;

      // weekend
    } else if (widget.style.weekendDays.contains(date.weekday)) {
      builder = widget.style.builderWeekend;

      // weekday
    } else {
      builder = widget.style.builderWeekday;
    }

    return _activeCell(
      date: date,
      child: _layoutCell(
        date: date,
        builder: builder,
        builderMarks: _marksBuilder(date),
        builderHighlightRange: _highlightRangeBuilder(date),
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
                style._paging(_focusedDate.value, index - _previousIndex),
                widget.domain.start,
                widget.domain.end,
              );

      if (!DateTimeExtension.predicateSameDate(_focusedDate.value, next)) {
        _focusedDate.value = next;
      }
      if (style.weeksPerPage == CalendarStyle.weeksPerPage_6 &&
          !constraints.hasBoundedHeight) {
        _height.value = _pageHeight;
      }

      _previousIndex = index;
      _focusedDate.value = next;
      widget.onPageChanged?.call(index, next);
    }

    _pageCallbackDisabled = false;
  };

  ValueWidgetBuilder<double> _builderPage(BoxConstraints constraints) =>
      (context, value, child) => AnimatedSize(
        duration: widget.formatAnimationDuration,
        curve: widget.formatAnimationCurve,
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: constraints.hasBoundedHeight ? constraints.maxHeight : value,
          child: child,
        ),
      );

  ///
  ///
  ///
  double? _heightPageRow(BoxConstraints constraints) =>
      constraints.hasBoundedHeight
          ? (constraints.maxHeight - (widget.styleDayOfWeek?.height ?? 0.0)) /
              widget.style.weeksPerPage
          : widget.style.rowHeight;

  NullableIndexedWidgetBuilder _builderPageItem(BoxConstraints constraints) => (
    BuildContext context,
    int index,
  ) {
    final dates = DateTimeRangeExtension.daysIn(
      DateTimeRangeExtension.weeksFrom(
        dm.DateTimeExtension.clamp(
          widget.style._paging(widget.domain.start, index),
          widget.domain.start,
          widget.domain.end,
        ),
        widget.style.weeksPerPage,
      ),
    );
    final weekNumbers = widget.styleWeekNumbers?.build(
      dates,
      _heightPageRow(constraints),
    );
    final daysOfWeek = widget.styleDayOfWeek?.buildTableRow(
      style: widget.style,
      days: dates,
      date: _focusedDate.value,
      locale: widget.locale,
    );
    return Padding(
      padding: widget.style.tablePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (weekNumbers != null) weekNumbers,
          Expanded(
            child: Table(
              border: widget.style.tableBorder,
              children: [
                if (daysOfWeek != null) daysOfWeek,
                ...List.generate(
                  dates.length ~/ DateTime.daysPerWeek,
                  (index) => TableRow(
                    decoration: widget.style.rowDecoration,
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
  Widget buildHeader(BuildContext context, CalendarStyleHeader style) {
    final buildFormatButton = style.builderFormatButtonFrom(widget.style);
    return Container(
      decoration: style.headerDecoration,
      margin: style.headerMargin,
      padding: style.headerPadding,
      child: Row(
        children: [
          if (style.chevronVisible)
            style.chevron(
              DirectionIn4.left,
              iconOnTap: _pageController.previousPage,
              duration: widget.style.pageStepDuration,
              curve: widget.style.pageStepCurve,
            ),
          style.builderTitle(_focusedDate.value, widget.locale),
          if (buildFormatButton != null) buildFormatButton(context),
          if (style.chevronVisible)
            style.chevron(
              DirectionIn4.right,
              iconOnTap: _pageController.nextPage,
              duration: widget.style.pageStepDuration,
              curve: widget.style.pageStepCurve,
            ),
        ],
      ),
    );
  }

  Widget _layout(BuildContext context, BoxConstraints constraints) =>
      ValueListenableBuilder<double>(
        valueListenable: _height,
        builder: _builderPage(constraints),
        child: PageView.builder(
          onPageChanged: _layoutPageOnChange(constraints),
          controller: _pageController,
          physics: widget.style.horizontalScroll,
          itemCount: DateTimeRangeExtension.scopesOf(
            widget.domain,
            widget.style.startingWeekday,
            DateTime.daysPerWeek * widget.style.weeksPerPage,
          ),
          itemBuilder: _builderPageItem(constraints),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final styleHeader = widget.styleHeader;
    return Column(
      children: [
        if (styleHeader != null) buildHeader(context, styleHeader),
        widget.style.build(
          _layout,
          (context, constraints) => _TableCalendarVerticalDrag(
            weeksPerPage: widget.style.weeksPerPage,
            onFormatChange: widget.style.onFormatChange!,
            child: _layout(context, constraints),
          ),
        ),
      ],
    );
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

      _pageController.animateToPage(
        currentIndex,
        duration: widget.style.pageStepDuration,
        curve: widget.style.pageStepCurve,
      );
    } else {
      _pageController.jumpToPage(currentIndex);
    }

    _previousIndex = currentIndex;
    _height.value = _pageHeight;
    _pageCallbackDisabled = false;
  }

  @override
  void didUpdateWidget(TableCalendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldUpdate = _focusedDate.value != widget.focusedDay;
    if (shouldUpdate ||
        widget.style.weeksPerPage != oldWidget.style.weeksPerPage ||
        widget.style.startingWeekday != oldWidget.style.startingWeekday) {
      _focusedDate.value = widget.focusedDay;
      _updatePage(widget.pageAnimationEnabled && shouldUpdate);
    }

    if (widget.style.rowHeight != oldWidget.style.rowHeight ||
        widget.styleDayOfWeek?.height != oldWidget.styleDayOfWeek?.height) {
      _height.value = _pageHeight;
    }

    if (_rangeSelectionMode != widget.rangeSelectionMode) {
      _rangeSelectionMode = widget.rangeSelectionMode;
    }

    if (rangeStart == null && rangeEnd == null) {
      _firstSelectedDay = null;
    }
  }
}

///
///
///
class _TableCalendarVerticalDrag extends StatefulWidget {
  const _TableCalendarVerticalDrag({
    required this.weeksPerPage,
    required this.onFormatChange,
    required this.child,
  });

  final int weeksPerPage;
  final ValueChanged<int> onFormatChange;
  final Widget child;

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
        onDrag: GestureDetectorDragMixin.onVerticalDrag<int>(
          CalendarStyle.weeksPerPage_all,
          widget.weeksPerPage,
          widget.onFormatChange,
        ),
      ),
      child: widget.child,
    );
  }
}
