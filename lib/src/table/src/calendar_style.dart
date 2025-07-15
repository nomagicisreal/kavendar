part of '../table_calendar.dart';

///
///
/// [OnDaySelected], ...
/// [EventBuilder], ...
/// [RangeSelectionMode], ...
///
/// [CalendarStyle]
/// [CalendarStyleCellMarker]
/// [DaysOfWeekStyle]
/// [HeaderStyle]
///
///

///
///
///
typedef OnDaySelected =
    void Function(DateTime selectedDay, DateTime focusedDay);

typedef OnPageChanged = void Function(int index, DateTime focusedDay);

typedef OnRangeSelected =
    void Function(DateTime? start, DateTime? end, DateTime focusedDay);

///
///
///
typedef DateBuilder = Widget? Function(DateTime date);

typedef PagingDateTime = DateTime Function(DateTime date, int index);

typedef CellBuilder =
    Widget? Function(DateTime date, DateTime focusedDate, dynamic locale);

//
// 1. range == null (within range)
// 2. range == true (range start)
// 3. range == false (range end)
//
typedef RangeHighlightBuilder =
    Widget Function(DateTime date, bool? range, BoxConstraints constraints);

typedef EventBuilder<T> = Widget? Function(DateTime dateTime, T event);

typedef EventsBuilder<T> =
    Widget? Function(DateTime dateTime, List<T>? events, EventBuilder<T> mark);

///
///
///
typedef EventMark<T> =
    EventBuilder<T> Function(
      BoxConstraints constraints,
      CalendarStyleCellMarker style,
    );
typedef EventsLayoutMark<T> =
    EventsBuilder<T> Function(
      BoxConstraints constraints,
      CalendarStyleCellMarker style,
    );

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
class CalendarStyleCellMarker {
  final int max;
  final double? size;
  final double sizeScale;
  final double sizeAnchor;
  final EdgeInsets margin;
  final EdgeInsets marginCell;
  final Decoration decoration;
  final StylePositionedLayout<CalendarStyleCellMarker> childrenPosition;

  const CalendarStyleCellMarker({
    this.size,
    this.childrenPosition = _position,
    this.sizeScale = 0.2,
    this.sizeAnchor = 0.7,
    this.marginCell = EdgeInsets.zero,
    this.margin = const EdgeInsets.symmetric(horizontal: 0.3),
    this.max = 4,
    this.decoration = const BoxDecoration(
      color: Color(0xFF263238),
      shape: BoxShape.circle,
    ),
  });

  static dm.PositionedOffset _position(
    CalendarStyleCellMarker style,
    BoxConstraints constraints,
  ) {
    final shorterSide = BoxConstraintsExtension.shortSide(constraints);
    return (
      null,
      constraints.maxHeight / 2 +
          (shorterSide - style.marginCell.vertical) / 2 -
          (style.size ??
              (shorterSide - style.marginCell.vertical) *
                  style.sizeScale *
                  style.sizeAnchor),
      null,
      null,
    );
  }

  static EventBuilder<T> _singleDecoration<T>(
    BoxConstraints constraints,
    CalendarStyleCellMarker style,
  ) =>
      (day, event) => Container(
        width: style.size,
        height: style.size,
        margin: style.margin,
        decoration: style.decoration,
      );

  static EventsBuilder<T> _eventsAsPositionedRow<T>(
    BoxConstraints constraints,
    CalendarStyleCellMarker style,
  ) => (dateTime, events, mark) {
    if (events == null) return null;
    if (events.isEmpty) return null;
    final position = style.childrenPosition(style, constraints);
    return PositionedDirectional(
      start: position.$1,
      top: position.$2,
      end: position.$3,
      bottom: position.$4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: dm.IterableExt.mapToListNotNull(
          events.take(style.max),
          (event) => mark(dateTime, event),
        ),
      ),
    );
  };
}

///
///
/// [dayTextFormatter], ...
/// [rangeHighlightScale], ...
///
class CalendarStyle {
  final dm.TextFormatter? dayTextFormatter;
  final DaysOfWeekStyle? daysOfWeekStyle;
  final PagingDateTime? paging;
  final int weeksPerPage;
  final Set<int> weekendDays;
  final EdgeInsets cellMargin;
  final EdgeInsets cellPadding;
  final AlignmentGeometry cellAlignment;
  final AlignmentGeometry cellStackAlignment;
  final Duration cellAnimationDuration;
  final Clip cellStackClip;
  final double rowHeight;
  final Decoration rowDecoration;
  final TableBorder tableBorder;
  final EdgeInsets tablePadding;

  ///
  ///
  ///
  final bool weekNumberVisible;
  final TextStyle? weekNumberTextStyle;
  final TextStyle? todayTextStyle;
  final Decoration todayDecoration;
  final TextStyle? weekdayTextStyle;
  final Decoration weekdayDecoration;
  final TextStyle? holidayTextStyle;
  final Decoration holidayDecoration;
  final TextStyle? weekendTextStyle;
  final Decoration weekendDecoration;
  final TextStyle? outsideTextStyle;
  final Decoration? outsideDecoration;
  final TextStyle? disabledTextStyle;
  final Decoration disabledDecoration;
  final TextStyle? selectedTextStyle;
  final Decoration selectedDecoration;

  ///
  ///
  ///
  final CellBuilder? builderPrioritized;
  final CellBuilder? _builderWeekday;
  final CellBuilder? _builderWeekend;
  final CellBuilder? _builderOutside;
  final CellBuilder? _builderToday;
  final CellBuilder? _builderHoliday;
  final CellBuilder? _builderDisabled;
  final CellBuilder? _builderSelected;
  final CellBuilder? _builderRangeStart;
  final CellBuilder? _builderRangeIn;
  final CellBuilder? _builderRangeEnd;
  final CellBuilder? _builderDayOfWeek;
  final DateBuilder? builderHeaderTitle;
  final RangeHighlightBuilder? _builderRangeHighlight; // highlight builder ??
  final Generator<Widget>? _builderWeekNumber;

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

  const CalendarStyle({
    this.dayTextFormatter,
    this.daysOfWeekStyle,
    this.weekendDays = const {
      DateTime.saturday,
      DateTime.sunday,
    }, // ignore invalid weekend integer
    this.weeksPerPage = 6,
    this.paging,
    this.cellMargin = const EdgeInsets.all(6.0),
    this.cellPadding = EdgeInsets.zero,
    this.cellAlignment = Alignment.center,
    this.cellStackAlignment = Alignment.bottomCenter,
    this.cellStackClip = Clip.none,
    this.cellAnimationDuration = Durations.medium1,
    this.rowHeight = 52.0,
    this.rowDecoration = const BoxDecoration(),
    this.tableBorder = const TableBorder(),
    this.tablePadding = EdgeInsets.zero,

    ///
    ///
    ///
    this.weekNumberVisible = true,
    this.weekNumberTextStyle = const TextStyle(
      fontSize: 12,
      color: Color(0xFFBFBFBF),
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
    this.weekdayTextStyle = const TextStyle(),
    this.weekdayDecoration = const BoxDecoration(shape: BoxShape.circle),

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

    ///
    ///
    ///
    this.builderPrioritized,
    CellBuilder? builderWeekday,
    CellBuilder? builderWeekend,
    CellBuilder? builderOutside,
    CellBuilder? builderToday,
    CellBuilder? builderHoliday,
    CellBuilder? builderDisabled,
    CellBuilder? builderSelected,
    CellBuilder? builderRangeStart,
    CellBuilder? builderRangeIn,
    CellBuilder? builderRangeEnd,
    CellBuilder? builderDayOfWeek,
    this.builderHeaderTitle,
    RangeHighlightBuilder? builderRangeHighlight,
    Generator<Widget>? builderWeekNumber,
  }) : _builderWeekday = builderWeekday,
       _builderWeekend = builderWeekend,
       _builderOutside = builderOutside,
       _builderToday = builderToday,
       _builderHoliday = builderHoliday,
       _builderDisabled = builderDisabled,
       _builderSelected = builderSelected,
       _builderRangeStart = builderRangeStart,
       _builderRangeIn = builderRangeIn,
       _builderRangeEnd = builderRangeEnd,
       _builderDayOfWeek = builderDayOfWeek,
       _builderRangeHighlight = builderRangeHighlight,
       _builderWeekNumber = builderWeekNumber;

  static Generator<Widget> _bWeekNumber(CalendarStyle style) =>
      (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: Text(index.toString(), style: style.weekNumberTextStyle),
        ),
      );

  static CellBuilder _bDayOfWeek(CalendarStyle style) {
    final daysOfWeekStyle = style.daysOfWeekStyle!;
    return (date, _, locale) => Center(
      child: ExcludeSemantics(
        child: Text(
          daysOfWeekStyle.textFormatter(date, locale),
          style:
              style.weekendDays.contains(date.weekday)
                  ? daysOfWeekStyle.weekendStyle
                  : daysOfWeekStyle.weekdayStyle,
        ),
      ),
    );
  }

  static RangeHighlightBuilder _bRangeHighlight(CalendarStyle style) =>
      (date, range, constraints) => Center(
        child: Container(
          margin: EdgeInsetsDirectional.only(
            start: range == true ? constraints.maxWidth * 0.5 : 0.0,
            end: range == false ? constraints.maxWidth * 0.5 : 0.0,
          ),
          height:
              (BoxConstraintsExtension.shortSide(constraints) -
                  style.cellMargin.vertical) *
              style.rangeHighlightScale,
          color: style.rangeHighlightColor,
        ),
      );

  ///
  ///
  ///
  static Widget _b({
    required CalendarStyle style,
    required Decoration? decoration,
    required Text child,
  }) => AnimatedContainer(
    duration: style.cellAnimationDuration,
    margin: style.cellMargin,
    padding: style.cellPadding,
    decoration: decoration,
    alignment: style.cellAlignment,
    child: child,
  );

  static CellBuilder _bWeekday(CalendarStyle style) =>
      (date, _, locale) => _b(
        style: style,
        decoration: style.weekdayDecoration,
        child: Text(
          style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
          style: style.weekdayTextStyle,
        ),
      );

  static CellBuilder _bWeekend(CalendarStyle style) =>
      (date, _, locale) => _b(
        style: style,
        decoration: style.weekendDecoration,
        child: Text(
          style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
          style: style.weekendTextStyle,
        ),
      );

  static CellBuilder _bOutside(CalendarStyle style) =>
      (date, _, locale) => _b(
        style: style,
        decoration: style.outsideDecoration,
        child: Text(
          style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
          style: style.outsideTextStyle,
        ),
      );

  static CellBuilder _bToday(CalendarStyle style) =>
      (date, _, locale) => _b(
        style: style,
        decoration: style.todayDecoration,
        child: Text(
          style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
          style: style.todayTextStyle,
        ),
      );

  static CellBuilder _bHoliday(CalendarStyle style) =>
      (date, _, locale) => _b(
        style: style,
        decoration: style.holidayDecoration,
        child: Text(
          style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
          style: style.holidayTextStyle,
        ),
      );

  static CellBuilder _bDisabled(CalendarStyle style) =>
      (date, _, locale) => _b(
        style: style,
        decoration: style.disabledDecoration,
        child: Text(
          style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
          style: style.disabledTextStyle,
        ),
      );

  static CellBuilder _bSelected(CalendarStyle style) =>
      (date, _, locale) => _b(
        style: style,
        decoration: style.selectedDecoration,
        child: Text(
          style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
          style: style.selectedTextStyle,
        ),
      );

  static CellBuilder _bRangeWithin(CalendarStyle style) =>
      (date, _, locale) => _b(
        style: style,
        decoration: style.rangeWithinDecoration,
        child: Text(
          style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
          style: style.rangeWithinTextStyle,
        ),
      );

  static CellBuilder _bRangeEnd(CalendarStyle style) =>
      (date, _, locale) => _b(
        style: style,
        decoration: style.rangeEndDecoration,
        child: Text(
          style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
          style: style.rangeEndTextStyle,
        ),
      );

  static CellBuilder _bRangeStart(CalendarStyle style) =>
      (date, _, locale) => _b(
        style: style,
        decoration: style.rangeStartDecoration,
        child: Text(
          style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
          style: style.rangeStartTextStyle,
        ),
      );

  CellBuilder get builderRangeStart => _builderRangeStart ?? _bRangeStart(this);

  CellBuilder get builderRangeIn => _builderRangeIn ?? _bRangeWithin(this);

  CellBuilder get builderRangeEnd => _builderRangeEnd ?? _bRangeEnd(this);

  CellBuilder get builderSelected => _builderSelected ?? _bSelected(this);

  CellBuilder get builderDisabled => _builderDisabled ?? _bDisabled(this);

  CellBuilder get builderHoliday => _builderHoliday ?? _bHoliday(this);

  CellBuilder get builderToday => _builderToday ?? _bToday(this);

  CellBuilder get builderOutside => _builderOutside ?? _bOutside(this);

  CellBuilder get builderWeekend => _builderWeekend ?? _bWeekend(this);

  CellBuilder get builderWeekday => _builderWeekday ?? _bWeekday(this);

  CellBuilder get builderDayOfWeek => _builderDayOfWeek ?? _bDayOfWeek(this);

  RangeHighlightBuilder get builderRangeHighlight =>
      _builderRangeHighlight ?? _bRangeHighlight(this);

  Generator<Widget> get builderWeekNumber =>
      _builderWeekNumber ?? _bWeekNumber(this);

  // DayBuilder get _buildHeaderTitle => __buildHeaderTitle ?? _bHeaderTitle(this);

  ///
  ///
  ///
  double? _layoutRowHeight(BoxConstraints constraints) {
    final daysOfWeekStyle = this.daysOfWeekStyle;
    return constraints.hasBoundedHeight
        ? (constraints.maxHeight -
                (daysOfWeekStyle == null ? 0.0 : daysOfWeekStyle.height)) /
            weeksPerPage
        : rowHeight;
  }

  double get pageHeight {
    final daysOfWeekStyle = this.daysOfWeekStyle;
    return (daysOfWeekStyle == null ? 0.0 : daysOfWeekStyle.height) +
        weeksPerPage * rowHeight +
        (tablePadding.vertical);
  }

  static PagingDateTime _pagingOf(int weeksPerPage) =>
      (date, index) => DateTime.utc(
        date.year,
        date.month,
        date.day + index * DateTime.daysPerWeek * weeksPerPage,
      );

  PagingDateTime get _paging => paging ?? _pagingOf(weeksPerPage);
}

///
///
///
class DaysOfWeekStyle {
  final double height;
  final dm.TextFormatter textFormatter;
  final Decoration decoration;
  final TextStyle weekdayStyle;
  final TextStyle weekendStyle;

  const DaysOfWeekStyle({
    this.height = 16.0,
    this.textFormatter = _formatter,
    this.decoration = const BoxDecoration(),
    this.weekdayStyle = const TextStyle(color: Color(0xFF4F4F4F)),
    this.weekendStyle = const TextStyle(color: Color(0xFF6A6A6A)),
  });

  // Defaults to simple `'E'` format (i.e. Mon, Tue, Wed, etc.).
  static String _formatter(DateTime date, dynamic locale) =>
      DateFormat.E(locale).format(date);
}

///
///
///
class HeaderStyle {
  final void Function(int weeksPerPage)? onFormatChanged;
  final void Function(DateTime focusedDay)? onTap;
  final void Function(DateTime focusedDay)? onLongPress;

  ///
  ///
  ///
  final bool titleCentered;
  final dm.TextFormatter? titleTextFormatter;
  final TextStyle titleTextStyle;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BoxDecoration decoration;

  ///
  ///
  ///
  final bool formatButtonShowsNext;
  final TextStyle formatButtonTextStyle;
  final BoxDecoration formatButtonDecoration;
  final EdgeInsets formatButtonPadding;

  ///
  ///
  ///
  final EdgeInsets leftChevronPadding;
  final EdgeInsets leftChevronMargin;
  final Widget leftChevronIcon;
  final bool leftChevronVisible;
  final EdgeInsets rightChevronPadding;
  final EdgeInsets rightChevronMargin;
  final Widget rightChevronIcon;
  final bool rightChevronVisible;

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
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
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
