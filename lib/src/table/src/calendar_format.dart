// ignore_for_file: constant_identifier_names
part of '../table_calendar.dart';

/// TODO: clean [Calendar], [CalendarStyle], define [CalendarFormat] integrating calendar scopes, weeksPerPage, other 'how to page' functions

///
///
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


// TODO: schedule enable viewing times period in a date, calendar extends schedule