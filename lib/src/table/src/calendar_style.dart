// ignore_for_file: constant_identifier_names
part of '../table_calendar.dart';

///
///
/// [OnDaySelected], ...
/// [EventBuilder], ...
/// [RangeSelectionMode], ...
///
/// [CalendarStyle]
/// [CalendarStyleWeekNumber]
/// [CalendarStyleDayOfWeek]
/// [CalendarStyleCellMark]
/// [CalendarStyleCellRange]
///
///

///
///
///
typedef OnPageChanged = void Function(int index, DateTime focusedDay);

typedef OnDaySelected =
    void Function(DateTime selectedDay, DateTime focusedDay);

typedef OnRangeSelected =
    void Function(DateTime? start, DateTime? end, DateTime focusedDay);

//
typedef PagingDateTime = DateTime Function(DateTime date, int index);

typedef DateBuilder = Widget Function(DateTime date, dynamic locale);

typedef CellBuilder =
    Widget Function(
      DateTime date,
      DateTime focusedDate,
      dynamic locale,
      BoxConstraints constraints,
    );

typedef PageStepper =
    Future<void> Function({required Duration duration, required Curve curve});

typedef PageStepperBuilder = Widget Function(PageStepper stepper);

//
typedef HighlightRangeBuilder =
    Widget Function(RangeState state, BoxConstraints constraints);

typedef BoxConstraintsDouble = double Function(BoxConstraints constraints);

typedef HighlightWidthFrom<T> = BoxConstraintsDouble Function(T style);

//
typedef EventBuilder<T> = Widget? Function(DateTime dateTime, T event);

typedef EventsBuilder<T> =
    Widget? Function(DateTime dateTime, List<T> events, EventBuilder<T> mark);

typedef EventMark<T> =
    EventBuilder<T> Function(
      BoxConstraints constraints,
      CalendarStyleCellMark style,
    );
typedef EventsLayoutMark<T> =
    EventsBuilder<T> Function(
      BoxConstraints constraints,
      CalendarStyleCellMark style,
    );

///
///
///
enum RangeState { beforeStart, onStart, within, onEnd, afterEnd }

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
/// [dateTextFormatter], ...
/// [rangeHighlightScale], ...
/// [_buildContainer], ...
/// [_pagingOf], ...
///
class CalendarStyle {
  ///
  ///
  ///
  final dm.TextFormatter? dateTextFormatter;

  // final CalendarFormatPage format;
  final Set<int> weekendDays;
  final int startingWeekday;
  final int initialWeeksPerPage;
  final PagingDateTime? paging;
  final Duration pageStepDuration;
  final Curve pageStepCurve;
  final ValueChanged<int>? onFormatChanged;
  final List<int> availableWeeksPerPage;
  final bool verticalScrollAble;
  final ScrollPhysics? horizontalScroll;
  final int verticalFlex;

  ///
  ///
  ///
  final CalendarStyleDayOfWeek? styleDayOfWeek;
  final CalendarStyleWeekNumber? styleWeekNumber;
  final CalendarStyleCellMark? styleCellMark;
  final CalendarStyleCellRange? styleCellRange;

  ///
  ///
  ///
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
  final CellBuilder? _bWeekday;
  final CellBuilder? _bWeekend;
  final CellBuilder? _bOutside;
  final CellBuilder? _bToday;
  final CellBuilder? _bHoliday;
  final CellBuilder? _bDisabled;
  final CellBuilder? _bSelected;

  const CalendarStyle({
    this.dateTextFormatter,

    ///
    ///
    ///
    this.weekendDays = const {
      DateTime.saturday,
      DateTime.sunday,
    }, // ignore invalid weekend integer
    // this.format = CalendarFormatPage.month,
    this.initialWeeksPerPage = weeksPerPage_6,
    this.availableWeeksPerPage = weeksPerPage_all,
    this.startingWeekday = DateTime.sunday,
    this.paging,
    this.pageStepDuration = DurationExtension.milli300,
    this.pageStepCurve = Curves.easeOut,
    this.onFormatChanged,
    this.horizontalScroll = const PageScrollPhysics(),
    this.verticalScrollAble = true,
    this.verticalFlex = 1, // 1 expand, 0 shrink
    ///
    ///
    ///
    this.styleDayOfWeek = const CalendarStyleDayOfWeek(),
    this.styleWeekNumber = const CalendarStyleWeekNumber(),
    this.styleCellMark = const CalendarStyleCellMark(),
    this.styleCellRange = const CalendarStyleCellRange(),

    ///
    ///
    ///
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
    this.builderPrioritized,
    CellBuilder? builderWeekday,
    CellBuilder? builderWeekend,
    CellBuilder? builderOutside,
    CellBuilder? builderToday,
    CellBuilder? builderHoliday,
    CellBuilder? builderDisabled,
    CellBuilder? builderSelected,
  }) : _bWeekday = builderWeekday,
       _bWeekend = builderWeekend,
       _bOutside = builderOutside,
       _bToday = builderToday,
       _bHoliday = builderHoliday,
       _bDisabled = builderDisabled,
       _bSelected = builderSelected;

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

  ///
  ///
  ///
  static Widget _buildContainer({
    required DateTime date,
    required CalendarStyle style,
    required dynamic locale,
    required Decoration? decoration,
    required TextStyle? textStyle,
  }) => Semantics(
    key: ValueKey('Cell-${date.year}-${date.month}-${date.day}'),
    label:
        '${DateFormat.EEEE(locale).format(date)}, '
        '${DateFormat.yMMMMd(locale).format(date)}',
    excludeSemantics: true,
    child: AnimatedContainer(
      duration: style.cellAnimationDuration,
      margin: style.cellMargin,
      padding: style.cellPadding,
      decoration: decoration,
      alignment: style.cellAlignment,
      child: Text(
        style.dateTextFormatter?.call(date, locale) ?? '${date.day}',
        style: textStyle,
      ),
    ),
  );

  static CellBuilder _builderWeekday(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.weekdayDecoration,
        textStyle: style.weekdayTextStyle,
      );

  static CellBuilder _builderWeekend(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.weekendDecoration,
        textStyle: style.weekendTextStyle,
      );

  static CellBuilder _builderOutside(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.outsideDecoration,
        textStyle: style.outsideTextStyle,
      );

  static CellBuilder _builderToday(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.todayDecoration,
        textStyle: style.todayTextStyle,
      );

  static CellBuilder _builderHoliday(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.holidayDecoration,
        textStyle: style.holidayTextStyle,
      );

  static CellBuilder _builderDisabled(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.disabledDecoration,
        textStyle: style.disabledTextStyle,
      );

  static CellBuilder _builderSelected(CalendarStyle style) =>
      (date, _, locale, __) => _buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: style.selectedDecoration,
        textStyle: style.selectedTextStyle,
      );

  CellBuilder get builderSelected => _bSelected ?? _builderSelected(this);

  CellBuilder get builderDisabled => _bDisabled ?? _builderDisabled(this);

  CellBuilder get builderHoliday => _bHoliday ?? _builderHoliday(this);

  CellBuilder get builderToday => _bToday ?? _builderToday(this);

  CellBuilder get builderOutside => _bOutside ?? _builderOutside(this);

  CellBuilder get builderWeekend => _bWeekend ?? _builderWeekend(this);

  CellBuilder get builderWeekday => _bWeekday ?? _builderWeekday(this);

  ///
  ///
  ///
  static PagingDateTime _pagingOf(int weeksPerPage) =>
      (date, index) => DateTime.utc(
        date.year,
        date.month,
        date.day + index * DateTime.daysPerWeek * weeksPerPage,
      );

  PagingDateTime _paging(int indexWeeksPerPage) =>
      paging ?? _pagingOf(availableWeeksPerPage[indexWeeksPerPage]);

  int weeksPerPage(int index) => availableWeeksPerPage[index];

  // Widget _layoutCell(BuildContext context, BoxConstraints constraints)
}

class CalendarStyleWeekNumber {
  final TextStyle? textStyle;

  const CalendarStyleWeekNumber({
    this.textStyle = const TextStyle(fontSize: 12, color: Color(0xFFBFBFBF)),
  });

  Widget build(List<DateTime> visibleDates, double? heightEach) => Column(
    children: List.generate(
      visibleDates.length ~/ 7,
      (index) => Expanded(
        child: SizedBox(
          height: heightEach,
          child: Padding(
            padding: KGeometry.edgeInsets_horizontal_1 * 4,
            child: Center(
              child: Text(
                dm.DateTimeExtension.weekNumberInYearOf(
                  visibleDates[index * 7],
                ).toString(),
                style: textStyle,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

///
///
///
class CalendarStyleDayOfWeek {
  final double height;
  final dm.TextFormatter textFormatter;
  final Decoration decoration;
  final TextStyle weekdayStyle;
  final TextStyle weekendStyle;
  final CellBuilder? _b;

  const CalendarStyleDayOfWeek({
    this.height = 16.0,
    this.textFormatter = _formatter,
    this.decoration = const BoxDecoration(),
    this.weekdayStyle = const TextStyle(color: Color(0xFF4F4F4F)),
    this.weekendStyle = const TextStyle(color: Color(0xFF6A6A6A)),
    CellBuilder? builderDayOfWeek,
  }) : _b = builderDayOfWeek;

  // Defaults to simple `'E'` format (i.e. Mon, Tue, Wed, etc.).
  static String _formatter(DateTime date, dynamic locale) =>
      DateFormat.E(locale).format(date);

  static CellBuilder _builder(
    CalendarStyle style,
    CalendarStyleDayOfWeek styleDayOfWeek,
  ) =>
      (date, _, locale, __) => Center(
        child: ExcludeSemantics(
          child: Text(
            styleDayOfWeek.textFormatter(date, locale),
            style:
                style.weekendDays.contains(date.weekday)
                    ? styleDayOfWeek.weekendStyle
                    : styleDayOfWeek.weekdayStyle,
          ),
        ),
      );

  TableRow buildTableRow({
    required CalendarStyle style,
    required List<DateTime> days,
    required DateTime date,
    required dynamic locale,
    required BoxConstraints constraints,
  }) {
    final builder = _b ?? _builder(style, this);
    return TableRow(
      decoration: decoration,
      children: List.generate(
        DateTime.daysPerWeek,
        (index) => SizedBox(
          height: height,
          child: builder(days[index], date, locale, constraints),
        ),
      ),
    );
  }
}

///
///
///
class CalendarStyleCellMark {
  final int max;
  final bool forDisabledCell;
  final double? size;
  final double sizeScale;
  final double sizeAnchor;
  final EdgeInsets margin;
  final EdgeInsets marginCell;
  final Decoration decoration;
  final StylePositionedLayout<CalendarStyleCellMark> childrenPosition;

  const CalendarStyleCellMark({
    this.max = 4,
    this.forDisabledCell = true,
    this.size,
    this.sizeScale = 0.2,
    this.sizeAnchor = 0.7,
    this.marginCell = EdgeInsets.zero,
    this.margin = const EdgeInsets.symmetric(horizontal: 0.3),
    this.decoration = const BoxDecoration(
      color: Color(0xFF263238),
      shape: BoxShape.circle,
    ),
    this.childrenPosition = _position,
  });

  static dm.PositionedOffset _position(
    CalendarStyleCellMark style,
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
    CalendarStyleCellMark style,
  ) =>
      (day, event) => Container(
        width: style.size,
        height: style.size,
        margin: style.margin,
        decoration: style.decoration,
      );

  static EventsBuilder<T> _eventsAsPositionedRow<T>(
    BoxConstraints constraints,
    CalendarStyleCellMark style,
  ) => (dateTime, events, mark) {
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
///
class CalendarStyleCellRange {
  final CellBuilder? _bRangeStart;
  final CellBuilder? _bRangeIn;
  final CellBuilder? _bRangeEnd;
  final HighlightRangeBuilder? _bHighlightRange;
  final HighlightWidthFrom<CalendarStyle> widthFrom;

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

  const CalendarStyleCellRange({
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
    CellBuilder? builderRangeStart,
    CellBuilder? builderRangeIn,
    CellBuilder? builderRangeEnd,
    HighlightRangeBuilder? builderRangeHighlight,
    this.widthFrom = _widthFrom,
  }) : _bRangeStart = builderRangeStart,
       _bRangeIn = builderRangeIn,
       _bRangeEnd = builderRangeEnd,
       _bHighlightRange = builderRangeHighlight;

  static CellBuilder _builderRangeWithin(
    CalendarStyle style,
    CalendarStyleCellRange styleRange,
  ) =>
      (date, _, locale, __) => CalendarStyle._buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: styleRange.rangeWithinDecoration,
        textStyle: styleRange.rangeWithinTextStyle,
      );

  static CellBuilder _builderRangeEnd(
    CalendarStyle style,
    CalendarStyleCellRange styleRange,
  ) =>
      (date, _, locale, __) => CalendarStyle._buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: styleRange.rangeEndDecoration,
        textStyle: styleRange.rangeEndTextStyle,
      );

  static CellBuilder _builderRangeStart(
    CalendarStyle style,
    CalendarStyleCellRange styleRange,
  ) =>
      (date, _, locale, __) => CalendarStyle._buildContainer(
        date: date,
        style: style,
        locale: locale,
        decoration: styleRange.rangeStartDecoration,
        textStyle: styleRange.rangeStartTextStyle,
      );

  CellBuilder builderRangeStart(CalendarStyle style) =>
      _bRangeStart ?? _builderRangeStart(style, this);

  CellBuilder builderRangeIn(CalendarStyle style) =>
      _bRangeIn ?? _builderRangeWithin(style, this);

  CellBuilder builderRangeEnd(CalendarStyle style) =>
      _bRangeEnd ?? _builderRangeEnd(style, this);

  ///
  ///
  ///
  static HighlightRangeBuilder _builderHighlightRange(
    BoxConstraintsDouble doubleFrom,
    CalendarStyleCellRange styleRange,
  ) =>
      (s, constraints) => Center(
        child: Container(
          margin: EdgeInsetsDirectional.only(
            start: s == RangeState.onStart ? constraints.maxWidth * 0.5 : 0.0,
            end: s == RangeState.onEnd ? constraints.maxWidth * 0.5 : 0.0,
          ),
          height: doubleFrom(constraints) * styleRange.rangeHighlightScale,
          color: styleRange.rangeHighlightColor,
        ),
      );

  static BoxConstraintsDouble _widthFrom(CalendarStyle style) =>
      (constraints) =>
          BoxConstraintsExtension.shortSide(constraints) -
          style.cellMargin.vertical;

  HighlightRangeBuilder _builderFrom(BoxConstraintsDouble doubleFrom) =>
      _bHighlightRange ?? _builderHighlightRange(doubleFrom, this);

  ///
  ///
  /// selected date changed
  /// 0. reset
  /// 1. rangeStart == null -> find range start date
  /// 2. rangeStart != null, rangeEnd == null -> find another range date, range within date(s), unselect rangeStart
  /// 3. rangeStart != null, rangeEnd != null -> expand range, shrink range, unselect rangeEnd
  ///
  ///
  // ConstraintsBuilder? builderFrom(CalendarStyle style, DateTime date) {
  //   // TODO: combine rangeStart and rangeEnd into 1 value notifier
  //   final rangeStart = _rangeStart;
  //   if (rangeStart == null) return null;
  //   if (date.isBefore(rangeStart)) return null;
  //   if (date.isAfter(rangeStart)) {
  //     final rangeEnd = this.rangeEnd;
  //     if (rangeEnd == null) return null;
  //     if (date.isAfter(rangeEnd)) return null;
  //
  //     final builder = _builderFrom(widthFrom(style));
  //     if (date.isBefore(rangeEnd)) {
  //       return (_, constraints) => builder(RangeState.within, constraints);
  //     }
  //     return (_, constraints) => builder(RangeState.onEnd, constraints);
  //   }
  //   final builder = _builderFrom(widthFrom(style));
  //   return (_, constraints) => builder(RangeState.onStart, constraints);
  // }
}
