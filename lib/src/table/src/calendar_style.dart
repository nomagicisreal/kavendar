import 'package:flutter/material.dart';

///
/// [OnDaySelected]
/// [OnRangeSelected]
/// [RangeSelectionMode]
///
/// [SingleMarkerBuilder]
/// [MarkerBuilder]
/// [HighlightBuilder]
///
/// [CalendarBuilders]
/// [CalendarStyle]
/// [PositionedOffset]
/// [DaysOfWeekStyle]
/// [HeaderStyle]
///
///

typedef OnDaySelected =
    void Function(DateTime selectedDay, DateTime focusedDay);

typedef OnPageChanged = void Function(int index, DateTime focusedDay);

typedef OnRangeSelected =
    void Function(DateTime? start, DateTime? end, DateTime focusedDay);

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

///
///
///
typedef DayBuilder = Widget? Function(DateTime day);

typedef FocusedDayBuilder = Widget? Function(DateTime day, DateTime focusedDay);

typedef TextFormatter = String Function(DateTime date, dynamic locale);

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

typedef SingleMarkerBuilder<T> = Widget? Function(DateTime day, T event);

typedef MarkerBuilder<T> =
    Widget? Function(BoxConstraints constraints, DateTime day, List<T>? events);

///
///
///
///

/// Class containing all custom builders for `TableCalendar`.
class CalendarBuilders<T> {
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
  final MarkerBuilder<T>? markerBuilder;
  final DayBuilder? dowBuilder;
  final DayBuilder? headerTitleBuilder;
  final Widget? Function(int weekNumber)? weekNumberBuilder;

  const CalendarBuilders({
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
    this.markerBuilder,
    this.dowBuilder,
    this.headerTitleBuilder,
    this.weekNumberBuilder,
  });
}

/// Class containing styling and configuration for `TableCalendar`'s content.
class CalendarStyle {
  final int markersMaxCount;
  final Clip cellMarkersClip;
  final bool markersAutoAligned;

  /// Specifies the anchor point of single event markers if `markersAutoAligned` is `true`.
  /// A value of `0.5` will center the markers at the bottom edge of day cell's decoration.
  ///
  /// Includes `cellMargin` for calculations.
  final double markersAnchor;

  /// The size of single event marker dot.
  ///
  /// By default `markerSizeScale` is used. To use `markerSize` instead, simply provide a non-null value.
  final double? markerSize;

  /// Proportion of single event marker dot size in relation to day cell size.
  ///
  /// Includes `cellMargin` for calculations.
  final double markerSizeScale;

  /// `PositionedOffset` for event markers. Allows to specify `top`, `bottom`, `start` and `end`.
  final PositionedOffset markersOffset;

  /// General `Alignment` for event markers.
  /// Will have no effect on markers if `markersAutoAligned` or `markersOffset` is used.
  final AlignmentGeometry cellMarkersAlignment;

  /// Decoration of single event markers. Affects each marker dot.
  final Decoration markerDecoration;

  /// Margin of single event markers. Affects each marker dot.
  final EdgeInsets markerMargin;

  /// Margin of each individual day cell.
  final EdgeInsets cellMargin;

  /// Padding of each individual day cell.
  final EdgeInsets cellPadding;

  /// Alignment of each individual day cell.
  final AlignmentGeometry cellAlignment;

  /// Proportion of range selection highlight size in relation to day cell size.
  ///
  /// Includes `cellMargin` for calculations.
  final double rangeHighlightScale;

  /// Color of range selection highlight.
  final Color rangeHighlightColor;

  /// Determines if day cells that do not match the currently focused month should be visible.
  ///
  /// Affects only `CalendarFormat.month`.
  final bool outsideDaysVisible;

  /// Determines if a day cell that matches the current day should be highlighted.
  final bool isTodayHighlighted;

  /// TextStyle for a day cell that matches the current day.
  final TextStyle todayTextStyle;

  /// Decoration for a day cell that matches the current day.
  final Decoration todayDecoration;

  /// TextStyle for day cells that are currently marked as selected by `selectedDayPredicate`.
  final TextStyle selectedTextStyle;

  /// Decoration for day cells that are currently marked as selected by `selectedDayPredicate`.
  final Decoration selectedDecoration;

  /// TextStyle for a day cell that is the start of current range selection.
  final TextStyle rangeStartTextStyle;

  /// Decoration for a day cell that is the start of current range selection.
  final Decoration rangeStartDecoration;

  /// TextStyle for a day cell that is the end of current range selection.
  final TextStyle rangeEndTextStyle;

  /// Decoration for a day cell that is the end of current range selection.
  final Decoration rangeEndDecoration;

  /// TextStyle for day cells that fall within the currently selected range.
  final TextStyle withinRangeTextStyle;

  /// Decoration for day cells that fall within the currently selected range.
  final Decoration withinRangeDecoration;

  /// TextStyle for day cells, of which the `day.month` is different than `focusedDay.month`.
  /// This will affect day cells that do not match the currently focused month.
  final TextStyle outsideTextStyle;

  /// Decoration for day cells, of which the `day.month` is different than `focusedDay.month`.
  /// This will affect day cells that do not match the currently focused month.
  final Decoration outsideDecoration;

  /// TextStyle for day cells that have been disabled.
  ///
  /// This refers to dates disabled by returning false in `enabledDayPredicate`,
  /// as well as dates that are outside of the bounds set up by `firstDay` and `lastDay`.
  final TextStyle disabledTextStyle;

  /// Decoration for day cells that have been disabled.
  ///
  /// This refers to dates disabled by returning false in `enabledDayPredicate`,
  /// as well as dates that are outside of the bounds set up by `firstDay` and `lastDay`.
  final Decoration disabledDecoration;

  /// TextStyle for day cells that are marked as holidays by `holidayPredicate`.
  final TextStyle holidayTextStyle;

  /// Decoration for day cells that are marked as holidays by `holidayPredicate`.
  final Decoration holidayDecoration;

  /// TextStyle for day cells that match `weekendDay` list.
  final TextStyle weekendTextStyle;

  /// Decoration for day cells that match `weekendDay` list.
  final Decoration weekendDecoration;

  /// TextStyle for week number.
  final TextStyle weekNumberTextStyle;

  /// TextStyle for day cells that do not match any other styles.
  final TextStyle defaultTextStyle;

  /// Decoration for day cells that do not match any other styles.
  final Decoration defaultDecoration;

  /// Decoration for each interior row of day cells.
  final Decoration rowDecoration;

  /// Border for the internal `Table` widget.
  final TableBorder tableBorder;

  /// Padding for the internal `Table` widget.
  final EdgeInsets tablePadding;

  /// Use to customize the text within each day cell.
  /// Defaults to `'${date.day}'`, to show just the day number.
  ///
  /// Example usage:
  /// ```dart
  /// dayTextFormatter: (date, locale) => DateFormat.d(locale).format(date),
  /// ```
  final TextFormatter? dayTextFormatter;

  /// Creates a `CalendarStyle` used by `TableCalendar` widget.
  const CalendarStyle({
    this.isTodayHighlighted = true,
    this.cellMarkersClip = Clip.none,
    this.outsideDaysVisible = true,
    this.markersAutoAligned = true,
    this.markerSize,
    this.markerSizeScale = 0.2,
    this.markersAnchor = 0.7,
    this.rangeHighlightScale = 1.0,
    this.markerMargin = const EdgeInsets.symmetric(horizontal: 0.3),
    this.cellMarkersAlignment = Alignment.bottomCenter,
    this.markersMaxCount = 4,
    this.cellMargin = const EdgeInsets.all(6.0),
    this.cellPadding = EdgeInsets.zero,
    this.cellAlignment = Alignment.center,
    this.markersOffset = const PositionedOffset(),
    this.rangeHighlightColor = const Color(0xFFBBDDFF),
    this.markerDecoration = const BoxDecoration(
      color: Color(0xFF263238),
      shape: BoxShape.circle,
    ),
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
    this.withinRangeTextStyle = const TextStyle(),
    this.withinRangeDecoration = const BoxDecoration(shape: BoxShape.circle),
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
    this.rowDecoration = const BoxDecoration(),
    this.tableBorder = const TableBorder(),
    this.tablePadding = EdgeInsets.zero,
    this.dayTextFormatter,
  });
}

/// Helper class containing data for internal `Positioned` widget.
class PositionedOffset {
  /// Distance from the top edge.
  final double? top;

  /// Distance from the bottom edge.
  final double? bottom;

  /// Distance from the leading edge.
  final double? start;

  /// Distance from the trailing edge.
  final double? end;

  /// Creates a `PositionedOffset`. Values are set to `null` by default.
  const PositionedOffset({this.top, this.bottom, this.start, this.end});
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
