// ignore_for_file: constant_identifier_names
part of '../table_calendar.dart';

///
///
/// [OnDaySelected], ...
/// [EventBuilder], ...
/// [RangeSelectionMode], ...
///
/// [TableCalendarStyle]
/// [CalendarStyleWeekNumber]
/// [CalendarStyleDayOfWeek]
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
typedef PagingDateTime = DateTime Function(DateTime date, int index);

typedef DateBuilder = Widget Function(DateTime date, dynamic locale);

typedef CellBuilder =
    Widget? Function(DateTime date, DateTime focusedDate, dynamic locale);

typedef OnTapBuilder = Widget Function(GestureTapCallback onTap);

typedef PageStepper =
    Future<void> Function({required Duration duration, required Curve curve});
typedef PageStepperBuilder = Widget Function(PageStepper stepper);

//
// 1. range == null (within range)
// 2. range == true (range start)
// 3. range == false (range end)
//
typedef HighlightRangeBuilder =
    Widget Function(DateTime date, bool? range, BoxConstraints constraints);

typedef EventBuilder<T> = Widget? Function(DateTime dateTime, T event);

typedef EventsBuilder<T> =
    Widget? Function(DateTime dateTime, List<T> events, EventBuilder<T> mark);

typedef StyleLocaleWidgetBuilder<T> = Widget Function(T style, dynamic locale);

///
///
///
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
/// [dateTextFormatter], ...
/// [rangeHighlightScale], ...
/// [_buildAnimatedContainer], ...
/// [_pagingOf], ...
///
class TableCalendarStyle {
  ///
  ///
  ///
  final dm.TextFormatter? dateTextFormatter;

  // final CalendarFormatPage format;
  final Set<int> weekendDays;
  final int startingWeekday;
  final int weeksPerPage;
  final PagingDateTime? paging;
  final Duration pageStepDuration;
  final Curve pageStepCurve;
  final ValueChanged<int>? onFormatChange;
  final List<int> availableWeeksPerPage;
  final bool verticalScrollAble;
  final ScrollPhysics? horizontalScroll;
  final int verticalFlex;

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
  final CellBuilder? _bRangeStart;
  final CellBuilder? _bRangeIn;
  final CellBuilder? _bRangeEnd;
  final HighlightRangeBuilder? _bHighlightRange;

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

  const TableCalendarStyle({
    this.dateTextFormatter,

    ///
    ///
    ///
    this.weekendDays = const {
      DateTime.saturday,
      DateTime.sunday,
    }, // ignore invalid weekend integer
    // this.format = CalendarFormatPage.month,
    this.weeksPerPage = weeksPerPage_6,
    this.availableWeeksPerPage = weeksPerPage_all,
    this.startingWeekday = DateTime.sunday,
    this.paging,
    this.pageStepDuration = DurationExtension.milli300,
    this.pageStepCurve = Curves.easeOut,
    this.onFormatChange,
    this.horizontalScroll = const PageScrollPhysics(),
    this.verticalScrollAble = true,
    this.verticalFlex = 1, // 1 expand, 0 shrink
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
    HighlightRangeBuilder? builderRangeHighlight,
  }) : _bWeekday = builderWeekday,
       _bWeekend = builderWeekend,
       _bOutside = builderOutside,
       _bToday = builderToday,
       _bHoliday = builderHoliday,
       _bDisabled = builderDisabled,
       _bSelected = builderSelected,
       _bRangeStart = builderRangeStart,
       _bRangeIn = builderRangeIn,
       _bRangeEnd = builderRangeEnd,
       _bHighlightRange = builderRangeHighlight;

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
  static Widget _buildAnimatedContainer({
    required TableCalendarStyle style,
    required Decoration? decoration,
    required String text,
    required TextStyle? textStyle,
  }) => AnimatedContainer(
    duration: style.cellAnimationDuration,
    margin: style.cellMargin,
    padding: style.cellPadding,
    decoration: decoration,
    alignment: style.cellAlignment,
    child: Text(text, style: textStyle),
  );

  static CellBuilder _builderWeekday(TableCalendarStyle style) =>
      (date, _, locale) => _buildAnimatedContainer(
        style: style,
        decoration: style.weekdayDecoration,
        text: style.dateTextFormatter?.call(date, locale) ?? '${date.day}',
        textStyle: style.weekdayTextStyle,
      );

  static CellBuilder _builderWeekend(TableCalendarStyle style) =>
      (date, _, locale) => _buildAnimatedContainer(
        style: style,
        decoration: style.weekendDecoration,
        text: style.dateTextFormatter?.call(date, locale) ?? '${date.day}',
        textStyle: style.weekendTextStyle,
      );

  static CellBuilder _builderOutside(TableCalendarStyle style) =>
      (date, _, locale) => _buildAnimatedContainer(
        style: style,
        decoration: style.outsideDecoration,
        text: style.dateTextFormatter?.call(date, locale) ?? '${date.day}',
        textStyle: style.outsideTextStyle,
      );

  static CellBuilder _builderToday(TableCalendarStyle style) =>
      (date, _, locale) => _buildAnimatedContainer(
        style: style,
        decoration: style.todayDecoration,
        text: style.dateTextFormatter?.call(date, locale) ?? '${date.day}',
        textStyle: style.todayTextStyle,
      );

  static CellBuilder _builderHoliday(TableCalendarStyle style) =>
      (date, _, locale) => _buildAnimatedContainer(
        style: style,
        decoration: style.holidayDecoration,
        text: style.dateTextFormatter?.call(date, locale) ?? '${date.day}',
        textStyle: style.holidayTextStyle,
      );

  static CellBuilder _builderDisabled(TableCalendarStyle style) =>
      (date, _, locale) => _buildAnimatedContainer(
        style: style,
        decoration: style.disabledDecoration,
        text: style.dateTextFormatter?.call(date, locale) ?? '${date.day}',
        textStyle: style.disabledTextStyle,
      );

  static CellBuilder _builderSelected(TableCalendarStyle style) =>
      (date, _, locale) => _buildAnimatedContainer(
        style: style,
        decoration: style.selectedDecoration,
        text: style.dateTextFormatter?.call(date, locale) ?? '${date.day}',
        textStyle: style.selectedTextStyle,
      );

  static CellBuilder _builderRangeWithin(TableCalendarStyle style) =>
      (date, _, locale) => _buildAnimatedContainer(
        style: style,
        decoration: style.rangeWithinDecoration,
        text: style.dateTextFormatter?.call(date, locale) ?? '${date.day}',
        textStyle: style.rangeWithinTextStyle,
      );

  static CellBuilder _builderRangeEnd(TableCalendarStyle style) =>
      (date, _, locale) => _buildAnimatedContainer(
        style: style,
        decoration: style.rangeEndDecoration,
        text: style.dateTextFormatter?.call(date, locale) ?? '${date.day}',
        textStyle: style.rangeEndTextStyle,
      );

  static CellBuilder _builderRangeStart(TableCalendarStyle style) =>
      (date, _, locale) => _buildAnimatedContainer(
        style: style,
        decoration: style.rangeStartDecoration,
        text: style.dateTextFormatter?.call(date, locale) ?? '${date.day}',
        textStyle: style.rangeStartTextStyle,
      );

  CellBuilder get builderRangeStart => _bRangeStart ?? _builderRangeStart(this);

  CellBuilder get builderRangeIn => _bRangeIn ?? _builderRangeWithin(this);

  CellBuilder get builderRangeEnd => _bRangeEnd ?? _builderRangeEnd(this);

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
  static HighlightRangeBuilder _builderHighlightRange(TableCalendarStyle style) =>
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

  HighlightRangeBuilder get builderHighlightRange =>
      _bHighlightRange ?? _builderHighlightRange(this);

  ///
  ///
  ///
  static PagingDateTime _pagingOf(int weeksPerPage) =>
      (date, index) => DateTime.utc(
        date.year,
        date.month,
        date.day + index * DateTime.daysPerWeek * weeksPerPage,
      );

  // PagingDateTime get _paging => paging ?? _pagingOf(format.weeksPerPage);
  PagingDateTime get _paging => paging ?? _pagingOf(weeksPerPage);

  int _nextWeeksPerPage() =>
      availableWeeksPerPage[(availableWeeksPerPage.indexOf(weeksPerPage) + 1) %
          availableWeeksPerPage.length];

  Widget build(
    ConstraintsBuilder layout,
    ConstraintsBuilder layoutVerticalDragAble,
  ) => Flexible(
    flex: verticalFlex,
    child: LayoutBuilder(
      builder: verticalScrollAble ? layoutVerticalDragAble : layout,
    ),
  );
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
    TableCalendarStyle style,
    CalendarStyleDayOfWeek styleDayOfWeek,
  ) =>
      (date, _, locale) => Center(
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
    required TableCalendarStyle style,
    required List<DateTime> days,
    required DateTime date,
    required dynamic locale,
  }) => TableRow(
    decoration: decoration,
    children: List.generate(
      DateTime.daysPerWeek,
      (index) => SizedBox(
        height: height,
        child: (_b ?? _builder(style, this))(days[index], date, locale),
      ),
    ),
  );
}

///
///
///
class CalendarStyleHeader {
  final void Function(DateTime focusedDay)? headerOnTap;
  final void Function(DateTime focusedDay)? headerOnLongPress;
  final EdgeInsets headerPadding;
  final EdgeInsets headerMargin;
  final BoxDecoration headerDecoration;

  ///
  ///
  ///
  final bool titleCentered;
  final dm.TextFormatter? titleTextFormatter;
  final TextStyle titleTextStyle;
  final DateBuilder? _bTitle;

  ///
  ///
  ///
  final String Function(int weeksPerPage)? formatButtonText;
  final TextStyle formatButtonTextStyle;
  final BoxDecoration formatButtonDecoration;
  final EdgeInsets formatButtonPadding;
  final bool chevronVisible;
  final Widget chevronLeft;
  final Widget chevronRight;
  final EdgeInsets chevronPadding;
  final EdgeInsets chevronMargin;
  final PageStepperBuilder? _bChevronLeft;
  final PageStepperBuilder? _bChevronRight;
  final WidgetBuilder Function(
    TableCalendarStyle style,
    CalendarStyleHeader styleHeader,
  )?
  _bFormatButton;

  const CalendarStyleHeader({
    this.headerOnTap,
    this.headerOnLongPress,
    this.headerDecoration = const BoxDecoration(),
    this.headerMargin = EdgeInsets.zero,
    this.headerPadding = const EdgeInsets.symmetric(vertical: 8.0),
    this.titleCentered = false,
    this.titleTextFormatter,
    this.titleTextStyle = const TextStyle(fontSize: 17.0),
    this.formatButtonText,
    this.formatButtonTextStyle = const TextStyle(fontSize: 14.0),
    this.formatButtonDecoration = const BoxDecoration(
      border: Border.fromBorderSide(BorderSide()),
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    ),
    this.formatButtonPadding = const EdgeInsets.symmetric(
      horizontal: 10.0,
      vertical: 4.0,
    ),
    this.chevronVisible = true,
    this.chevronPadding = const EdgeInsets.all(12.0),
    this.chevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.chevronLeft = const Icon(Icons.chevron_left),
    this.chevronRight = const Icon(Icons.chevron_right),

    DateBuilder? builderTitle,
    PageStepperBuilder? builderLeftChevron,
    PageStepperBuilder? builderRightChevron,
    WidgetBuilder Function(
      TableCalendarStyle style,
      CalendarStyleHeader styleHeader,
    )?
    builderFormatButton,
  }) : _bTitle = builderTitle,
       _bChevronLeft = builderLeftChevron,
       _bChevronRight = builderRightChevron,
       _bFormatButton = builderFormatButton;

  static DateBuilder _builderTitle(CalendarStyleHeader style) =>
      (focusedDate, locale) => Expanded(
        child: GestureDetector(
          onTap: () => style.headerOnTap?.call(focusedDate),
          onLongPress: () => style.headerOnLongPress?.call(focusedDate),
          child: Text(
            style.titleTextFormatter?.call(focusedDate, locale) ??
                DateFormat.yMMMM(locale).format(focusedDate),
            style: style.titleTextStyle,
            textAlign: style.titleCentered ? TextAlign.center : TextAlign.start,
          ),
        ),
      );

  DateBuilder get builderTitle => _bTitle ?? _builderTitle(this);

  ///
  ///
  ///
  static PageStepperBuilder _builderChevron(
    CalendarStyleHeader style,
    Widget icon,
    Duration duration,
    Curve curve,
  ) =>
      (stepper) => Padding(
        padding: style.chevronMargin,
        child: InkWell(
          onTap: () => stepper(duration: duration, curve: curve),
          borderRadius: KGeometry.borderRadius_circularAll_1 * 100,
          child: Padding(padding: style.chevronPadding, child: icon),
        ),
      );

  Widget chevron(
    DirectionIn4 direction, {
    required PageStepper iconOnTap,
    required Duration duration,
    required Curve curve,
  }) => (switch (direction) {
    DirectionIn4.left =>
      _bChevronLeft ?? _builderChevron(this, chevronLeft, duration, curve),
    DirectionIn4.right =>
      _bChevronRight ?? _builderChevron(this, chevronRight, duration, curve),
    _ => throw StateError('invalid direction $direction'),
  })(iconOnTap);

  ///
  ///
  ///
  static WidgetBuilder _builderFormatButton(
    TableCalendarStyle style,
    CalendarStyleHeader styleHeader,
  ) =>
      (context) => Padding(
        padding: KGeometry.edgeInsets_left_1 * 8,
        child: InkWell(
          borderRadius: styleHeader.formatButtonDecoration.borderRadius
              ?.resolve(context.textDirection),
          onTap: () => style.onFormatChange!(style._nextWeeksPerPage()),
          child: Container(
            decoration: styleHeader.formatButtonDecoration,
            padding: styleHeader.formatButtonPadding,
            child: Text(
              styleHeader.formatButtonText?.call(style.weeksPerPage) ??
                  '${style.weeksPerPage} weeks',
              style: styleHeader.formatButtonTextStyle,
            ),
          ),
        ),
      );

  WidgetBuilder? builderFormatButtonFrom(TableCalendarStyle style) {
    if (style.availableWeeksPerPage.length == 1) return null;
    if (style.onFormatChange == null) return null;
    return (_bFormatButton ?? _builderFormatButton)(style, this);
  }
}
