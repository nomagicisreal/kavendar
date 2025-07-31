part of '../table_calendar.dart';

///
/// [CalendarCellType]
/// [CalendarCell]
/// [CalendarStyleCellStack]
/// [CalendarStyleCellStackOverlay]
/// [CalendarStyleCellStackBackground]
///
///

enum CalendarCellType {
  disabled,
  today,
  focused,
  holiday,
  outside,
  normal,
}


typedef CalendarCell =
    (
      CalendarCellType,
      // cell decoration: shape, background color, border color
      (BoxShape, MaterialColorRole, MaterialColorRole?),
      // text style: theme, color, emphasis level
      (MaterialTextTheme, MaterialColorRole, MaterialEmphasisLevel),
    );

///
///
///
class CalendarStyleCellStack {
  final AlignmentGeometry cellStackAlignment;
  final Clip cellStackClip;
  final CalendarStyleCellStackOverlay styleOverlay;
  final CalendarStyleCellStackBackground? styleBackground;

  const CalendarStyleCellStack({
    this.cellStackAlignment = Alignment.bottomCenter,
    this.cellStackClip = Clip.none,
    this.styleOverlay = const CalendarStyleCellStackOverlay(),
    this.styleBackground,
  });

  Widget _build(List<Widget> children) => Stack(
    alignment: cellStackAlignment,
    clipBehavior: cellStackClip,
    children: children,
  );
}

///
///
///
class CalendarStyleCellStackOverlay {
  final int markMax;
  final double? markSize;
  final double markSizeScale;
  final double markSizeAnchor;
  final EdgeInsets markMargin;
  final EdgeInsets markMarginCell;
  final Decoration markDecoration;
  final PositionedLayout? _markLayout;

  const CalendarStyleCellStackOverlay({
    this.markMax = 4,
    this.markSize,
    this.markSizeScale = 0.2,
    this.markSizeAnchor = 0.7,
    this.markMarginCell = EdgeInsets.zero,
    this.markMargin = const EdgeInsets.symmetric(horizontal: 0.3),
    this.markDecoration = const BoxDecoration(
      color: Color(0xFF263238),
      shape: BoxShape.circle,
    ),
    PositionedLayout? layout,
  }) : _markLayout = layout;

  ///
  ///
  ///
  static PositionedLayout _layoutFrom(CalendarStyleCellStackOverlay style) => (
    constraints,
  ) {
    final shorterSide = FBoxConstraints.shortSide(constraints);
    return (
      null,
      constraints.maxHeight / 2 +
          (shorterSide - style.markMarginCell.vertical) / 2 -
          (style.markSize ??
              (shorterSide - style.markMarginCell.vertical) *
                  style.markSizeScale *
                  style.markSizeAnchor),
      null,
      null,
    );
  };

  PositionedLayout get layout => _markLayout ?? _layoutFrom(this);

  ///
  ///
  ///
  static EventSingleBuilder<T> _singleDecoration<T>(
    CalendarStyleCellStackOverlay style,
  ) =>
      (day, event) => Container(
        width: style.markSize,
        height: style.markSize,
        margin: style.markMargin,
        decoration: style.markDecoration,
      );

  static EventsBuilder<T> _allPositionedRow<T>(
    CalendarStyleCellStackOverlay style,
  ) {
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
              .take(style.markMax)
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
  }) {
    if (eventLoader == null) return null;
    final layout = (eventsLayoutMark ?? _allPositionedRow<T>)(this);
    final mark = (eventLayoutSingleMark ?? _singleDecoration<T>)(this);
    return (date, focusedDate, cellType, constraints) =>
        layout(constraints, date, eventLoader(date), mark)!;
  }
}

///
///
///
class CalendarStyleCellStackBackground {
  final HighlightWidthFrom<CalendarStyle> widthFrom;
  final OnRangeSelected? onRangeSelected;

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

  const CalendarStyleCellStackBackground({
    ///
    ///
    ///
    this.highlightScale = 1.0,
    this.highlightColor = const Color(0xFFBBDDFF),

    // todo: move to calendar cell type?
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
    this.onRangeSelected,

    this.widthFrom = _widthFrom,
  });

  static BoxConstraintsDouble _widthFrom(CalendarStyle style) =>
      (constraints) =>
          FBoxConstraints.shortSide(constraints) - style.cellMargin.vertical;

  ///
  ///
  ///
  static ConstraintsRangeBuilder _backgroundHighlight(
    CalendarStyle style,
    CalendarStyleCellStackBackground styleRange,
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
    if (!isBackground) {
      throw UnimplementedError();
    }
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
