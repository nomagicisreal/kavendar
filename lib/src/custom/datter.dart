part of 'calendar.dart';

///
///
/// [ResponsiveShape]
/// [ScrollWay]
/// [AppendixPosition]
///
/// [BuildContextExtension]
/// [GestureDetectorDragMixin]
///

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
  static List<DateTime> daysIn(DateTimeRange range) => List.generate(
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
    DateTime focusedDate, [
    int startingDay = DateTime.sunday,
    int count = 1,
  ]) {
    final start = dm.DateTimeExtension.firstDateOfWeek(focusedDate, startingDay);
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
      dm.DateTimeExtension.firstDateOfWeek(range.start, startingWeekday)
          .difference(
            dm.DateTimeExtension.lastDateOfWeek(range.end, startingWeekday),
          )
          .inDays + 1 ~/
      daysPerScope;
}

///
///
///
mixin GestureDetectorDragMixin<T extends StatefulWidget> on State<T> {
  Offset? _dragStart;
  Offset? _dragCurrentOffset;

  void onDragStart(DragStartDetails details) =>
      _dragStart = details.globalPosition;

  ///
  /// to [OffsetExtension]
  ///
  static double verticalDifference(Offset begin, Offset end) =>
      end.dy - begin.dy;

  static double horizontalDifference(Offset begin, Offset end) =>
      end.dx - begin.dx;

  static DirectionIn4 verticalForward(double d) =>
      d > 0 ? DirectionIn4.bottom : DirectionIn4.top;

  static DirectionIn4 horizontalForward(double d) =>
      d > 0 ? DirectionIn4.right : DirectionIn4.left;

  GestureDragUpdateCallback onDragUpdateFrom({
    bool callbackOnlyOnEnd = true,
    void Function(Offset begin, Offset end, VoidCallback reset)?
    continuousCallback,
  }) => (details) {
    _dragCurrentOffset = details.globalPosition;
    if (callbackOnlyOnEnd) return;

    final begin = _dragStart;
    final end = _dragCurrentOffset;
    if (begin != null && end != null) {
      continuousCallback!(begin, end, () => _dragStart = end);
    }
  };

  GestureDragEndCallback onDragEndFrom({
    required double Function(Offset begin, Offset end) difference,
    required double threshold,
    required DirectionIn4 Function(double d) direction,
    required Consumer<DirectionIn4> onDrag,
  }) => (details) {
    final begin = _dragStart;
    final end = _dragCurrentOffset;
    if (begin != null && end != null) {
      final d = difference(begin, end);
      if (d.abs() > threshold) onDrag(direction(d));
    }
    _dragStart = null;
  };
}
