// ignore_for_file: constant_identifier_names
import 'package:damath/damath.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kavendar/kavendar.dart';
import 'package:kavendar/src/table/src/calendar_style.dart';
import 'package:kavendar/src/custom/damath.dart' as dm;

import 'calendar_element.dart';

///
///
/// [TableCalendar]
///
///
class TableCalendar<T> extends StatefulWidget {
  final dynamic locale;
  final DateTimeRange domain;
  final DateTime? rangeStartDay;
  final DateTime? rangeEndDay;
  final DateTime focusedDay;
  final DateTime? currentDay;
  final Set<int> weekendDays;
  final int weeksPerPage;
  final List<int> availableWeeksPerPage;
  final bool daysOfWeekVisible;
  final bool pageJumpingEnabled;
  final bool pageAnimationEnabled;
  final bool sixWeekMonthsEnforced;
  final bool expandVertical;
  final bool weekNumbersVisible;
  final double rowHeight;
  final double daysOfWeekHeight;
  final Duration formatAnimationDuration;
  final Curve formatAnimationCurve;
  final Duration pageAnimationDuration;
  final Curve pageAnimationCurve;
  final int startingWeekday;
  final HitTestBehavior dayHitTestBehavior;
  final AvailableScroll availableScroll;
  final HeaderStyle? headerStyle;
  final DaysOfWeekStyle daysOfWeekStyle;
  final CalendarStyle calendarStyle;
  final CalendarBuilders<T> _calendarBuilders;

  CalendarBuilders<T> get calendarBuilders => _calendarBuilders;

  final RangeSelectionMode rangeSelectionMode;
  final bool loadEventsForDisabledDays;
  final List<T> Function(DateTime day)? eventLoader;
  final bool Function(DateTime day)? enabledDayPredicate;
  final bool Function(DateTime day)? selectedDayPredicate;
  final bool Function(DateTime day)? holidayPredicate;
  final OnRangeSelected? onRangeSelected;
  final OnDaySelected? onDaySelected;
  final OnDaySelected? onDayLongPressed;
  final OnPageChanged? onPageChanged;
  final void Function(DateTime day)? onDisabledDayTapped;
  final void Function(DateTime day)? onDisabledDayLongPressed;
  final void Function(PageController pageController)? onCalendarCreated;

  TableCalendar({
    super.key,
    required DateTime focusedDay,
    required DateTime firstDay,
    required DateTime lastDay,
    DateTime? currentDay,
    this.locale,
    this.rangeStartDay,
    this.rangeEndDay,
    this.weekendDays = const {DateTime.saturday, DateTime.sunday},
    this.weeksPerPage = 6,
    this.availableWeeksPerPage = weeksPerPage_all,
    this.daysOfWeekVisible = true,
    this.pageJumpingEnabled = false,
    this.pageAnimationEnabled = true,
    this.sixWeekMonthsEnforced = false,
    this.expandVertical = false,
    this.weekNumbersVisible = false,
    this.rowHeight = 52.0,
    this.daysOfWeekHeight = 16.0,
    this.formatAnimationDuration = DurationExtension.milli200,
    this.formatAnimationCurve = Curves.linear,
    this.pageAnimationDuration = DurationExtension.milli300,
    this.pageAnimationCurve = Curves.easeOut,
    this.startingWeekday = DateTime.sunday,
    this.dayHitTestBehavior = HitTestBehavior.opaque,
    this.availableScroll = AvailableScroll.both,
    this.headerStyle = const HeaderStyle(),
    this.daysOfWeekStyle = const DaysOfWeekStyle(),
    this.calendarStyle = const CalendarStyle(),
    CalendarBuilders<T>? calendarBuilders,
    this.rangeSelectionMode = RangeSelectionMode.toggledOff,
    this.eventLoader,
    this.enabledDayPredicate,
    this.loadEventsForDisabledDays = false,
    this.selectedDayPredicate,
    this.holidayPredicate,
    this.onRangeSelected,
    this.onDaySelected,
    this.onDayLongPressed,
    this.onDisabledDayTapped,
    this.onDisabledDayLongPressed,
    this.onPageChanged,
    this.onCalendarCreated,
  }) : assert(availableWeeksPerPage.contains(weeksPerPage)),
       assert(availableWeeksPerPage.length <= weeksPerPage_all.length),
       assert(dm.DateTimeExtension.anyInvalidWeekday(weekendDays)),
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
       currentDay = currentDay ?? DateTime.now(),
       _calendarBuilders = CalendarBuilders(style: calendarStyle);

  @override
  State<TableCalendar<T>> createState() => _TableCalendarState<T>();

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
  late final PageController _pageController;
  late final ValueNotifier<double> _pageHeight;
  late final ValueNotifier<DateTime> _focusedDay;
  late RangeSelectionMode _rangeSelectionMode;
  late bool _pageCallbackDisabled;
  late int _previousIndex;
  late final int _endIndex;
  DateTime? _firstSelectedDay;

  @override
  void dispose() {
    _focusedDay.dispose();
    _pageController.dispose();
    _pageHeight.dispose();
    super.dispose();
  }

  ///
  ///
  ///
  double _getPageHeight(int rowCount) =>
      (widget.daysOfWeekVisible ? widget.daysOfWeekHeight : 0.0) +
      rowCount * widget.rowHeight +
      (widget.calendarStyle.tablePadding.vertical);

  int _focusedPageIndex(DateTime from, DateTime target) =>
      DateTimeRangeExtension.scopesOf(
        DateTimeRange(start: from, end: target),
        widget.startingWeekday,
        DateTime.daysPerWeek * widget.weeksPerPage,
      );

  @override
  void initState() {
    super.initState();
    _endIndex = _focusedPageIndex(widget.domain.start, widget.domain.end);
    final focusedDay = widget.focusedDay;
    _focusedDay = ValueNotifier(focusedDay);
    _rangeSelectionMode = widget.rangeSelectionMode;
    _pageHeight = ValueNotifier(
      _getPageHeight(
        dm.DateTimeExtension.monthRowsOf(focusedDay, widget.startingWeekday),
      ),
    );
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
      widget.calendarStyle.outsideDecoration == null &&
      widget.weeksPerPage == 6;

  void _onDayTapped(DateTime day) {
    final isOutside = day.month != _focusedDay.value.month;
    if (isOutside && _shouldBlockOutsideDays) return;
    if (_isDayDisabled(day)) return widget.onDisabledDayTapped?.call(day);

    _updateFocusOnTap(day);

    if (_rangeSelectionMode.isSelectionOn && widget.onRangeSelected != null) {
      if (_firstSelectedDay == null) {
        _firstSelectedDay = day;
        widget.onRangeSelected!(_firstSelectedDay, null, _focusedDay.value);
      } else {
        if (day.isAfter(_firstSelectedDay!)) {
          widget.onRangeSelected!(_firstSelectedDay, day, _focusedDay.value);
          _firstSelectedDay = null;
        } else if (day.isBefore(_firstSelectedDay!)) {
          widget.onRangeSelected!(day, _firstSelectedDay, _focusedDay.value);
          _firstSelectedDay = null;
        }
      }
    } else {
      widget.onDaySelected?.call(day, _focusedDay.value);
    }
  }

  void _onDayLongPressed(DateTime day) {
    final isOutside = day.month != _focusedDay.value.month;
    if (isOutside && _shouldBlockOutsideDays) return;

    if (_isDayDisabled(day)) {
      return widget.onDisabledDayLongPressed?.call(day);
    }

    if (widget.onDayLongPressed != null) {
      _updateFocusOnTap(day);
      return widget.onDayLongPressed!(day, _focusedDay.value);
    }

    if (widget.onRangeSelected != null) {
      if (_rangeSelectionMode.isToggleAble) {
        _updateFocusOnTap(day);
        _rangeSelectionMode =
            _rangeSelectionMode == RangeSelectionMode.toggledOn
                ? RangeSelectionMode.toggledOff
                : RangeSelectionMode.toggledOn;

        if (_rangeSelectionMode.isSelectionOn) {
          _firstSelectedDay = day;
          widget.onRangeSelected!(_firstSelectedDay, null, _focusedDay.value);
        } else {
          _firstSelectedDay = null;
          widget.onDaySelected?.call(day, _focusedDay.value);
        }
      }
    }
  }

  void _updateFocusOnTap(DateTime day) {
    if (widget.pageJumpingEnabled) {
      _focusedDay.value = day;
      return;
    }

    if (widget.weeksPerPage == 6) {
      if (dm.DateTimeExtension.predicateBeforeMonth(day, _focusedDay.value)) {
        _focusedDay.value = dm.DateTimeExtension.firstDateOfMonth(
          _focusedDay.value,
        );
      } else if (dm.DateTimeExtension.predicateAfterMonth(
        day,
        _focusedDay.value,
      )) {
        _focusedDay.value = dm.DateTimeExtension.lastDateOfMonth(
          _focusedDay.value,
        );
      } else {
        _focusedDay.value = day;
      }
    } else {
      _focusedDay.value = day;
    }
  }

  void _onPageChange(int index, DateTime focusedDay) {
    _focusedDay.value = focusedDay;
    widget.onPageChanged?.call(index, focusedDay);
  }

  ///
  /// a year
  ///
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
  Widget _weekNumbersBuilder(DateTime date) {
    final index = dm.DateTimeExtension.weekYearIndexOf(date);
    return widget.calendarBuilders.weekYearIndexBuilder?.call(index) ??
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Center(
            child: Text(
              index.toString(),
              style: widget.calendarStyle.weekNumberTextStyle,
            ),
          ),
        );
  }

  Widget _dayOfWeekBuilder(DateTime day) =>
      widget.calendarBuilders.dayOfWeekBuilder?.call(day) ??
      Center(
        child: ExcludeSemantics(
          child: Text(
            widget.daysOfWeekStyle.dowTextFormatter?.call(day, widget.locale) ??
                DateFormat.E(widget.locale).format(day),
            style:
                widget.weekendDays.contains(day.weekday)
                    ? widget.daysOfWeekStyle.weekendStyle
                    : widget.daysOfWeekStyle.weekdayStyle,
          ),
        ),
      );

  ///
  ///
  ///

  Widget? _dayBuilderRangeHighlight(
    BoxConstraints constraints,
    DateTime day,
    bool isRangeStart,
    bool isRangeEnd,
  ) =>
      widget.calendarBuilders.rangeHighlightBuilder?.call(day) ??
      Center(
        child: Container(
          margin: EdgeInsetsDirectional.only(
            start: isRangeStart ? constraints.maxWidth * 0.5 : 0.0,
            end: isRangeEnd ? constraints.maxWidth * 0.5 : 0.0,
          ),
          height:
              (BoxConstraintsExtension.shortSide(constraints) -
                  widget.calendarStyle.cellMargin.vertical) *
              widget.calendarStyle.rangeHighlightScale,
          color: widget.calendarStyle.rangeHighlightColor,
        ),
      );

  ConstraintsBuilder _dayBuilderLayout(
    DateTime day,
    DateTime focusedDay,
    bool isOutside,
  ) => (context, constraints) {
    final isDisabled = _isDayDisabled(day);
    final isWithinRange =
        widget.rangeStartDay != null &&
        widget.rangeEndDay != null &&
        dm.DateTimeExtension.predicateWithin(
          day,
          widget.rangeStartDay!,
          widget.rangeEndDay!,
        );
    final isRangeStart = DateTimeExtension.predicateSameDate(
      day,
      widget.rangeStartDay,
    );
    final isRangeEnd = DateTimeExtension.predicateSameDate(
      day,
      widget.rangeEndDay,
    );

    // range highlight
    Widget? rangeHighlight;
    if (isWithinRange) {
      rangeHighlight = _dayBuilderRangeHighlight(
        constraints,
        day,
        isRangeStart,
        isRangeEnd,
      );
    }

    // events marker
    Widget? eventsMarker;
    if (widget.loadEventsForDisabledDays || !isDisabled) {
      eventsMarker = widget.calendarBuilders.markerBuilder(
        constraints,
        day,
        widget.eventLoader?.call(day),
      );
    }

    return Stack(
      alignment: widget.calendarStyle.cellStackAlignment,
      clipBehavior: widget.calendarStyle.cellStackClip,
      children: [
        if (rangeHighlight != null) rangeHighlight,
        TableCalendarCell(
          key: ValueKey('Cell-${day.year}-${day.month}-${day.day}'),
          day: day,
          focusedDay: focusedDay,
          calendarStyle: widget.calendarStyle,
          calendarBuilders: widget.calendarBuilders,
          isTodayHighlighted: widget.calendarStyle.todayIsHighlighted,
          isToday: DateTimeExtension.predicateSameDate(day, widget.currentDay),
          isSelected: widget.selectedDayPredicate?.call(day) ?? false,
          isRangeStart: isRangeStart,
          isRangeEnd: isRangeEnd,
          isWithinRange: isWithinRange,
          isOutside: isOutside,
          isDisabled: isDisabled,
          isWeekend: widget.weekendDays.contains(day.weekday),
          isHoliday: widget.holidayPredicate?.call(day) ?? false,
          locale: widget.locale,
        ),
        if (eventsMarker != null) eventsMarker,
      ],
    );
  };

  Widget _dayBuilder(DateTime day, DateTime focusedDay) {
    final isOutside = day.month != focusedDay.month;
    if (isOutside && _shouldBlockOutsideDays) return Container();
    return GestureDetector(
      behavior: widget.dayHitTestBehavior,
      onTap: () => _onDayTapped(day),
      onLongPress: () => _onDayLongPressed(day),
      child: LayoutBuilder(
        builder: _dayBuilderLayout(day, focusedDay, isOutside),
      ),
    );
  }

  ///
  ///
  ///
  void _updatePage(bool shouldAnimate) {
    final currentIndex = _focusedPageIndex(
      widget.domain.start,
      _focusedDay.value,
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
    _pageHeight.value = _getPageHeight(
      dm.DateTimeExtension.monthRowsOf(
        _focusedDay.value,
        widget.startingWeekday,
      ),
    );
    _pageCallbackDisabled = false;
  }

  @override
  void didUpdateWidget(TableCalendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldUpdate = _focusedDay.value != widget.focusedDay;
    if (shouldUpdate ||
        widget.weeksPerPage != oldWidget.weeksPerPage ||
        widget.startingWeekday != oldWidget.startingWeekday) {
      _focusedDay.value = widget.focusedDay;
      _updatePage(widget.pageAnimationEnabled && shouldUpdate);
    }

    if (widget.rowHeight != oldWidget.rowHeight ||
        widget.daysOfWeekHeight != oldWidget.daysOfWeekHeight ||
        widget.daysOfWeekVisible != oldWidget.daysOfWeekVisible) {
      _pageHeight.value = _getPageHeight(
        dm.DateTimeExtension.monthRowsOf(
          _focusedDay.value,
          widget.startingWeekday,
        ),
      );
    }

    if (_rangeSelectionMode != widget.rangeSelectionMode) {
      _rangeSelectionMode = widget.rangeSelectionMode;
    }

    if (widget.rangeStartDay == null && widget.rangeEndDay == null) {
      _firstSelectedDay = null;
    }
  }

  ///
  ///
  ///
  DateTime _focus(DateTime prevFocused, int i) => switch (widget.weeksPerPage) {
    6 => DateTime.utc(prevFocused.year, prevFocused.month + i),
    2 => DateTime.utc(
      prevFocused.year,
      prevFocused.month,
      prevFocused.day + i * 14,
    ),
    1 => DateTime.utc(
      prevFocused.year,
      prevFocused.month,
      prevFocused.day + i * 7,
    ),
    _ => throw UnimplementedError('unimplement weeks: ${widget.weeksPerPage}'),
  };

  DateTime _getFocusedDay(DateTime prevFocusedDay, int pageIndex) {
    if (pageIndex == _previousIndex) return prevFocusedDay;
    return dm.DateTimeExtension.clamp(
      _focus(prevFocusedDay, pageIndex - _previousIndex),
      widget.domain.start,
      widget.domain.end,
    );
  }

  ///
  ///
  ///
  double? _layoutRowHeight(BoxConstraints constraints) =>
      constraints.hasBoundedHeight
          ? (constraints.maxHeight -
                  (widget.daysOfWeekVisible ? widget.daysOfWeekHeight : 0.0)) /
              widget.weeksPerPage
          : widget.rowHeight;

  Widget _layoutWeekNumbers(
    BoxConstraints constraints,
    List<DateTime> visibleDays,
  ) => Column(
    children: [
      if (widget.daysOfWeekVisible) SizedBox(height: widget.daysOfWeekHeight),
      ...List.generate(
        visibleDays.length ~/ 7,
        (index) => Expanded(
          child: SizedBox(
            height: _layoutRowHeight(constraints),
            child: _weekNumbersBuilder.call(visibleDays[index * 7]),
          ),
        ),
      ),
    ],
  );

  TableRow _layoutWeekends(List<DateTime> visibleDays) => TableRow(
    decoration: widget.daysOfWeekStyle.decoration,
    children: List.generate(
      7,
      (index) => SizedBox(
        height: widget.daysOfWeekHeight,
        child: _dayOfWeekBuilder(visibleDays[index]),
      ),
    ),
  );

  List<TableRow> _layoutWeekdays(
    BoxConstraints constraints,
    List<DateTime> visibleDays,
  ) => List.generate(
    visibleDays.length ~/ DateTime.daysPerWeek,
    (index) => TableRow(
      decoration: widget.calendarStyle.rowDecoration,
      children: List.generate(
        DateTime.daysPerWeek,
        (id) => SizedBox(
          height: _layoutRowHeight(constraints),
          child: _dayBuilder(
            visibleDays[index * 7 + id],
            _getFocusedDay(_focusedDay.value, index),
          ),
        ),
      ),
    ),
  );

  ///
  ///
  ///
  ValueWidgetBuilder<double> _layoutPageAnimated(BoxConstraints constraints) =>
      (context, value, child) => AnimatedSize(
        duration: widget.formatAnimationDuration,
        curve: widget.formatAnimationCurve,
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: constraints.hasBoundedHeight ? constraints.maxHeight : value,
          child: child,
        ),
      );

  ValueChanged<int> _layoutPageOnChange(BoxConstraints constraints) => (index) {
    if (!_pageCallbackDisabled) {
      final focusedDay = _getFocusedDay(_focusedDay.value, index);
      if (!DateTimeExtension.predicateSameDate(_focusedDay.value, focusedDay)) {
        _focusedDay.value = focusedDay;
      }
      if (widget.weeksPerPage == TableCalendar.weeksPerPage_6 &&
          !constraints.hasBoundedHeight) {
        final rowCount = dm.DateTimeExtension.monthRowsOf(
          focusedDay,
          widget.startingWeekday,
        );
        _pageHeight.value = _getPageHeight(rowCount);
      }

      _previousIndex = index;
      _onPageChange(index, focusedDay);
    }

    _pageCallbackDisabled = false;
  };

  NullableIndexedWidgetBuilder _layoutPageItem(BoxConstraints constraints) => (
    BuildContext context,
    int index,
  ) {
    final days = DateTimeRangeExtension.daysIn(
      DateTimeRangeExtension.weeksFrom(
        dm.DateTimeExtension.clamp(
          _focus(widget.domain.start, index),
          widget.domain.start,
          widget.domain.end,
        ),
        widget.weeksPerPage,
      ),
    );
    return Padding(
      padding: widget.calendarStyle.tablePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.weekNumbersVisible) _layoutWeekNumbers(constraints, days),
          Expanded(
            child: Table(
              border: widget.calendarStyle.tableBorder,
              children: [
                if (widget.daysOfWeekVisible) _layoutWeekends(days),
                ..._layoutWeekdays(constraints, days),
              ],
            ),
          ),
        ],
      ),
    );
  };

  Widget _layout(BoxConstraints constraints) => ValueListenableBuilder<double>(
    valueListenable: _pageHeight,
    builder: _layoutPageAnimated(constraints),
    child: PageView.builder(
      onPageChanged: _layoutPageOnChange(constraints),
      controller: _pageController,
      physics: widget.availableScroll.scrollPhysicsHorizontal,
      itemCount: DateTimeRangeExtension.scopesOf(
        widget.domain,
        widget.startingWeekday,
        DateTime.daysPerWeek * widget.weeksPerPage,
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
                widget.weeksPerPage,
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
          focusedDay: _focusedDay.value,
          headerTitleBuilder: widget.calendarBuilders.headerTitleBuilder,
          onLeftChevronTap: _onLeftChevronTap,
          onRightChevronTap: _onRightChevronTap,
          availableWeeksPerPage: widget.availableWeeksPerPage,
          weeksPerPage: widget.weeksPerPage,
        ),
        Flexible(
          flex: widget.expandVertical ? 1 : 0,
          child: LayoutBuilder(builder: _layoutBuilder),
        ),
      ],
    );
  }
}
