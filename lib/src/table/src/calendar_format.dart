// ignore_for_file: constant_identifier_names
part of '../table_calendar.dart';

///
///
/// [OnDateChanged], ...
/// [PredicateCell], ...
/// [EventSingleBuilder], ...
///
///

///
/// [PageController.animateTo]
/// [PageController.animateToPage]
/// [PageController.previousPage]
/// [PageController.nextPage]
///
typedef AnimateToFutureRequired = Future<void> Function(
    {required Duration duration, required Curve curve});


///
///
///
typedef OnPageChanged =
    void Function(int index, int indexPrevious, DateTime focusedDate);

typedef OnRangeSelected =
    void Function(DateTime? start, DateTime? end, DateTime focusedDate);

///
///
///
typedef CalendarPageControllerInitializer =
    PageController Function(
      DateTimeRange domain,
      int weeksPerPage,
      DateTime dateFocused,
    );

///
///
///
typedef DateBuilder = Widget Function(DateTime date);
typedef DateLocaleBuilder = Widget Function(DateTime date, dynamic locale);
typedef CellMetaBuilder =
    Widget? Function(
      DateTime date,
      DateTime? focusedDate,
      CalendarCellType cellType,
      BoxConstraints constraints,
    );

typedef CellBuilder =
    Widget Function(
      DateTime date,
      DateTime? focusedDate,
      CalendarCellType cellType,
      BoxConstraints constraints,
      Widget child,
    );

typedef TableRowsBuilder =
    Widget Function(List<DateTime> dates, DateBuilder buildCell);

///
///
///
typedef ConstraintsRangeBuilder =
    Widget Function(RangeState3 state, BoxConstraints constraints);

typedef BoxConstraintsDouble = double Function(BoxConstraints constraints);

typedef HighlightWidthFrom<T> = BoxConstraintsDouble Function(T style);

//
typedef EventSingleBuilder<T> = Widget? Function(DateTime dateTime, T event);

typedef EventsBuilder<T> =
    Widget? Function(
      BoxConstraints constraints,
      DateTime dateTime,
      List<T> events,
      EventSingleBuilder<T> mark,
    );

typedef EventLoader<T> = List<T> Function(DateTime date);
typedef EventElementMark<T> =
    EventSingleBuilder<T> Function(
      BoxConstraints constraints,
      CalendarStyleCellStackOverlay style,
    );
typedef EventsLayoutMark<T> =
    EventsBuilder<T> Function(
      BoxConstraints constraints,
      CalendarStyleCellStackOverlay style,
    );

///
///
///
typedef CalendarCellConfiguration = Map<CalendarCellType, Predicator<DateTime>>;

///
/// todo: ValueListenableBuilder for each cell.
///

///
///
/// todo: figure out how many possible calendar format
/// days x ≤ 7:
/// - current week
/// - cross weeks till 7 days
/// - to current week end
/// - to date in 7 days
///
/// days 7 < x ≤ 31:
/// - current month
/// - current month to index month end
/// - to index month end
///
/// days 31 < x ≤ 365:
/// -
///
///

///
/// date to date (may be in 7 days, may be over year)
///
///
// sealed class CalendarScope {
//   const CalendarScope();
// }
//
// //
// class _CalendarScopeCurrentWeek extends CalendarScope {
//   const _CalendarScopeCurrentWeek();
// }
//
// class _CalendarScopeToCurrentWeekEnd extends CalendarScope {
//   const _CalendarScopeToCurrentWeekEnd();
// }
//
// class _CalendarScopeToCurrentWeekDate extends CalendarScope {
//   const _CalendarScopeToCurrentWeekDate();
// }
//
// //
// sealed class _CalendarScopeWeeks extends CalendarScope {
//   final int weeksPerPage;
//
//   const _CalendarScopeWeeks({this.weeksPerPage = 6})
//       : assert(weeksPerPage > 0 && weeksPerPage < 7);
// }
//
// class _CalendarScopeCurrentMonth extends _CalendarScopeWeeks {
//   const _CalendarScopeCurrentMonth({super.weeksPerPage});
// }
//
// class _CalendarScopeToCurrentMonthEnd extends _CalendarScopeWeeks {
//   const _CalendarScopeToCurrentMonthEnd({super.weeksPerPage});
// }
//
// class _CalendarScopeWeeksCustom extends _CalendarScopeWeeks {
//   final int weekStartFromNow;
//   final int weekEndFromNow;
//
//   const _CalendarScopeWeeksCustom({
//     super.weeksPerPage,
//     required this.weekStartFromNow,
//     required this.weekEndFromNow,
//   }) : assert(
//   weekEndFromNow != weekEndFromNow &&
//       (weekEndFromNow - weekStartFromNow) % weeksPerPage == 0,
//   );
// }
//
// //
// sealed class _CalendarScopeMonths extends _CalendarScopeWeeks {
//   final bool shouldBlockOutsideDate;
//
//   const _CalendarScopeMonths({
//     this.shouldBlockOutsideDate = false,
//     super.weeksPerPage,
//   });
// }
//
// class _CalendarScopeCurrentYear extends _CalendarScopeMonths {
//   const _CalendarScopeCurrentYear({
//     super.shouldBlockOutsideDate = false,
//     super.weeksPerPage,
//   });
// }
//
// class _CalendarScopeToCurrentYear extends _CalendarScopeMonths {
//   const _CalendarScopeToCurrentYear({
//     super.shouldBlockOutsideDate = false,
//     super.weeksPerPage,
//   });
// }
//
// class _CalendarScopeMonthsCustom extends _CalendarScopeMonths {
//   const _CalendarScopeMonthsCustom({
//     super.shouldBlockOutsideDate = false,
//     super.weeksPerPage,
//   });
// }
//
// class CalendarFormat {
//   final DateTimeRange range;
//   final CalendarScope scope;
//   final int weeksPerPage;
//   final bool blockOutsideMonthDate;
//
//   const CalendarFormat(
//       this.range,
//       this.scope,
//       this.weeksPerPage,
//       this.blockOutsideMonthDate,
//       );
// }

