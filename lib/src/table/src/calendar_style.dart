import 'package:damath/damath.dart';
import 'package:flutter/material.dart';
import 'package:kavendar/kavendar.dart';

///
/// [OnDaySelected]
/// [OnPageChanged]
/// [OnRangeSelected]
/// [SingleMarkerBuilder]
/// [MarkerBuilder]
/// [HighlightBuilder]
///
/// [RangeSelectionMode]
///
///
/// [CalendarBuilders]
/// [CalendarStyle]
/// [PositionedOffset]
/// [DaysOfWeekStyle]
/// [HeaderStyle]
///
///

typedef PositionedOffset = (double?, double?, double?, double?);

///
///
///
typedef OnDaySelected =
    void Function(DateTime selectedDay, DateTime focusedDay);

typedef OnPageChanged = void Function(int index, DateTime focusedDay);

typedef OnRangeSelected =
    void Function(DateTime? start, DateTime? end, DateTime focusedDay);

typedef DayBuilder = Widget? Function(DateTime day);

typedef FocusedDayBuilder = Widget? Function(DateTime day, DateTime focusedDay);

typedef TextFormatter = String Function(DateTime date, dynamic locale);

///
///
///
enum RangeSelectionMode {
  disabled,
  toggledOff,
  toggledOn,
  enforced;

  bool get isToggleAble =>
      this == RangeSelectionMode.toggledOn ||
      this == RangeSelectionMode.toggledOff;

  bool get isSelectionOn =>
      this == RangeSelectionMode.toggledOn ||
      this == RangeSelectionMode.enforced;
}

enum AvailableScroll {
  none,
  onlyVertical,
  onlyHorizontal,
  both;

  static const ScrollPhysics pageScrollPhysics = PageScrollPhysics();
  static const ScrollPhysics neverScroll = NeverScrollableScrollPhysics();

  bool get canScrollHorizontal =>
      this == AvailableScroll.both || this == AvailableScroll.onlyHorizontal;

  bool get canScrollVertical =>
      this == AvailableScroll.both || this == AvailableScroll.onlyVertical;

  ScrollPhysics get scrollPhysicsVertical => switch (this) {
    AvailableScroll.none || AvailableScroll.onlyHorizontal => neverScroll,
    AvailableScroll.onlyVertical || AvailableScroll.both => pageScrollPhysics,
  };

  ScrollPhysics get scrollPhysicsHorizontal => switch (this) {
    AvailableScroll.none || AvailableScroll.onlyVertical => neverScroll,
    AvailableScroll.onlyHorizontal || AvailableScroll.both => pageScrollPhysics,
  };
}

///
///
///
///

typedef ConstraintsBuilder =
    Widget Function(BuildContext context, BoxConstraints constraints);

typedef HighlightBuilder = Widget? Function(DateTime day);

typedef MarkerBuilder<T> =
    Widget? Function(BoxConstraints constraints, DateTime day, List<T>? events);

typedef SingleMarkerBuilder<T> = Widget? Function(DateTime day, T event);

///
///
///
class CalendarBuilders<T> {
  final CalendarStyle style;
  final FocusedDayBuilder? prioritizedBuilder;
  final FocusedDayBuilder? todayBuilder;
  final FocusedDayBuilder? selectedBuilder;
  final FocusedDayBuilder? rangeStartBuilder;
  final FocusedDayBuilder? rangeEndBuilder;
  final FocusedDayBuilder? withinRangeBuilder;
  final FocusedDayBuilder? outsideBuilder;
  final FocusedDayBuilder? disabledBuilder;
  final FocusedDayBuilder? holidayBuilder;
  final FocusedDayBuilder? defaultBuilder;
  final HighlightBuilder? rangeHighlightBuilder;
  final SingleMarkerBuilder<T>? singleMarkerBuilder;
  final MarkerBuilder<T>? _markerBuilder;
  final DayBuilder? dayOfWeekBuilder;
  final DayBuilder? headerTitleBuilder;
  final Widget? Function(int weekNumber)? weekYearIndexBuilder;

  const CalendarBuilders({
    required this.style,
    this.prioritizedBuilder,
    this.todayBuilder,
    this.selectedBuilder,
    this.rangeStartBuilder,
    this.rangeEndBuilder,
    this.withinRangeBuilder,
    this.outsideBuilder,
    this.disabledBuilder,
    this.holidayBuilder,
    this.defaultBuilder,
    this.rangeHighlightBuilder,
    this.singleMarkerBuilder,
    this.dayOfWeekBuilder,
    this.headerTitleBuilder,
    this.weekYearIndexBuilder,
    MarkerBuilder<T>? markerBuilder,
  }) : _markerBuilder = markerBuilder;

  ///
  /// TODO: statically
  ///
  Widget _dayBuilderMarkerRowChild(DateTime day, T event, double markerSize) =>
      singleMarkerBuilder?.call(day, event) ??
      Container(
        width: markerSize,
        height: markerSize,
        margin: style.marker!.cellMarkerMargin,
        decoration: style.marker!.cellMarkerDecoration,
      );

  Widget? _dayBuilderMarker(
    BoxConstraints constraints,
    DateTime day,
    List<T>? events,
  ) {
    if (events == null) return null;
    if (events.isEmpty) return null;
    final center = constraints.maxHeight / 2;
    final shorterSide = BoxConstraintsExtension.shortSide(constraints);

    final markerSize =
        style.marker!.cellMarkerSize ??
        (shorterSide - style.cellMargin.vertical) *
            style.marker!.cellMarkerSizeScale;

    return PositionedDirectional(
      start: style.marker!.getMarkerPosition(DirectionIn4.left),
      top: style.marker!.getMarkerPosition(
        DirectionIn4.top,
        center +
            (shorterSide - style.cellMargin.vertical) / 2 -
            (markerSize * style.marker!.cellMarkersAnchor),
      ),
      end: style.marker!.getMarkerPosition(DirectionIn4.right),
      bottom: style.marker!.getMarkerPosition(DirectionIn4.bottom),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            events
                .take(style.marker!.cellMarkersMax)
                .map((e) => _dayBuilderMarkerRowChild(day, e, markerSize))
                .toList(),
      ),
    );
  }

  MarkerBuilder<T> get markerBuilder => _markerBuilder ?? _dayBuilderMarker;
}

///
///
///
class CalendarMarker {
  final int cellMarkersMax;
  final double cellMarkersAnchor;
  final PositionedOffset? cellMarkersPosition;
  final double? cellMarkerSize;
  final double cellMarkerSizeScale;
  final Decoration cellMarkerDecoration;
  final EdgeInsets cellMarkerMargin;

  const CalendarMarker({
    this.cellMarkerSize,
    this.cellMarkersPosition,
    this.cellMarkerSizeScale = 0.2,
    this.cellMarkersAnchor = 0.7,
    this.cellMarkerMargin = const EdgeInsets.symmetric(horizontal: 0.3),
    this.cellMarkersMax = 4,
    this.cellMarkerDecoration = const BoxDecoration(
      color: Color(0xFF263238),
      shape: BoxShape.circle,
    ),
  });

  double? getMarkerPosition(DirectionIn4 direction, [double? positionDefault]) {
    final position = cellMarkersPosition;
    return position == null
        ? positionDefault
        : switch (direction) {
          DirectionIn4.left => position.$1,
          DirectionIn4.top => position.$2,
          DirectionIn4.right => position.$3,
          DirectionIn4.bottom => position.$4,
        };
  }
}

///
///
/// [dayTextFormatter], ...
/// [todayIsHighlighted], ...
/// [rangeHighlightScale], ...
///
class CalendarStyle {
  final TextFormatter? dayTextFormatter;
  final EdgeInsets cellMargin;
  final EdgeInsets cellPadding;
  final AlignmentGeometry cellAlignment;
  final AlignmentGeometry cellStackAlignment;
  final Clip cellStackClip;
  final TextStyle weekNumberTextStyle;
  final Decoration rowDecoration;
  final TableBorder tableBorder;
  final EdgeInsets tablePadding;

  ///
  ///
  ///
  final bool todayIsHighlighted;
  final TextStyle todayTextStyle;
  final Decoration todayDecoration;
  final TextStyle defaultTextStyle;
  final Decoration defaultDecoration;
  final TextStyle holidayTextStyle;
  final Decoration holidayDecoration;
  final TextStyle weekendTextStyle;
  final Decoration weekendDecoration;
  final TextStyle outsideTextStyle;
  final Decoration? outsideDecoration;
  final TextStyle disabledTextStyle;
  final Decoration disabledDecoration;
  final TextStyle selectedTextStyle;
  final Decoration selectedDecoration;

  ///
  ///
  ///
  final double rangeHighlightScale;
  final Color rangeHighlightColor;
  final TextStyle rangeStartTextStyle;
  final Decoration rangeStartDecoration;
  final TextStyle rangeEndTextStyle;
  final Decoration rangeEndDecoration;
  final TextStyle rangeWithinTextStyle;
  final Decoration rangeWithinDecoration;

  ///
  ///
  ///
  final CalendarMarker? marker;

  // TODO: to constant values
  const CalendarStyle({
    this.dayTextFormatter,
    this.cellMargin = const EdgeInsets.all(6.0),
    this.cellPadding = EdgeInsets.zero,
    this.cellAlignment = Alignment.center,
    this.cellStackAlignment = Alignment.bottomCenter,
    this.cellStackClip = Clip.none,
    this.rowDecoration = const BoxDecoration(),
    this.tableBorder = const TableBorder(),
    this.tablePadding = EdgeInsets.zero,

    ///
    ///
    ///
    this.todayIsHighlighted = true,
    this.todayTextStyle = const TextStyle(
      color: Color(0xFFFAFAFA),
      fontSize: 16.0,
    ), //
    this.todayDecoration = const BoxDecoration(
      color: Color(0xFF9FA8DA),
      shape: BoxShape.circle,
    ),
    this.selectedTextStyle = const TextStyle(
      color: Color(0xFFFAFAFA),
      fontSize: 16.0,
    ),
    this.selectedDecoration = const BoxDecoration(
      color: Color(0xFF5C6BC0),
      shape: BoxShape.circle,
    ),
    this.outsideTextStyle = const TextStyle(color: Color(0xFFAEAEAE)),
    this.outsideDecoration = const BoxDecoration(shape: BoxShape.circle),
    this.disabledTextStyle = const TextStyle(color: Color(0xFFBFBFBF)),
    this.disabledDecoration = const BoxDecoration(shape: BoxShape.circle),
    this.holidayTextStyle = const TextStyle(color: Color(0xFF5C6BC0)),
    this.holidayDecoration = const BoxDecoration(
      border: Border.fromBorderSide(
        BorderSide(color: Color(0xFF9FA8DA), width: 1.4),
      ),
      shape: BoxShape.circle,
    ),
    this.weekendTextStyle = const TextStyle(color: Color(0xFF5A5A5A)),
    this.weekendDecoration = const BoxDecoration(shape: BoxShape.circle),
    this.weekNumberTextStyle = const TextStyle(
      fontSize: 12,
      color: Color(0xFFBFBFBF),
    ),
    this.defaultTextStyle = const TextStyle(),
    this.defaultDecoration = const BoxDecoration(shape: BoxShape.circle),

    ///
    ///
    ///
    this.rangeHighlightScale = 1.0,
    this.rangeHighlightColor = const Color(0xFFBBDDFF),
    this.rangeStartTextStyle = const TextStyle(
      color: Color(0xFFFAFAFA),
      fontSize: 16.0,
    ),
    this.rangeStartDecoration = const BoxDecoration(
      color: Color(0xFF6699FF),
      shape: BoxShape.circle,
    ),
    this.rangeEndTextStyle = const TextStyle(
      color: Color(0xFFFAFAFA),
      fontSize: 16.0,
    ),
    this.rangeEndDecoration = const BoxDecoration(
      color: Color(0xFF6699FF),
      shape: BoxShape.circle,
    ),
    this.rangeWithinTextStyle = const TextStyle(),
    this.rangeWithinDecoration = const BoxDecoration(shape: BoxShape.circle),
    this.marker,
  });
}

/// Class containing styling for `TableCalendar`'s days of week panel.
class DaysOfWeekStyle {
  /// Use to customize days of week panel text (e.g. with different `DateFormat`).
  /// You can use `String` transformations to further customize the text.
  /// Defaults to simple `'E'` format (i.e. Mon, Tue, Wed, etc.).
  ///
  /// Example usage:
  /// ```dart
  /// dowTextFormatter: (date, locale) => DateFormat.E(locale).format(date)[0],
  /// ```
  final TextFormatter? dowTextFormatter;

  /// Decoration for the top row of the table
  final Decoration decoration;

  /// Style for weekdays on the top of calendar.
  final TextStyle weekdayStyle;

  /// Style for weekend days on the top of calendar.
  final TextStyle weekendStyle;

  /// Creates a `DaysOfWeekStyle` used by `TableCalendar` widget.
  const DaysOfWeekStyle({
    this.dowTextFormatter,
    this.decoration = const BoxDecoration(),
    this.weekdayStyle = const TextStyle(color: Color(0xFF4F4F4F)),
    this.weekendStyle = const TextStyle(color: Color(0xFF6A6A6A)),
  });
}

/// Class containing styling and configuration of `TableCalendar`'s header.
class HeaderStyle {
  final void Function(int weeksPerPage)? onFormatChanged;
  final void Function(DateTime focusedDay)? onTap;
  final void Function(DateTime focusedDay)? onLongPress;
  final bool titleCentered;
  final bool formatButtonShowsNext;
  final TextFormatter? titleTextFormatter;
  final TextStyle titleTextStyle;

  /// Style for FormatButton `Text`.
  final TextStyle formatButtonTextStyle;

  /// Background `Decoration` for FormatButton.
  final BoxDecoration formatButtonDecoration;

  /// Internal padding of the whole header.
  final EdgeInsets headerPadding;

  /// External margin of the whole header.
  final EdgeInsets headerMargin;

  /// Internal padding of FormatButton.
  final EdgeInsets formatButtonPadding;

  /// Internal padding of left chevron.
  /// Determines how much of ripple animation is visible during taps.
  final EdgeInsets leftChevronPadding;

  /// Internal padding of right chevron.
  /// Determines how much of ripple animation is visible during taps.
  final EdgeInsets rightChevronPadding;

  /// External margin of left chevron.
  final EdgeInsets leftChevronMargin;

  /// External margin of right chevron.
  final EdgeInsets rightChevronMargin;

  /// Widget used for left chevron.
  ///
  /// Tapping on it will navigate to previous calendar page.
  final Widget leftChevronIcon;

  /// Widget used for right chevron.
  ///
  /// Tapping on it will navigate to next calendar page.
  final Widget rightChevronIcon;

  /// Determines left chevron's visibility.
  final bool leftChevronVisible;

  /// Determines right chevron's visibility.
  final bool rightChevronVisible;

  /// Decoration of the header.
  final BoxDecoration decoration;

  /// Creates a `HeaderStyle` used by `TableCalendar` widget.
  const HeaderStyle({
    this.onFormatChanged,
    this.onTap,
    this.onLongPress,
    this.titleCentered = false,
    this.formatButtonShowsNext = true,
    this.titleTextFormatter,
    this.titleTextStyle = const TextStyle(fontSize: 17.0),
    this.formatButtonTextStyle = const TextStyle(fontSize: 14.0),
    this.formatButtonDecoration = const BoxDecoration(
      border: Border.fromBorderSide(BorderSide()),
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    ),
    this.headerMargin = EdgeInsets.zero,
    this.headerPadding = const EdgeInsets.symmetric(vertical: 8.0),
    this.formatButtonPadding = const EdgeInsets.symmetric(
      horizontal: 10.0,
      vertical: 4.0,
    ),
    this.leftChevronPadding = const EdgeInsets.all(12.0),
    this.rightChevronPadding = const EdgeInsets.all(12.0),
    this.leftChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.rightChevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.leftChevronIcon = const Icon(Icons.chevron_left),
    this.rightChevronIcon = const Icon(Icons.chevron_right),
    this.leftChevronVisible = true,
    this.rightChevronVisible = true,
    this.decoration = const BoxDecoration(),
  });
}
