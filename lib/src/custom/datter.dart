part of 'calendar.dart';

///
/// [StyleWidgetBuilder], ...
/// [ResponsiveShape], ...
/// [BuildContextExtension], ...
/// [GestureDetectorDragMixin], ...
///

extension DebugUtils<T> on T {
  void printThis([Mapper<T, String>? mapper]) =>
      print(mapper?.call(this) ?? ':::::$this');
}

typedef ConstraintsBuilder =
    Widget Function(BuildContext context, BoxConstraints constraints);
typedef StyleWidgetBuilder<T> = Widget Function(T style);
typedef StylePositionedLayout<T> =
    PositionedOffset Function(T style, BoxConstraints constraints);

///
///
///
enum ResponsiveShape {
  horizontalRail,
  horizontalView, // for screen
  almostSquare,
  verticalView, // for phone
  verticalRail,
}

enum ScrollWay { horizontal, vertical, graph }

// assuming ltrb handle 80% cases, none for 20% cases (overflow, on the corner, far positioned)
enum AppendixPosition { none, left, top, right, bottom }

///
///
///
extension BuildContextExtension on BuildContext {
  TargetPlatform get platform => Theme.of(this).platform;
}

extension DateTimeRangeExtension on DateTimeRange {
  static List<DateTime> datesIn(DateTimeRange range) => List.generate(
    range.duration.inDays + 1,
    (index) => DateTime.utc(
      range.start.year,
      range.start.month,
      range.start.day + index,
    ),
  );

  ///
  ///
  ///
  static DateTimeRange weeksFrom(
    DateTime focusedDate, {
    int startingDay = DateTime.sunday,
    int count = 1,
  }) {
    final start = dm.DateTimeExtension.firstDateOfWeek(
      focusedDate,
      startingDay,
    );
    return DateTimeRange(
      start: start,
      end: start.add(DurationExtension.day1 * DateTime.daysPerWeek * count),
    );
  }

  static DateTimeRange weeksIneMonthFrom(
    DateTime focusedDate, [
    int startingDay = DateTime.sunday,
  ]) => DateTimeRange(
    start: dm.DateTimeExtension.firstDateOfWeekInMonth(
      focusedDate,
      startingDay,
    ),
    end: dm.DateTimeExtension.lastDateOfWeekInMonth(focusedDate, startingDay),
  );

  static int scopesOf(
    DateTimeRange range, [
    int startingWeekday = DateTime.sunday,
    int daysPerScope = DateTime.daysPerWeek,
  ]) =>
      (dm.DateTimeExtension.firstDateOfWeek(range.start, startingWeekday)
              .difference(
                dm.DateTimeExtension.lastDateOfWeek(range.end, startingWeekday),
              )
              .inDays
              .abs() +
          1) ~/
      daysPerScope;
}

extension BoxConstraintsExtension on BoxConstraints {
  static double shortSide(BoxConstraints constraints) =>
      math.min(constraints.maxHeight, constraints.maxWidth);
}

///
///
///
mixin GestureDetectorDragMixin<T extends StatefulWidget> on State<T> {
  Offset? dragStart;
  Offset? dragCurrent;

  void onDragStart(DragStartDetails details) =>
      dragStart = details.globalPosition;

  ///
  ///
  ///
  static double verticalDifference(Offset begin, Offset end) =>
      end.dy - begin.dy;

  static double horizontalDifference(Offset begin, Offset end) =>
      end.dx - begin.dx;

  static DirectionIn4 verticalForward(double d) =>
      d > 0 ? DirectionIn4.bottom : DirectionIn4.top;

  static DirectionIn4 horizontalForward(double d) =>
      d > 0 ? DirectionIn4.right : DirectionIn4.left;

  static ValueChanged<DirectionIn4> indexingByVerticalDrag({
    required ValueChanged<int> onIndex,
    required int currentIndex,
    required int maxIndex,
  }) =>
      (direction) => onIndex(
        direction == DirectionIn4.top
            ? math.min(currentIndex + 1, maxIndex)
            : math.max(currentIndex - 1, 0),
      );

  ///
  ///
  ///
  GestureDragUpdateCallback onDragUpdateFrom([
    VoidCallback? continuousCallback,
  ]) => (details) {
    dragCurrent = details.globalPosition;
    if (continuousCallback == null) return;
    continuousCallback();
  };

  GestureDragEndCallback onDragEndFrom({
    required double Function(Offset begin, Offset end) difference,
    required double threshold,
    required DirectionIn4 Function(double d) direction,
    required Consumer<DirectionIn4> onDrag,
  }) => (details) {
    final begin = dragStart;
    final end = dragCurrent;
    if (begin != null && end != null) {
      final d = difference(begin, end);
      if (d.abs() > threshold) onDrag(direction(d));
    }
    dragStart = null;
  };
}
