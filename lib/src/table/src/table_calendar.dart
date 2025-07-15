// ignore_for_file: constant_identifier_names
part of '../table_calendar.dart';

///
///
/// [TableCalendar]
///
///
class TableCalendar<T> extends StatefulWidget {
  final dynamic locale;
  final DateTimeRange domain;
  final DateTime focusedDay;
  final DateTime? currentDate;
  final List<int> availableWeeksPerPage;
  final bool pageJumpingEnabled;
  final bool pageAnimationEnabled;
  final bool expandVertical;
  final Duration formatAnimationDuration;
  final Curve formatAnimationCurve;
  final Duration pageAnimationDuration;
  final Curve pageAnimationCurve;
  final int startingWeekday;
  final HitTestBehavior dayHitTestBehavior;
  final AvailableScroll availableScroll;
  final HeaderStyle? headerStyle;

  ///
  ///
  ///
  final CalendarStyle style;
  final CalendarStyleCellMarker? styleCellMarker;
  final EventsLayoutMark<T>? eventsLayoutMark;
  final EventMark<T>? eventMark;
  final bool loadEventsForDisabledDays;
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
    this.availableWeeksPerPage = weeksPerPage_all,
    this.pageJumpingEnabled = false,
    this.pageAnimationEnabled = true,
    this.expandVertical = false,
    this.formatAnimationDuration = DurationExtension.milli200,
    this.formatAnimationCurve = Curves.linear,
    this.pageAnimationDuration = DurationExtension.milli300,
    this.pageAnimationCurve = Curves.easeOut,
    this.startingWeekday = DateTime.sunday,
    this.dayHitTestBehavior = HitTestBehavior.opaque,
    this.availableScroll = AvailableScroll.both,
    this.headerStyle = const HeaderStyle(),
    this.style = const CalendarStyle(),
    this.styleCellMarker,
    this.eventsLayoutMark,
    this.eventMark,

    ///
    ///
    ///
    this.rangeSelectionMode = RangeSelectionMode.toggledOff,
    this.eventLoader,
    this.enabledDayPredicate,
    this.loadEventsForDisabledDays = false,
    this.predicateSelect = _datePredicateFalse,
    this.predicateHoliday = _datePredicateFalse,
    this.onRangeSelected,
    this.onDaySelected,
    this.onDayLongPressed,
    this.onDisabledDayTapped,
    this.onDisabledDayLongPressed,
    this.onPageChanged,
    this.onCalendarCreated,
  }) : assert(availableWeeksPerPage.contains(style.weeksPerPage)),
       assert(availableWeeksPerPage.length <= weeksPerPage_all.length),
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
       currentDate = currentDay ?? DateTime.now(),
       assert(
         eventsLayoutMark == null || styleCellMarker != null,
         'events layout mark: ($eventsLayoutMark) requires style not null',
       ),
       assert(
         eventMark == null || styleCellMarker != null,
         'events single mark: ($eventsLayoutMark) requires style not null',
       );

  static bool _datePredicateFalse(DateTime date) => false;

  @override
  State<TableCalendar<T>> createState() => _TableCalendarState<T>();

  EventsLayoutMark<T> get _eventsLayoutMark =>
      CalendarStyleCellMarker._eventsAsPositionedRow<T>;

  EventMark<T> get _eventMark => CalendarStyleCellMarker._singleDecoration<T>;

  ///
  ///
  ///
  static const int weeksPerPage_6 = 6;
  static const int weeksPerPage_2 = 2;
  static const int weeksPerPage_1 = 1;
  static const List<int> weeksPerPage_all = [
    weeksPerPage_6,
    weeksPerPage_2,
    weeksPerPage_1,
  ];
}

///
///
///
class _TableCalendarState<T> extends State<TableCalendar<T>>
    with GestureDetectorDragMixin<TableCalendar<T>> {
  ///
  ///
  ///
  late final PageController _pageController;
  late final ValueNotifier<double> _pageHeight;
  late final ValueNotifier<DateTime> _focusedDate;
  late RangeSelectionMode _rangeSelectionMode;
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;

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
    _pageHeight.dispose();
    super.dispose();
  }

  ///
  ///
  ///
  int _focusedPageIndex(DateTime from, DateTime target) =>
      DateTimeRangeExtension.scopesOf(
        DateTimeRange(start: from, end: target),
        widget.startingWeekday,
        DateTime.daysPerWeek * widget.style.weeksPerPage,
      );

  @override
  void initState() {
    super.initState();
    _endIndex = _focusedPageIndex(widget.domain.start, widget.domain.end);
    final focusedDay = widget.focusedDay;
    _focusedDate = ValueNotifier(focusedDay);
    _rangeSelectionMode = widget.rangeSelectionMode;
    _pageHeight = ValueNotifier(widget.style.pageHeight);
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
  ConstraintsBuilder _dateBuilderLayout(
    DateTime date,
    TableCalendarCellType cellType,
  ) => (context, constraints) {
    final isDisabled = _isDayDisabled(date);

    Widget? cellRangeHighlight;
    try {
      cellRangeHighlight = widget.style.builderRangeHighlight(
        date,
        cellType.rangeHighlightState,
        constraints,
      );
    } on StateError catch (e) {
      if (e.message != TableCalendarCellType.message_noHighlight) rethrow;
    }

    //
    Widget? cellMarks;
    if (widget.loadEventsForDisabledDays || !isDisabled) {
      final style = widget.styleCellMarker;
      if (style != null) {
        cellMarks = widget._eventsLayoutMark(constraints, style)(
          date,
          widget.eventLoader?.call(date),
          widget._eventMark(constraints, style),
        );
      }
    }

    return Stack(
      alignment: widget.style.cellStackAlignment,
      clipBehavior: widget.style.cellStackClip,
      children: [
        if (cellRangeHighlight != null) cellRangeHighlight,
        TableCalendarCell(
          key: ValueKey('Cell-${date.year}-${date.month}-${date.day}'),
          date: date,
          locale: widget.locale,
          style: widget.style,
          focusedDate: _focusedDate.value,
          cellType: cellType,
        ),
        if (cellMarks != null) cellMarks,
      ],
    );
  };

  TableCalendarCellType cellTypeOf(DateTime date) {
    if (rangeStartDate != null) {
      if (DateTimeExtension.predicateSameDate(date, rangeStartDate)) {
        return TableCalendarCellType.rangeStart;
      }
      if (rangeEndDate != null) {
        if (DateTimeExtension.predicateSameDate(date, rangeEndDate)) {
          return TableCalendarCellType.rangeEnd;
        }
      }
      if (dm.DateTimeExtension.predicateWithin(
        date,
        rangeStartDate!,
        rangeEndDate!,
      )) {
        return TableCalendarCellType.rangeWithin;
      }
    }

    if (widget.predicateHoliday(date)) return TableCalendarCellType.holiday;
    if (date.month != _focusedDate.value.month) {
      return TableCalendarCellType.outside;
    }
    if (DateTimeExtension.predicateSameDate(date, widget.currentDate)) {
      return TableCalendarCellType.today;
    }
    // TODO: highlighted before select date
    if (widget.predicateSelect(date)) return TableCalendarCellType.selected;
    if (widget.style.weekendDays.contains(date.weekday)) {
      return TableCalendarCellType.weekend;
    }
    return TableCalendarCellType.weekday;
  }

  Widget _dateBuilder(DateTime date) {
    final cellType = cellTypeOf(date);
    if (cellType == TableCalendarCellType.outside && _shouldBlockOutsideDays) {
      return Container();
    }
    return GestureDetector(
      behavior: widget.dayHitTestBehavior,
      onTap: () => _onDateTapped(date),
      onLongPress: () => _onDateLongPressed(date),
      child: LayoutBuilder(builder: _dateBuilderLayout(date, cellType)),
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
      if (style.weeksPerPage == TableCalendar.weeksPerPage_6 &&
          !constraints.hasBoundedHeight) {
        _pageHeight.value = style.pageHeight;
      }

      _previousIndex = index;
      _focusedDate.value = next;
      widget.onPageChanged?.call(index, next);
    }

    _pageCallbackDisabled = false;
  };

  ValueWidgetBuilder<double> _layoutPage(BoxConstraints constraints) =>
      (context, value, child) => AnimatedSize(
        duration: widget.formatAnimationDuration,
        curve: widget.formatAnimationCurve,
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: constraints.hasBoundedHeight ? constraints.maxHeight : value,
          child: child,
        ),
      );

  NullableIndexedWidgetBuilder _layoutPageItem(BoxConstraints constraints) => (
    BuildContext context,
    int index,
  ) {
    final days = DateTimeRangeExtension.daysIn(
      DateTimeRangeExtension.weeksFrom(
        dm.DateTimeExtension.clamp(
          widget.style._paging(widget.domain.start, index),
          widget.domain.start,
          widget.domain.end,
        ),
        widget.style.weeksPerPage,
      ),
    );
    final daysOfWeekStyle = widget.style.daysOfWeekStyle;
    return Padding(
      padding: widget.style.tablePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.style.weekNumberVisible)
            Column(
              children: List.generate(
                days.length ~/ 7,
                (index) => Expanded(
                  child: SizedBox(
                    height: widget.style._layoutRowHeight(constraints),
                    child: widget.style.builderWeekNumber(
                      dm.DateTimeExtension.weekYearIndexOf(days[index * 7]),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Table(
              border: widget.style.tableBorder,
              children: [
                if (daysOfWeekStyle != null)
                  TableRow(
                    decoration: daysOfWeekStyle.decoration,
                    children: List.generate(
                      DateTime.daysPerWeek,
                      (index) => SizedBox(
                        height: daysOfWeekStyle.height,
                        child: widget.style.builderDayOfWeek(
                          days[index],
                          _focusedDate.value,
                          widget.locale,
                        ),
                      ),
                    ),
                  ),
                ...List.generate(
                  days.length ~/ DateTime.daysPerWeek,
                  (index) => TableRow(
                    decoration: widget.style.rowDecoration,
                    children: List.generate(
                      DateTime.daysPerWeek,
                      (id) => SizedBox(
                        height: widget.style._layoutRowHeight(constraints),
                        child: _dateBuilder(
                          days[index * DateTime.daysPerWeek + id],
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

  Widget _layout(BoxConstraints constraints) => ValueListenableBuilder<double>(
    valueListenable: _pageHeight,
    builder: _layoutPage(constraints),
    child: PageView.builder(
      onPageChanged: _layoutPageOnChange(constraints),
      controller: _pageController,
      physics: widget.availableScroll.scrollPhysicsHorizontal,
      itemCount: DateTimeRangeExtension.scopesOf(
        widget.domain,
        widget.startingWeekday,
        DateTime.daysPerWeek * widget.style.weeksPerPage,
      ),
      itemBuilder: _layoutPageItem(constraints),
    ),
  );

  ///
  ///
  ///
  void _onLeftChevronTap() => _pageController.previousPage(
    duration: widget.pageAnimationDuration,
    curve: widget.pageAnimationCurve,
  );

  void _onRightChevronTap() => _pageController.nextPage(
    duration: widget.pageAnimationDuration,
    curve: widget.pageAnimationCurve,
  );

  Widget _layoutBuilder(BuildContext context, BoxConstraints constraints) =>
      widget.availableScroll.canScrollVertical
          ? GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onVerticalDragStart: onDragStart,
            onVerticalDragUpdate: onDragUpdateFrom(),
            onVerticalDragEnd: onDragEndFrom(
              difference: GestureDetectorDragMixin.verticalDifference,
              threshold: 25.0,
              direction: GestureDetectorDragMixin.verticalForward,
              onDrag: GestureDetectorDragMixin.onVerticalDrag<int>(
                TableCalendar.weeksPerPage_all,
                widget.style.weeksPerPage,
                widget.headerStyle?.onFormatChanged,
              ),
            ),
            child: _layout(constraints),
          )
          : _layout(constraints);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendarHeader(
          headerStyle: widget.headerStyle,
          locale: widget.locale,
          focusedDate: _focusedDate.value,
          headerTitleBuilder: widget.style.builderHeaderTitle,
          onLeftChevronTap: _onLeftChevronTap,
          onRightChevronTap: _onRightChevronTap,
          availableWeeksPerPage: widget.availableWeeksPerPage,
          weeksPerPage: widget.style.weeksPerPage,
        ),
        Flexible(
          flex: widget.expandVertical ? 1 : 0,
          child: LayoutBuilder(builder: _layoutBuilder),
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
        duration: widget.pageAnimationDuration,
        curve: widget.pageAnimationCurve,
      );
    } else {
      _pageController.jumpToPage(currentIndex);
    }

    _previousIndex = currentIndex;
    _pageHeight.value = widget.style.pageHeight;
    _pageCallbackDisabled = false;
  }

  @override
  void didUpdateWidget(TableCalendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldUpdate = _focusedDate.value != widget.focusedDay;
    if (shouldUpdate ||
        widget.style.weeksPerPage != oldWidget.style.weeksPerPage ||
        widget.startingWeekday != oldWidget.startingWeekday) {
      _focusedDate.value = widget.focusedDay;
      _updatePage(widget.pageAnimationEnabled && shouldUpdate);
    }

    final style = widget.style;
    final oldStyle = oldWidget.style;
    if (style.rowHeight != oldStyle.rowHeight ||
        style.daysOfWeekStyle?.height != oldStyle.daysOfWeekStyle?.height) {
      _pageHeight.value = widget.style.pageHeight;
    }

    if (_rangeSelectionMode != widget.rangeSelectionMode) {
      _rangeSelectionMode = widget.rangeSelectionMode;
    }

    if (rangeStartDate == null && rangeEndDate == null) {
      _firstSelectedDay = null;
    }
  }
}
