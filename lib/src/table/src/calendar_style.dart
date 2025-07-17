// ignore_for_file: constant_identifier_names
part of '../table_calendar.dart';

///
///
/// [OnDaySelected], ...
/// [EventBuilder], ...
/// [RangeSelectionMode], ...
///
/// [CalendarFormatPage], ...
/// [DaysOfWeekStyle], ...
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
typedef RangeHighlightBuilder =
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

  ScrollPhysics get scrollPhysicsVertical =>
      switch (this) {
        AvailableScroll.none || AvailableScroll.onlyHorizontal => neverScroll,
        AvailableScroll.onlyVertical || AvailableScroll
            .both => pageScrollPhysics,
      };

  ScrollPhysics get scrollPhysicsHorizontal =>
      switch (this) {
        AvailableScroll.none || AvailableScroll.onlyVertical => neverScroll,
        AvailableScroll.onlyHorizontal || AvailableScroll
            .both => pageScrollPhysics,
      };
}

///
///
///
class CalendarStyleCellMark {
  final int max;
  final bool forDisable;
  final double? size;
  final double sizeScale;
  final double sizeAnchor;
  final EdgeInsets margin;
  final EdgeInsets marginCell;
  final Decoration decoration;
  final StylePositionedLayout<CalendarStyleCellMark> childrenPosition;

  const CalendarStyleCellMark({
    this.max = 4,
    this.forDisable = true,
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

  static dm.PositionedOffset _position(CalendarStyleCellMark style,
      BoxConstraints constraints,) {
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

  static EventBuilder<T> _singleDecoration<T>(BoxConstraints constraints,
      CalendarStyleCellMark style,) =>
          (day, event) =>
          Container(
            width: style.size,
            height: style.size,
            margin: style.margin,
            decoration: style.decoration,
          );

  static EventsBuilder<T> _eventsAsPositionedRow<T>(BoxConstraints constraints,
      CalendarStyleCellMark style,) =>
          (dateTime, events, mark) {
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
  ///
  ///
  ///
  final dm.TextFormatter? dayTextFormatter;
  final DaysOfWeekStyle? daysOfWeekStyle;
  final bool weekNumberVisible;

  // final CalendarFormatPage format;
  final int weeksPerPage;
  final List<int> availableWeeksPerPage;
  final Set<int> weekendDays;
  final int startingWeekday;
  final PagingDateTime? paging;
  final Duration pageStepDuration;
  final Curve pageStepCurve;
  final ValueChanged<int>? onFormatChange;

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
  final CellBuilder? _bDayOfWeek;
  final RangeHighlightBuilder? _bRangeHighlight; // highlight builder ??
  final Generator<Widget>? _bWeekNumber;

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
    this.weekNumberVisible = true,
    this.weekendDays = const {
      DateTime.saturday,
      DateTime.sunday,
    }, // ignore invalid weekend integer
    this.availableWeeksPerPage = weeksPerPage_all,
    // this.format = CalendarFormatPage.month,
    this.weeksPerPage = 6,
    this.startingWeekday = DateTime.sunday,
    this.paging,
    this.pageStepDuration = DurationExtension.milli300,
    this.pageStepCurve = Curves.easeOut,
    this.onFormatChange,

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
    RangeHighlightBuilder? builderRangeHighlight,
    Generator<Widget>? builderWeekNumber,
  })
      : _bWeekday = builderWeekday,
        _bWeekend = builderWeekend,
        _bOutside = builderOutside,
        _bToday = builderToday,
        _bHoliday = builderHoliday,
        _bDisabled = builderDisabled,
        _bSelected = builderSelected,
        _bRangeStart = builderRangeStart,
        _bRangeIn = builderRangeIn,
        _bRangeEnd = builderRangeEnd,
        _bDayOfWeek = builderDayOfWeek,
        _bRangeHighlight = builderRangeHighlight,
        _bWeekNumber = builderWeekNumber;

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
  static Widget _b({
    required CalendarStyle style,
    required Decoration? decoration,
    required String text,
    required TextStyle? textStyle,
  }) =>
      AnimatedContainer(
        duration: style.cellAnimationDuration,
        margin: style.cellMargin,
        padding: style.cellPadding,
        decoration: decoration,
        alignment: style.cellAlignment,
        child: Text(text, style: textStyle),
      );

  static CellBuilder _builderWeekday(CalendarStyle style) =>
          (date, _, locale) =>
          _b(
            style: style,
            decoration: style.weekdayDecoration,
            text: style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
            textStyle: style.weekdayTextStyle,
          );

  static CellBuilder _builderWeekend(CalendarStyle style) =>
          (date, _, locale) =>
          _b(
            style: style,
            decoration: style.weekendDecoration,
            text: style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
            textStyle: style.weekendTextStyle,
          );

  static CellBuilder _builderOutside(CalendarStyle style) =>
          (date, _, locale) =>
          _b(
            style: style,
            decoration: style.outsideDecoration,
            text: style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
            textStyle: style.outsideTextStyle,
          );

  static CellBuilder _builderToday(CalendarStyle style) =>
          (date, _, locale) =>
          _b(
            style: style,
            decoration: style.todayDecoration,
            text: style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
            textStyle: style.todayTextStyle,
          );

  static CellBuilder _builderHoliday(CalendarStyle style) =>
          (date, _, locale) =>
          _b(
            style: style,
            decoration: style.holidayDecoration,
            text: style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
            textStyle: style.holidayTextStyle,
          );

  static CellBuilder _builderDisabled(CalendarStyle style) =>
          (date, _, locale) =>
          _b(
            style: style,
            decoration: style.disabledDecoration,
            text: style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
            textStyle: style.disabledTextStyle,
          );

  static CellBuilder _builderSelected(CalendarStyle style) =>
          (date, _, locale) =>
          _b(
            style: style,
            decoration: style.selectedDecoration,
            text: style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
            textStyle: style.selectedTextStyle,
          );

  static CellBuilder _builderRangeWithin(CalendarStyle style) =>
          (date, _, locale) =>
          _b(
            style: style,
            decoration: style.rangeWithinDecoration,
            text: style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
            textStyle: style.rangeWithinTextStyle,
          );

  static CellBuilder _builderRangeEnd(CalendarStyle style) =>
          (date, _, locale) =>
          _b(
            style: style,
            decoration: style.rangeEndDecoration,
            text: style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
            textStyle: style.rangeEndTextStyle,
          );

  static CellBuilder _builderRangeStart(CalendarStyle style) =>
          (date, _, locale) =>
          _b(
            style: style,
            decoration: style.rangeStartDecoration,
            text: style.dayTextFormatter?.call(date, locale) ?? '${date.day}',
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
  static Generator<Widget> _builderWeekNumber(CalendarStyle style) =>
          (index) =>
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              child: Text(index.toString(), style: style.weekNumberTextStyle),
            ),
          );

  static CellBuilder _builderDayOfWeek(CalendarStyle style) {
    final daysOfWeekStyle = style.daysOfWeekStyle!;
    return (date, _, locale) =>
        Center(
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

  static RangeHighlightBuilder _builderHighlightRange(CalendarStyle style) =>
          (date, range, constraints) =>
          Center(
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

  CellBuilder get builderDayOfWeek => _bDayOfWeek ?? _builderDayOfWeek(this);

  RangeHighlightBuilder get builderHighlightRange =>
      _bRangeHighlight ?? _builderHighlightRange(this);

  Generator<Widget> get builderWeekNumber =>
      _bWeekNumber ?? _builderWeekNumber(this);

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
        // format.weeksPerPage * rowHeight +
        weeksPerPage * rowHeight +
        (tablePadding.vertical);
  }

  static PagingDateTime _pagingOf(int weeksPerPage) =>
          (date, index) =>
          DateTime.utc(
            date.year,
            date.month,
            date.day + index * DateTime.daysPerWeek * weeksPerPage,
          );

  // PagingDateTime get _paging => paging ?? _pagingOf(format.weeksPerPage);
  PagingDateTime get _paging => paging ?? _pagingOf(weeksPerPage);

  int _nextWeeksPerPage() =>
      availableWeeksPerPage[(availableWeeksPerPage.indexOf(weeksPerPage) + 1) %
          availableWeeksPerPage.length];
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
class CalendarStyleWithHeader extends CalendarStyle {
  final void Function(DateTime focusedDay)? headerOnTap;
  final void Function(DateTime focusedDay)? headerOnLongPress;
  final DateBuilder? _builderTitle;
  final PageStepperBuilder? _builderLeftChevron;
  final PageStepperBuilder? _builderRightChevron;

  ///
  ///
  ///
  final bool titleCentered;
  final dm.TextFormatter? titleTextFormatter;
  final TextStyle titleTextStyle;
  final EdgeInsets headerPadding;
  final EdgeInsets headerMargin;
  final BoxDecoration headerDecoration;

  ///
  ///
  ///
  final String Function(int weeksPerPage)? _formatButtonText;
  final TextStyle formatButtonTextStyle;
  final BoxDecoration formatButtonDecoration;
  final EdgeInsets formatButtonPadding;

  ///
  ///
  ///
  final bool chevronVisible;
  final Widget chevronIconLeft;
  final Widget chevronIconRight;
  final EdgeInsets chevronPadding;
  final EdgeInsets chevronMargin;

  const CalendarStyleWithHeader({
    super.availableWeeksPerPage,
    super.builderDayOfWeek,
    super.builderDisabled,
    super.builderHoliday,
    super.builderOutside,
    super.builderPrioritized,
    super.builderRangeEnd,
    super.builderRangeHighlight,
    super.builderRangeIn,
    super.builderRangeStart,
    super.builderSelected,
    super.builderToday,
    super.builderWeekday,
    super.builderWeekend,
    super.builderWeekNumber,
    super.cellAlignment,
    super.cellAnimationDuration,
    super.cellMargin,
    super.cellPadding,
    super.cellStackAlignment,
    super.cellStackClip,
    super.daysOfWeekStyle,
    super.dayTextFormatter,
    super.disabledDecoration,
    super.disabledTextStyle,
    super.holidayDecoration,
    super.holidayTextStyle,
    super.outsideDecoration,
    super.outsideTextStyle,
    super.pageStepCurve,
    super.pageStepDuration,
    super.paging,
    super.rangeEndDecoration,
    super.rangeEndTextStyle,
    super.rangeHighlightColor,
    super.rangeHighlightScale,
    super.rangeStartDecoration,
    super.rangeStartTextStyle,
    super.rangeWithinDecoration,
    super.rangeWithinTextStyle,
    super.rowDecoration,
    super.rowHeight,
    super.selectedDecoration,
    super.selectedTextStyle,
    super.startingWeekday,
    super.tableBorder,
    super.tablePadding,
    super.todayDecoration,
    super.todayTextStyle,
    super.weekdayDecoration,
    super.weekdayTextStyle,
    super.weekendDays,
    super.weekendDecoration,
    super.weekendTextStyle,
    super.weekNumberTextStyle,
    super.weekNumberVisible,
    super.weeksPerPage,

    ///
    ///
    ///
    DateBuilder? builderTitle,
    PageStepperBuilder? builderLeftChevron,
    PageStepperBuilder? builderRightChevron,
    String Function(int weeksPerPage)? formatButtonText,
    this.headerOnTap,
    this.headerOnLongPress,
    this.titleCentered = false,
    this.titleTextFormatter,
    this.titleTextStyle = const TextStyle(fontSize: 17.0),
    this.headerDecoration = const BoxDecoration(),

    //
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

    //
    this.chevronVisible = true,
    this.chevronPadding = const EdgeInsets.all(12.0),
    this.chevronMargin = const EdgeInsets.symmetric(horizontal: 8.0),
    this.chevronIconLeft = const Icon(Icons.chevron_left),
    this.chevronIconRight = const Icon(Icons.chevron_right),
  })
      : _builderTitle = builderTitle,
        _builderLeftChevron = builderLeftChevron,
        _builderRightChevron = builderRightChevron,
        _formatButtonText = formatButtonText;

  String formatButtonText(int weeksPerPage) =>
      _formatButtonText?.call(weeksPerPage) ?? '$weeksPerPage weeks';

  static DateBuilder _bTitle(CalendarStyleWithHeader style) =>
          (focusedDate, locale) =>
          Expanded(
            child: GestureDetector(
              onTap: () => style.headerOnTap?.call(focusedDate),
              onLongPress: () => style.headerOnLongPress?.call(focusedDate),
              child: Text(
                style.titleTextFormatter?.call(focusedDate, locale) ??
                    DateFormat.yMMMM(locale).format(focusedDate),
                style: style.titleTextStyle,
                textAlign: style.titleCentered ? TextAlign.center : TextAlign
                    .start,
              ),
            ),
          );

  DateBuilder get builderTitle => _builderTitle ?? _bTitle(this);

  ///
  ///
  ///
  static PageStepperBuilder _bChevron(// CalendarStyle style,
      // HeaderStyle headerStyle,
      CalendarStyleWithHeader style,
      Widget icon,) =>
          (stepper) =>
          Padding(
            // padding: headerStyle.chevronMargin,
            padding: style.chevronMargin,
            child: InkWell(
              onTap:
                  () =>
                  stepper(
                    duration: style.pageStepDuration,
                    curve: style.pageStepCurve,
                  ),
              borderRadius: KGeometry.borderRadius_circularAll_1 * 100,
              child: Padding(padding: style.chevronPadding, child: icon),
            ),
          );

  Widget chevron(DirectionIn4 direction, {required PageStepper iconOnTap}) =>
      (switch (direction) {
        DirectionIn4.left =>
        // _builderLeftChevron ?? _bChevron(style, this, chevronIconLeft),
        _builderLeftChevron ?? _bChevron(this, chevronIconLeft),
        DirectionIn4.right =>
        // _builderRightChevron ?? _bChevron(style, this, chevronIconRight),
        _builderRightChevron ?? _bChevron(this, chevronIconRight),
        _ => throw StateError('invalid direction $direction'),
      })(iconOnTap);

  ///
  ///
  ///
  static WidgetBuilder _bFormatButton(CalendarStyleWithHeader style) =>
          (context) =>
          Padding(
            padding: KGeometry.edgeInsets_left_1 * 8,
            child: InkWell(
              borderRadius: style.formatButtonDecoration.borderRadius
                  ?.resolve(context.textDirection),
              onTap: () => style.onFormatChange!(style._nextWeeksPerPage()),
              child: Container(
                decoration: style.formatButtonDecoration,
                padding: style.formatButtonPadding,
                child: Text(
                  style.formatButtonText(style.weeksPerPage),
                  style: style.formatButtonTextStyle,
                ),
              ),
            ),
          );

  WidgetBuilder? get _builderFormatButton {
    if (availableWeeksPerPage.length == 1) return null;
    if (onFormatChange == null) return null;
    return _bFormatButton(this);
  }
}
