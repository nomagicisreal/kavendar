part of '../table_calendar.dart';

///
/// [CalendarCellType]
///
/// [CalendarStyleHeader]
/// [CalendarStyleWeekNumber]
/// [CalendarStyleDayOfWeek]
/// [CalendarStyleCellMark]
/// [CalendarStyleCellRange]
///
///

///
///
///
enum CalendarCellType {
  disabled,
  today,
  focused,
  weekend,
  weekday,
  holiday,
  outside,
}

///
///
///
class CalendarStyleHeader {
  final void Function(DateTime focusedDay)? onTap;
  final void Function(DateTime focusedDay)? onLongPress;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BoxDecoration decoration;

  ///
  ///
  ///
  final bool titleCentered;
  final DateTimeFormatter? titleTextFormatter;
  final TextStyle titleTextStyle;
  final DateLocaleBuilder? _bTitle;

  ///
  ///
  ///
  final StyleTextButton? styleFormatButton;
  final StyleChevrons? styleChevrons;

  const CalendarStyleHeader({
    this.onTap,
    this.onLongPress,
    this.decoration = const BoxDecoration(),
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
    this.titleCentered = false,
    this.titleTextFormatter,
    this.titleTextStyle = const TextStyle(fontSize: 17.0),
    this.styleFormatButton,
    this.styleChevrons = const StyleChevrons(),

    DateLocaleBuilder? builderTitle,
    WidgetBuilder Function(
      CalendarStyle style,
      CalendarStyleHeader styleHeader,
    )?
    builderFormatButton,
  }) : _bTitle = builderTitle;

  static DateLocaleBuilder _builderTitle(CalendarStyleHeader style) =>
      (focusedDate, locale) => Expanded(
        child: GestureDetector(
          onTap: () => style.onTap?.call(focusedDate),
          onLongPress: () => style.onLongPress?.call(focusedDate),
          child: Text(
            style.titleTextFormatter?.call(focusedDate, locale) ??
                DateFormat.yMMMM(locale).format(focusedDate),
            style: style.titleTextStyle,
            textAlign: style.titleCentered ? TextAlign.center : TextAlign.start,
          ),
        ),
      );

  DateLocaleBuilder get buildTitle => _bTitle ?? _builderTitle(this);


  // TODO: know the default fontSize if textStyle == null
  double get height =>
      margin.vertical +
          padding.vertical +
          titleTextStyle.fontSize!;
}

///
///
///
class CalendarStyleWeekNumber {
  final String title;
  final double flexOnRow;
  final TextStyle? textStyle;

  const CalendarStyleWeekNumber({
    this.title = '',
    this.flexOnRow = 0.4,
    this.textStyle = const TextStyle(fontSize: 12, color: Color(0xFFBFBFBF)),
  });

  DateBuilder builderFrom(Predicator<DateTime> predicateBlock, double heightRow) =>
      (startingDate) =>
          !predicateBlock(startingDate) ||
                  !predicateBlock(
                    startingDate.add(
                      DurationExtension.day1 * (DateTime.daysPerWeek - 1),
                    ),
                  )
              ? SizedBox(
                height: heightRow,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    startingDate
                        .yearWeekNumber(startingDate.weekday)
                        .toString(),
                    style: textStyle,
                  ),
                ),
              )
              : Container();

  Widget buildTitle(double? heightDayOfWeek) => SizedBox(
    height: heightDayOfWeek,
    child: Align(
      alignment: Alignment.centerRight,
      child: Text(title, style: textStyle),
    ),
  );
}

///
///
///
class CalendarStyleDayOfWeek {
  final double? height;
  final DateTimeFormatter textFormatter;
  final Decoration decoration;
  final TextStyle weekdayStyle;
  final TextStyle weekendStyle;
  final DateLocaleBuilder? _b;

  const CalendarStyleDayOfWeek({
    this.height = 16.0,
    this.textFormatter = _formatter,
    this.decoration = const BoxDecoration(),
    this.weekdayStyle = const TextStyle(color: Color(0xFF4F4F4F)),
    this.weekendStyle = const TextStyle(color: Color(0xFF6A6A6A)),
    DateLocaleBuilder? builderDayOfWeek,
  }) : _b = builderDayOfWeek;

  // Defaults to simple `'E'` format (i.e. Mon, Tue, Wed, etc.).
  static String _formatter(DateTime date, dynamic locale) =>
      DateFormat.E(locale).format(date);

  static DateLocaleBuilder _builder(
    Predicator<DateTime> predicateWeekend,
    CalendarStyleDayOfWeek styleDayOfWeek,
  ) =>
      (date, locale) => Center(
        child: ExcludeSemantics(
          child: Text(
            styleDayOfWeek.textFormatter(date, locale),
            style:
                predicateWeekend(date)
                    ? styleDayOfWeek.weekendStyle
                    : styleDayOfWeek.weekdayStyle,
          ),
        ),
      );

  TableRow Function(List<DateTime> dates) buildFrom({
    required Predicator<DateTime> predicateWeekend,
    required dynamic locale,
    required Widget? weekNumberTitle,
  }) {
    final builder = _b ?? _builder(predicateWeekend, this);
    final height = this.height;

    List<Widget> children(List<DateTime> dates) => List.generate(
      DateTime.daysPerWeek,
      (index) => SizedBox(
        height: height,
        child: builder(dates[index], locale),
      ),
    );
    final row =
        weekNumberTitle == null
            ? children
            : (dates) => [
              SizedBox(height: height, child: weekNumberTitle),
              ...children(dates),
            ];

    final decoration = this.decoration;
    return (dates) => TableRow(decoration: decoration, children: row(dates));
  }
}

///
///
///
class CalendarStyleCellMark {
  final int max;
  final double? size;
  final double sizeScale;
  final double sizeAnchor;
  final EdgeInsets margin;
  final EdgeInsets marginCell;
  final Decoration decoration;
  final PositionedLayout? _layout;

  const CalendarStyleCellMark({
    this.max = 4,
    this.size,
    this.sizeScale = 0.2,
    this.sizeAnchor = 0.7,
    this.marginCell = EdgeInsets.zero,
    this.margin = const EdgeInsets.symmetric(horizontal: 0.3),
    this.decoration = const BoxDecoration(
      color: Color(0xFF263238),
      shape: BoxShape.circle,
    ),
    PositionedLayout? layout,
  }) : _layout = layout;

  ///
  ///
  ///
  static PositionedLayout _layoutFrom(CalendarStyleCellMark style) => (
    constraints,
  ) {
    final shorterSide = FBoxConstraints.shortSide(constraints);
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
  };

  PositionedLayout get layout => _layout ?? _layoutFrom(this);

  ///
  ///
  ///
  static EventSingleBuilder<T> _singleDecoration<T>(
    CalendarStyleCellMark style,
  ) =>
      (day, event) => Container(
        width: style.size,
        height: style.size,
        margin: style.margin,
        decoration: style.decoration,
      );

  static EventsBuilder<T> _allPositionedRow<T>(CalendarStyleCellMark style) {
    final layout = style.layout;
    return (constraints, dateTime, events, mark) {
      if (events.isEmpty) return null;
      final positioned = layout(constraints);
      return PositionedDirectional(
        start: positioned.$1,
        top: positioned.$2,
        end: positioned.$3,
        bottom: positioned.$4,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: events
              .take(style.max)
              .fold(
                [],
                (list, event) => list..addIfNotNull(mark(dateTime, event)),
              ),
        ),
      );
    };
  }

  CellMetaBuilder? builderFrom<T>({
    required EventLoader<T>? eventLoader,
    required EventsLayoutMark<T>? eventsLayoutMark,
    required EventElementMark<T>? eventLayoutSingleMark,
    required MarkConfiguration<T>? customMark,
  }) {
    if (eventLoader == null) return null;
    if (customMark == null) {
      final layout = (eventsLayoutMark ?? _allPositionedRow<T>)(this);
      final mark = (eventLayoutSingleMark ?? _singleDecoration<T>)(this);
      return (date, focusedDate, cellType, constraints) =>
          layout(constraints, date, eventLoader(date), mark)!;
    } else {
      return (date, focusedDate, cellType, constraints) {
        final builder = customMark[cellType];
        if (builder == null) return null;
        final layout = (builder.$1 ?? _allPositionedRow<T>)(this);
        final mark = (builder.$2 ?? _singleDecoration<T>)(this);
        return layout(constraints, date, eventLoader(date), mark)!;
      };
    }
  }
}

///
///
///
class CalendarStyleCellRange {
  final CellMetaBuilder? _bStart;
  final CellMetaBuilder? _bWithin;
  final CellMetaBuilder? _bEnd;
  final ConstraintsRangeBuilder? _bHighlight;
  final HighlightWidthFrom<CalendarStyle> widthFrom;
  final Map<CalendarCellType, (RangeState3, CellMetaBuilder?)>?
  customBuilder;

  ///
  ///
  ///
  final double highlightScale;
  final Color highlightColor;
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
    this.highlightScale = 1.0,
    this.highlightColor = const Color(0xFFBBDDFF),
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
    CellMetaBuilder? builderRangeStart,
    CellMetaBuilder? builderRangeIn,
    CellMetaBuilder? builderRangeEnd,
    ConstraintsRangeBuilder? builderRangeHighlight,
    this.widthFrom = _widthFrom,
    this.customBuilder,
  }) : _bStart = builderRangeStart,
       _bWithin = builderRangeIn,
       _bEnd = builderRangeEnd,
       _bHighlight = builderRangeHighlight;

  static BoxConstraintsDouble _widthFrom(CalendarStyle style) =>
      (constraints) =>
          FBoxConstraints.shortSide(constraints) - style.cellMargin.vertical;

  ///
  ///
  ///
  // static CellConstraintsBuilder _builderRangeWithin(
  //   CalendarStyle style,
  //   CalendarStyleCellRange styleRange,
  // ) =>
  //     (date, _, locale, __) => CalendarStyle._buildContainer(
  //       date: date,
  //       style: style,
  //       locale: locale,
  //       decoration: styleRange.rangeWithinDecoration,
  //       textStyle: styleRange.rangeWithinTextStyle,
  //     );
  //
  // static CellConstraintsBuilder _builderRangeEnd(
  //   CalendarStyle style,
  //   CalendarStyleCellRange styleRange,
  // ) =>
  //     (date, _, locale, __) => CalendarStyle._buildContainer(
  //       date: date,
  //       style: style,
  //       locale: locale,
  //       decoration: styleRange.rangeEndDecoration,
  //       textStyle: styleRange.rangeEndTextStyle,
  //     );
  //
  // static CellConstraintsBuilder _builderRangeStart(
  //   CalendarStyle style,
  //   CalendarStyleCellRange styleRange,
  // ) =>
  //     (date, _, locale, __) => CalendarStyle._buildContainer(
  //       date: date,
  //       style: style,
  //       locale: locale,
  //       decoration: styleRange.rangeStartDecoration,
  //       textStyle: styleRange.rangeStartTextStyle,
  //     );

  ///
  ///
  ///
  static ConstraintsRangeBuilder _backgroundHighlight(
    CalendarStyle style,
    CalendarStyleCellRange styleRange,
  ) {
    final doubleFrom = styleRange.widthFrom(style);
    return (s, constraints) => Center(
      child: Container(
        margin: EdgeInsetsDirectional.only(
          start: s == RangeState3.start ? constraints.maxWidth * 0.5 : 0.0,
          end: s == RangeState3.end ? constraints.maxWidth * 0.5 : 0.0,
        ),
        height: doubleFrom(constraints) * styleRange.highlightScale,
        color: styleRange.highlightColor,
      ),
    );
  }

  ///
  ///
  /// selected date changed
  /// 0. reset
  /// 1. rangeStart == null -> find range start date
  /// 2. rangeStart != null, rangeEnd == null -> find another range date, range within date(s), unselect rangeStart
  /// 3. rangeStart != null, rangeEnd != null -> expand range, shrink range, unselect rangeEnd
  ///
  ///
  CellMetaBuilder? builderFrom({
    required CalendarStyle style,
    required bool isBackground,
  }) {
    // final builder = customBuilder;
    throw UnimplementedError();
    // final rangeStart = _rangeStart;
    // if (rangeStart == null) return null;
    // if (date.isBefore(rangeStart)) return null;
    // if (date.isAfter(rangeStart)) {
    //   final rangeEnd = this.rangeEnd;
    //   if (rangeEnd == null) return null;
    //   if (date.isAfter(rangeEnd)) return null;
    //   if (date.isBefore(rangeEnd)) {
    //     final builder =
    //         isBackground
    //             ? _bHighlight ?? _backgroundHighlight(style, this)
    //             : _bWithin ?? _builderRangeWithin(style, this);
    //     return (_, constraints) => builder(RangeState3.within, constraints);
    //   }
    //   final builder =
    //       isBackground
    //           ? _bHighlight ?? _backgroundHighlight(style, this)
    //           : _bEnd ?? _builderRangeEnd(style, this);
    //   return (_, constraints) => builder(RangeState3.end, constraints);
    // }
    // final builder =
    //     isBackground
    //         ? _bHighlight ?? _backgroundHighlight(style, this)
    //         : _bStart ?? _builderRangeStart(style, this);
    // return (_, constraints) => builder(RangeState3.start, constraints);
  }
}
