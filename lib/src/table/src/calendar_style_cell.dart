part of '../table_calendar.dart';

///
///
/// [CalendarCellType]
/// [CalendarCellStyle], [CalendarCellPrioritization]
/// [CalendarStyleCellStack]
/// [CalendarStyleCellStackOverlay]
/// [CalendarStyleCellStackBackground]
///
///

enum CalendarCellType {
  disabled,
  today,
  focused,
  outside,
  selected,
  readyToAction,
  holiday,
  normal,
}

typedef CalendarCellStyle =
    (CalendarCellType, MaterialDecoration?, MaterialTextStyle?);

typedef CalendarCellPrioritization =
    (
      Predicator<DateTime>?,
      bool hasGesture,
      ContextGeneral<Decoration>,
      ContextGeneral<TextStyle>,
    );

///
///
///
class CalendarStyleCellStack {
  final AlignmentGeometry alignment;
  final Clip clip;
  final CalendarStyleCellStackOverlay styleOverlay;
  final CalendarStyleCellStackBackground? styleBackground;

  const CalendarStyleCellStack({
    this.alignment = Alignment.bottomCenter,
    this.clip = Clip.none,
    this.styleOverlay = const CalendarStyleCellStackOverlay(),
    this.styleBackground = const CalendarStyleCellStackBackground(),
  });

  Widget _build(List<Widget> children) =>
      Stack(alignment: alignment, clipBehavior: clip, children: children);

  CellBuilder _initCellStackBuilder<T>({
    required CalendarStyle style,
    required CalendarFocus focus,
    required EventLoader<T>? eventLoader,
    required EventsLayoutMark<T>? eventsLayoutMark,
    required EventElementMark<T>? eventLayoutSingleMark,
  }) {
    final buildBackground = styleBackground?.builderFrom(
      style: style,
      focus: focus,
    );
    final buildOverlay = styleOverlay.builderFrom(
      style: style,
      eventLoader: eventLoader,
      eventsLayoutMark: eventsLayoutMark,
      eventLayoutSingleMark: eventLayoutSingleMark,
    );
    final build = _build;
    final CellStackBuilder stacking =
        buildBackground == null
            ? (buildOverlay == null
                ? (_, __, ___, child) => build([child])
                : (context, constraints, date, child) {
                  final overlay = buildOverlay(context, constraints, date);
                  return build([child, if (overlay != null) overlay]);
                })
            : (buildOverlay == null
                ? (context, constraints, date, child) {
                  final background = buildBackground(
                    context,
                    constraints,
                    date,
                  );
                  return build([if (background != null) background, child]);
                }
                : (context, constraints, date, child) {
                  final overlay = buildOverlay(context, constraints, date);
                  final background = buildBackground(
                    context,
                    constraints,
                    date,
                  );
                  return build([
                    if (background != null) background,
                    child,
                    if (overlay != null) overlay,
                  ]);
                });

    final cell = style._buildCell;
    return (context, constraints, locale, date, decoration, textStyle) =>
        stacking(
          context,
          constraints,
          date,
          cell(context, constraints, locale, date, decoration, textStyle),
        );
  }
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
    required CalendarStyle style,
    required EventLoader<T>? eventLoader,
    required EventsLayoutMark<T>? eventsLayoutMark,
    required EventElementMark<T>? eventLayoutSingleMark,
  }) {
    if (eventLoader == null) return null;
    final layout = (eventsLayoutMark ?? _allPositionedRow<T>)(this);
    final mark = (eventLayoutSingleMark ?? _singleDecoration<T>)(this);
    return (context, constraints, date) =>
        layout(constraints, date, eventLoader(date), mark)!;
  }
}

///
///
///
class CalendarStyleCellStackBackground {
  final HighlightWidthFrom<CalendarStyle> widthFrom;
  final double highlightScale;
  final MaterialColorRole highlightColor;

  const CalendarStyleCellStackBackground({
    ///
    ///
    ///
    this.highlightScale = 1.0,
    this.highlightColor = MaterialColorRole.tertiary,
    this.widthFrom = _widthFrom,
  });

  static BoxConstraintsDouble _widthFrom(CalendarStyle style) =>
      (constraints) =>
          FBoxConstraints.shortSide(constraints) - style.cellMargin.vertical;

  ///
  ///
  ///
  static const int highlightAlphaDefault = 0x22;

  static ConstraintsRangeBuilder _highlight(
    CalendarStyle style,
    CalendarStyleCellStackBackground styleRange,
  ) {
    //
    final duration = style.cellAnimationDuration;
    final curve = style.cellAnimationCurve;
    final heightFrom = styleRange.widthFrom(style);
    final heightScale = styleRange.highlightScale;

    //
    final emphasis = styleRange.highlightColor;
    final color = emphasis.buildColor;
    final animationStyle = AnimationStyle(
      duration: duration ~/ 2,
      reverseDuration: duration ~/ 2,
      curve: curve,
      reverseCurve: curve,
    );
    final mamable = MamableSingle(
      Between(begin: 0.0, end: 1.0, curve: (curve, curve)),
      (o, child) => Opacity(opacity: o.value, child: child),
    );
    return (context, constraints, state) => Center(
      child: Mationani.mamion(
        ani: Ani.update(
          style: animationStyle,
          onNotAnimating: FAni.decideForwardThenReverse(state != null),
        ),
        mamable: mamable,
        child: Container(
          height: heightFrom(constraints) * heightScale,
          color: color(context).withAlpha(highlightAlphaDefault),
        ),
      ),
    );
  }

  ///
  ///
  ///
  CellMetaBuilder? builderFrom({
    required CalendarStyle style,
    required CalendarFocus focus,
  }) {
    switch (focus) {
      case _CalendarFocusFocusOnly():
        return null;
      case _CalendarFocusFocusAndSelection():
        final build = _highlight(style, this);
        (DateTime, DateTime)? r;
        focus._consumeRanging = (range) => r = range;
        focus._onRangingAnimationFinished = (_) => r = null;
        return (context, constraints, date) {
          final range = r;
          if (range == null) return build(context, constraints, null);
          final start = range.$1;
          final end = range.$2;
          if (start == end) return build(context, constraints, null);
          if (date.isBefore(start)) return build(context, constraints, null);
          if (date.isAfter(start)) {
            if (date.isAfter(end)) return build(context, constraints, null);
            if (date.isBefore(end)) {
              return build(context, constraints, RangeState3.within);
            }
            return build(context, constraints, RangeState3.end);
          }
          return build(context, constraints, RangeState3.start);
        };
    }
  }
}
