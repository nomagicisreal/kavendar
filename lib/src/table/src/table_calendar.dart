import 'dart:math';
import 'package:damath/damath.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kavendar/kavendar.dart';
import 'package:kavendar/src/table/src/calendar_style.dart';
import 'package:kavendar/src/custom/damath.dart' as dm;

import 'calendar_core.dart';
import 'calendar_element.dart';

///
/// [TableCalendar]
/// [TableCalendarBase]
///

class TableCalendar<T> extends StatefulWidget {
  final dynamic locale;
  final DateTimeRange domain;
  final DateTime? rangeStartDay;
  final DateTime? rangeEndDay;
  final DateTime focusedDay;
  final DateTime? currentDay;
  final List<int> weekendDays;
  final int weeksPerPage;
  final Map<int, String> availableCalendarFormats;
  final bool headerVisible;
  final bool daysOfWeekVisible;
  final bool pageJumpingEnabled;
  final bool pageAnimationEnabled;
  final bool sixWeekMonthsEnforced;
  final bool shouldFillViewport;
  final bool weekNumbersVisible;
  final double rowHeight;
  final double daysOfWeekHeight;
  final Duration formatAnimationDuration;
  final Curve formatAnimationCurve;
  final Duration pageAnimationDuration;
  final Curve pageAnimationCurve;
  final int startingDayOfWeek;
  final HitTestBehavior dayHitTestBehavior;
  final AvailableGestures availableGestures;
  final HeaderStyle headerStyle;
  final DaysOfWeekStyle daysOfWeekStyle;
  final CalendarStyle calendarStyle;
  final CalendarBuilders<T> calendarBuilders;
  final RangeSelectionMode rangeSelectionMode;
  final bool loadEventsForDisabledDays;
  final List<T> Function(DateTime day)? eventLoader;
  final bool Function(DateTime day)? enabledDayPredicate;
  final bool Function(DateTime day)? selectedDayPredicate;
  final bool Function(DateTime day)? holidayPredicate;
  final OnRangeSelected? onRangeSelected;
  final OnDaySelected? onDaySelected;
  final OnDaySelected? onDayLongPressed;
  final void Function(DateTime day)? onDisabledDayTapped;
  final void Function(DateTime day)? onDisabledDayLongPressed;
  final void Function(DateTime focusedDay)? onHeaderTap;
  final void Function(DateTime focusedDay)? onHeaderLongPress;
  final void Function(DateTime focusedDay)? onPageChanged;
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
    this.weekendDays = const [DateTime.saturday, DateTime.sunday],
    this.weeksPerPage = 6,
    this.availableCalendarFormats = const {6: 'Month', 2: '2 weeks', 1: 'Week'},
    this.headerVisible = true,
    this.daysOfWeekVisible = true,
    this.pageJumpingEnabled = false,
    this.pageAnimationEnabled = true,
    this.sixWeekMonthsEnforced = false,
    this.shouldFillViewport = false,
    this.weekNumbersVisible = false,
    this.rowHeight = 52.0,
    this.daysOfWeekHeight = 16.0,
    this.formatAnimationDuration = DurationExtension.milli200,
    this.formatAnimationCurve = Curves.linear,
    this.pageAnimationDuration = DurationExtension.milli300,
    this.pageAnimationCurve = Curves.easeOut,
    this.startingDayOfWeek = DateTime.sunday,
    this.dayHitTestBehavior = HitTestBehavior.opaque,
    this.availableGestures = AvailableGestures.all,
    this.headerStyle = const HeaderStyle(),
    this.daysOfWeekStyle = const DaysOfWeekStyle(),
    this.calendarStyle = const CalendarStyle(),
    this.calendarBuilders = const CalendarBuilders(),
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
    this.onHeaderTap,
    this.onHeaderLongPress,
    this.onPageChanged,
    this.onCalendarCreated,
  }) : assert(availableCalendarFormats.keys.contains(weeksPerPage)),
       assert(availableCalendarFormats.length <= CalendarFormat.values.length),
       assert(
         weekendDays.isEmpty ||
             weekendDays.every(
               (day) => day >= DateTime.monday && day <= DateTime.sunday,
             ),
       ),
       focusedDay = dm.DateTimeExtension.normalizeDate(focusedDay),
       domain = DateTimeRange(
         start: dm.DateTimeExtension.normalizeDate(firstDay),
         end: dm.DateTimeExtension.normalizeDate(lastDay),
       ),
       currentDay = currentDay ?? DateTime.now();

  @override
  State<TableCalendar<T>> createState() => _TableCalendarState<T>();

  ///
  ///
  ///
  static int weeksPerPage_6 = 6;
  static int weeksPerPage_2 = 2;
  static int weeksPerPage_1 = 1;
}

class _TableCalendarState<T> extends State<TableCalendar<T>> {
  late final PageController _pageController;
  late final ValueNotifier<DateTime> _focusedDay;
  late RangeSelectionMode _rangeSelectionMode;
  DateTime? _firstSelectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = ValueNotifier(widget.focusedDay);
    _rangeSelectionMode = widget.rangeSelectionMode;
  }

  @override
  void didUpdateWidget(TableCalendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_focusedDay.value != widget.focusedDay) {
      _focusedDay.value = widget.focusedDay;
    }

    if (_rangeSelectionMode != widget.rangeSelectionMode) {
      _rangeSelectionMode = widget.rangeSelectionMode;
    }

    if (widget.rangeStartDay == null && widget.rangeEndDay == null) {
      _firstSelectedDay = null;
    }
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    super.dispose();
  }

  bool get _isRangeSelectionToggleable =>
      _rangeSelectionMode == RangeSelectionMode.toggledOn ||
      _rangeSelectionMode == RangeSelectionMode.toggledOff;

  bool get _isRangeSelectionOn =>
      _rangeSelectionMode == RangeSelectionMode.toggledOn ||
      _rangeSelectionMode == RangeSelectionMode.enforced;

  bool get _shouldBlockOutsideDays =>
      !widget.calendarStyle.outsideDaysVisible && widget.weeksPerPage == 6;

  void _swipeCalendarFormat(DirectionIn4 direction) {
    final onFormatChanged = widget.headerStyle.onFormatChanged;
    if (onFormatChanged != null) {
      final formats = widget.availableCalendarFormats.keys.toList();

      final isSwipeUp = direction == DirectionIn4.top;
      int id = formats.indexOf(widget.weeksPerPage);

      // Order of CalendarFormats must be from biggest to smallest,
      // e.g.: [month, twoWeeks, week]
      if (isSwipeUp) {
        id = min(formats.length - 1, id + 1);
      } else {
        id = max(0, id - 1);
      }

      onFormatChanged(formats[id]);
    }
  }

  void _onDayTapped(DateTime day) {
    final isOutside = day.month != _focusedDay.value.month;
    if (isOutside && _shouldBlockOutsideDays) return;
    if (_isDayDisabled(day)) return widget.onDisabledDayTapped?.call(day);

    _updateFocusOnTap(day);

    if (_isRangeSelectionOn && widget.onRangeSelected != null) {
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
      if (_isRangeSelectionToggleable) {
        _updateFocusOnTap(day);
        _toggleRangeSelection();

        if (_isRangeSelectionOn) {
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
      if (dm.DateTimeExtension.isBeforeMonth(day, _focusedDay.value)) {
        _focusedDay.value = dm.DateTimeExtension.firstDateOfMonth(
          _focusedDay.value,
        );
      } else if (dm.DateTimeExtension.isAfterMonth(day, _focusedDay.value)) {
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

  void _toggleRangeSelection() =>
      _rangeSelectionMode =
          _rangeSelectionMode == RangeSelectionMode.toggledOn
              ? RangeSelectionMode.toggledOff
              : RangeSelectionMode.toggledOn;

  void _onLeftChevronTap() => _pageController.previousPage(
    duration: widget.pageAnimationDuration,
    curve: widget.pageAnimationCurve,
  );

  void _onRightChevronTap() => _pageController.nextPage(
    duration: widget.pageAnimationDuration,
    curve: widget.pageAnimationCurve,
  );

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay.value = focusedDay;
    widget.onPageChanged?.call(focusedDay);
  }

  void _onCalendarCreated(PageController controller) {
    _pageController = controller;
    widget.onCalendarCreated?.call(controller);
  }

  ///
  ///
  ///
  Widget _buildSingleMarker(DateTime day, T event, double markerSize) =>
      widget.calendarBuilders.singleMarkerBuilder?.call(context, day, event) ??
      Container(
        width: markerSize,
        height: markerSize,
        margin: widget.calendarStyle.markerMargin,
        decoration: widget.calendarStyle.markerDecoration,
      );

  int _calculateWeekNumber(DateTime date) {
    final middleDay = date.add(const Duration(days: 3));
    final dayOfYear = dm.DateTimeExtension.dayOfYear(middleDay);
    return 1 + ((dayOfYear - 1) / 7).floor();
  }

  bool _isDayDisabled(DateTime day) =>
      day.isBefore(widget.domain.start) ||
      day.isAfter(widget.domain.end) ||
      !_isDayAvailable(day);

  bool _isDayAvailable(DateTime day) {
    if (widget.enabledDayPredicate == null) return true;
    return widget.enabledDayPredicate!(day);
  }

  bool _isWeekend(
    DateTime day, {
    List<int> weekendDays = const [DateTime.saturday, DateTime.sunday],
  }) => weekendDays.contains(day.weekday);

  ///
  ///
  ///
  Widget _weekNumbersBuilder(DateTime day) {
    final weekNumber = _calculateWeekNumber(day);
    return widget.calendarBuilders.weekNumberBuilder?.call(weekNumber) ??
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Center(
            child: Text(
              weekNumber.toString(),
              style: widget.calendarStyle.weekNumberTextStyle,
            ),
          ),
        );
  }

  Widget _dowBuilder(DateTime day) =>
      widget.calendarBuilders.dowBuilder?.call(day) ??
      Center(
        child: ExcludeSemantics(
          child: Text(
            widget.daysOfWeekStyle.dowTextFormatter?.call(day, widget.locale) ??
                DateFormat.E(widget.locale).format(day),
            style:
                _isWeekend(day, weekendDays: widget.weekendDays)
                    ? widget.daysOfWeekStyle.weekendStyle
                    : widget.daysOfWeekStyle.weekdayStyle,
          ),
        ),
      );

  Widget _dayBuilder(DateTime day, DateTime focusedDay) {
    final isOutside = day.month != focusedDay.month;
    if (isOutside && _shouldBlockOutsideDays) return Container();

    return GestureDetector(
      behavior: widget.dayHitTestBehavior,
      onTap: () => _onDayTapped(day),
      onLongPress: () => _onDayLongPressed(day),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shorterSide =
              constraints.maxHeight > constraints.maxWidth
                  ? constraints.maxWidth
                  : constraints.maxHeight;

          final children = <Widget>[];

          final isWithinRange =
              widget.rangeStartDay != null &&
              widget.rangeEndDay != null &&
              dm.DateTimeExtension.isWithin(
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

          Widget? rangeHighlight = widget.calendarBuilders.rangeHighlightBuilder
              ?.call(context, day, isWithinRange);

          if (rangeHighlight == null) {
            if (isWithinRange) {
              rangeHighlight = Center(
                child: Container(
                  margin: EdgeInsetsDirectional.only(
                    start: isRangeStart ? constraints.maxWidth * 0.5 : 0.0,
                    end: isRangeEnd ? constraints.maxWidth * 0.5 : 0.0,
                  ),
                  height:
                      (shorterSide - widget.calendarStyle.cellMargin.vertical) *
                      widget.calendarStyle.rangeHighlightScale,
                  color: widget.calendarStyle.rangeHighlightColor,
                ),
              );
            }
          }

          if (rangeHighlight != null) {
            children.add(rangeHighlight);
          }

          final isToday = DateTimeExtension.predicateSameDate(
            day,
            widget.currentDay,
          );
          final isDisabled = _isDayDisabled(day);
          final isWeekend = _isWeekend(day, weekendDays: widget.weekendDays);

          final content = TableCalendarCell(
            key: ValueKey('CellContent-${day.year}-${day.month}-${day.day}'),
            day: day,
            focusedDay: focusedDay,
            calendarStyle: widget.calendarStyle,
            calendarBuilders: widget.calendarBuilders,
            isTodayHighlighted: widget.calendarStyle.isTodayHighlighted,
            isToday: isToday,
            isSelected: widget.selectedDayPredicate?.call(day) ?? false,
            isRangeStart: isRangeStart,
            isRangeEnd: isRangeEnd,
            isWithinRange: isWithinRange,
            isOutside: isOutside,
            isDisabled: isDisabled,
            isWeekend: isWeekend,
            isHoliday: widget.holidayPredicate?.call(day) ?? false,
            locale: widget.locale,
          );

          children.add(content);

          if (widget.loadEventsForDisabledDays || !isDisabled) {
            final events = widget.eventLoader?.call(day) ?? [];
            Widget? markerWidget = widget.calendarBuilders.markerBuilder?.call(
              context,
              day,
              events,
            );

            if (events.isNotEmpty && markerWidget == null) {
              final center = constraints.maxHeight / 2;

              final markerSize =
                  widget.calendarStyle.markerSize ??
                  (shorterSide - widget.calendarStyle.cellMargin.vertical) *
                      widget.calendarStyle.markerSizeScale;

              final markerAutoAlignmentTop =
                  center +
                  (shorterSide - widget.calendarStyle.cellMargin.vertical) / 2 -
                  (markerSize * widget.calendarStyle.markersAnchor);

              markerWidget = PositionedDirectional(
                top:
                    widget.calendarStyle.markersAutoAligned
                        ? markerAutoAlignmentTop
                        : widget.calendarStyle.markersOffset.top,
                bottom:
                    widget.calendarStyle.markersAutoAligned
                        ? null
                        : widget.calendarStyle.markersOffset.bottom,
                start:
                    widget.calendarStyle.markersAutoAligned
                        ? null
                        : widget.calendarStyle.markersOffset.start,
                end:
                    widget.calendarStyle.markersAutoAligned
                        ? null
                        : widget.calendarStyle.markersOffset.end,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      events
                          .take(widget.calendarStyle.markersMaxCount)
                          .map(
                            (event) =>
                                _buildSingleMarker(day, event, markerSize),
                          )
                          .toList(),
                ),
              );
            }

            if (markerWidget != null) {
              children.add(markerWidget);
            }
          }

          return Stack(
            alignment: widget.calendarStyle.markersAlignment,
            clipBehavior:
                widget.calendarStyle.canMarkersOverflow
                    ? Clip.none
                    : Clip.hardEdge,
            children: children,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.headerVisible)
          ValueListenableBuilder<DateTime>(
            valueListenable: _focusedDay,
            builder: (context, value, _) {
              return TableCalendarHeader(
                locale: widget.locale,
                headerTitleBuilder: widget.calendarBuilders.headerTitleBuilder,
                focusedMonth: value,
                onLeftChevronTap: _onLeftChevronTap,
                onRightChevronTap: _onRightChevronTap,
                onHeaderTap: () => widget.onHeaderTap?.call(value),
                onHeaderLongPress: () => widget.onHeaderLongPress?.call(value),
                headerStyle: widget.headerStyle,
                availableCalendarFormats: widget.availableCalendarFormats,
                weeksPerPage: widget.weeksPerPage,
              );
            },
          ),
        Flexible(
          flex: widget.shouldFillViewport ? 1 : 0,

          // remove this stateful widget
          child: TableCalendarBase(
            domain: widget.domain,
            onCalendarCreated: _onCalendarCreated,
            focusedDay: _focusedDay.value,
            weeksPerPage: widget.weeksPerPage,
            availableGestures: widget.availableGestures,
            startingWeekday: widget.startingDayOfWeek,
            dowDecoration: widget.daysOfWeekStyle.decoration,
            rowDecoration: widget.calendarStyle.rowDecoration,
            tableBorder: widget.calendarStyle.tableBorder,
            tablePadding: widget.calendarStyle.tablePadding,
            dowVisible: widget.daysOfWeekVisible,
            dowHeight: widget.daysOfWeekHeight,
            rowHeight: widget.rowHeight,
            formatAnimationDuration: widget.formatAnimationDuration,
            formatAnimationCurve: widget.formatAnimationCurve,
            pageAnimationEnabled: widget.pageAnimationEnabled,
            pageAnimationDuration: widget.pageAnimationDuration,
            pageAnimationCurve: widget.pageAnimationCurve,
            availableCalendarFormats: widget.availableCalendarFormats,
            onVerticalSwipe: _swipeCalendarFormat,
            onPageChanged: _onPageChanged,
            weekNumbersVisible: widget.weekNumbersVisible,
            weekNumberBuilder: _weekNumbersBuilder,
            dowBuilder: _dowBuilder,
            dayBuilder: _dayBuilder,
          ),
        ),
      ],
    );
  }
}

class TableCalendarBase extends StatefulWidget {
  final DateTimeRange domain;
  final DateTime focusedDay;
  final int weeksPerPage;
  final DayBuilder? dowBuilder;
  final DayBuilder? weekNumberBuilder;
  final FocusedDayBuilder dayBuilder;
  final double? dowHeight;
  final double rowHeight;
  final bool dowVisible;
  final bool weekNumbersVisible;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;
  final EdgeInsets? tablePadding;
  final Duration formatAnimationDuration;
  final Curve formatAnimationCurve;
  final bool pageAnimationEnabled;
  final Duration pageAnimationDuration;
  final Curve pageAnimationCurve;
  final int startingWeekday;
  final AvailableGestures availableGestures;
  final Map<int, String> availableCalendarFormats;
  final void Function(DirectionIn4 swipe)? onVerticalSwipe;
  final void Function(DateTime focusedDay)? onPageChanged;
  final void Function(PageController pageController)? onCalendarCreated;

  TableCalendarBase({
    super.key,
    required this.domain,
    required this.focusedDay,
    this.weeksPerPage = 6,
    this.dowBuilder,
    required this.dayBuilder,
    this.dowHeight,
    required this.rowHeight,
    this.dowVisible = true,
    this.weekNumberBuilder,
    this.weekNumbersVisible = false,
    this.dowDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.tablePadding,
    this.formatAnimationDuration = DurationExtension.milli200,
    this.formatAnimationCurve = Curves.linear,
    this.pageAnimationEnabled = true,
    this.pageAnimationDuration = DurationExtension.milli300,
    this.pageAnimationCurve = Curves.easeOut,
    this.startingWeekday = DateTime.sunday,
    this.availableGestures = AvailableGestures.all,
    this.availableCalendarFormats = const {6: 'Month', 2: '2 Weeks', 1: 'Week'},
    this.onVerticalSwipe,
    this.onPageChanged,
    this.onCalendarCreated,
  }) : assert(!dowVisible || (dowHeight != null && dowBuilder != null)),
       assert(
         DateTimeExtension.predicateSameDate(focusedDay, domain.start) ||
             focusedDay.isAfter(domain.start),
       ),
       assert(
         DateTimeExtension.predicateSameDate(focusedDay, domain.end) ||
             focusedDay.isBefore(domain.end),
       );

  @override
  State<TableCalendarBase> createState() => _TableCalendarBaseState();
}

class _TableCalendarBaseState extends State<TableCalendarBase>
    with GestureDetectorDragMixin<TableCalendarBase> {
  late final ValueNotifier<double> _pageHeight;
  late final PageController _pageController;
  late DateTime _focusedDay;
  late int _previousIndex;
  late bool _pageCallbackDisabled;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;

    final rowCount = dm.DateTimeExtension.monthRowsOf(
      _focusedDay,
      widget.startingWeekday,
    );
    _pageHeight = ValueNotifier(_getPageHeight(rowCount));

    final initialPage = _focusedPagesOf(widget.domain.start, _focusedDay);

    _pageController = PageController(initialPage: initialPage);
    widget.onCalendarCreated?.call(_pageController);

    _previousIndex = initialPage;
    _pageCallbackDisabled = false;
  }

  void Function(int index, DateTime focusedDay) _onPageChanged(
    bool updatePageHeight,
  ) => (index, focusedDay) {
    if (!_pageCallbackDisabled) {
      if (!DateTimeExtension.predicateSameDate(_focusedDay, focusedDay)) {
        _focusedDay = focusedDay;
      }
      if (updatePageHeight) {
        final rowCount = dm.DateTimeExtension.monthRowsOf(
          focusedDay,
          widget.startingWeekday,
        );
        _pageHeight.value = _getPageHeight(rowCount);
      }

      _previousIndex = index;
      widget.onPageChanged?.call(focusedDay);
    }

    _pageCallbackDisabled = false;
  };

  ValueWidgetBuilder<double> _pageHeightBuilder(BoxConstraints constraints) =>
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
  bool get _canScrollHorizontally =>
      widget.availableGestures == AvailableGestures.all ||
      widget.availableGestures == AvailableGestures.horizontalSwipe;

  bool get _canScrollVertically =>
      widget.availableGestures == AvailableGestures.all ||
      widget.availableGestures == AvailableGestures.verticalSwipe;

  void _updatePage({bool shouldAnimate = false}) {
    final currentIndex = _focusedPagesOf(widget.domain.start, _focusedDay);
    final endIndex = _focusedPagesOf(widget.domain.start, widget.domain.end);

    if (currentIndex != _previousIndex ||
        currentIndex == 0 ||
        currentIndex == endIndex) {
      _pageCallbackDisabled = true;
    }

    if (shouldAnimate && widget.pageAnimationEnabled) {
      if ((currentIndex - _previousIndex).abs() > 1) {
        final jumpIndex =
            currentIndex > _previousIndex ? currentIndex - 1 : currentIndex + 1;

        _pageController.jumpToPage(jumpIndex);
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
    final rowCount = dm.DateTimeExtension.monthRowsOf(
      _focusedDay,
      widget.startingWeekday,
    );
    _pageHeight.value = _getPageHeight(rowCount);

    _pageCallbackDisabled = false;
  }

  double _getPageHeight(int rowCount) =>
      (widget.dowVisible ? widget.dowHeight! : 0.0) +
      rowCount * widget.rowHeight +
      (widget.tablePadding?.vertical ?? 0.0);

  int _focusedPagesOf(DateTime start, DateTime end) =>
      DateTimeRangeExtension.scopesOf(
        DateTimeRange(start: start, end: end),
        widget.startingWeekday,
        DateTime.daysPerWeek * widget.weeksPerPage,
      );

  Widget _layoutBuilder(BuildContext context, BoxConstraints constraints) =>
      GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onVerticalDragStart: _canScrollVertically ? onDragStart : null,
        onVerticalDragUpdate: _canScrollVertically ? onDragUpdateFrom() : null,
        onVerticalDragEnd:
            _canScrollVertically
                ? onDragEndFrom(
                  difference: GestureDetectorDragMixin.verticalDifference,
                  threshold: 25.0,
                  direction: GestureDetectorDragMixin.verticalForward,
                  onDrag: widget.onVerticalSwipe!,
                )
                : null,
        child: ValueListenableBuilder<double>(
          valueListenable: _pageHeight,
          builder: _pageHeightBuilder(constraints),
          child: CalendarCore(
            constraints: constraints,
            pageController: _pageController,
            scrollPhysics:
                _canScrollHorizontally
                    ? const PageScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
            domain: widget.domain,
            startingWeekday: widget.startingWeekday,
            weeksPerPage: widget.weeksPerPage,
            previousIndex: _previousIndex,
            focusedDay: _focusedDay,
            dowVisible: widget.dowVisible,
            dowHeight: widget.dowHeight,
            rowHeight: widget.rowHeight,
            weekNumbersVisible: widget.weekNumbersVisible,
            weekNumberBuilder: widget.weekNumberBuilder,
            dowDecoration: widget.dowDecoration,
            rowDecoration: widget.rowDecoration,
            tableBorder: widget.tableBorder,
            tablePadding: widget.tablePadding,
            onPageChanged: _onPageChanged(
              widget.weeksPerPage == TableCalendar.weeksPerPage_6 &&
                  !constraints.hasBoundedHeight,
            ),
            dowBuilder: widget.dowBuilder,
            dayBuilder: widget.dayBuilder,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _layoutBuilder);
  }

  @override
  void didUpdateWidget(TableCalendarBase oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_focusedDay != widget.focusedDay ||
        widget.weeksPerPage != oldWidget.weeksPerPage ||
        widget.startingWeekday != oldWidget.startingWeekday) {
      final shouldAnimate = _focusedDay != widget.focusedDay;

      _focusedDay = widget.focusedDay;
      _updatePage(shouldAnimate: shouldAnimate);
    }

    if (widget.rowHeight != oldWidget.rowHeight ||
        widget.dowHeight != oldWidget.dowHeight ||
        widget.dowVisible != oldWidget.dowVisible) {
      _pageHeight.value = _getPageHeight(
        dm.DateTimeExtension.monthRowsOf(_focusedDay, widget.startingWeekday),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageHeight.dispose();
    super.dispose();
  }
}
