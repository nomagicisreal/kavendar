part of '../table_calendar.dart';

///
/// todo: integrating page... field in [CalendarStyle]
///
// class CalendarPaging {
//   final DateTime dateFirst;
//   final DateTime lastDate;
//   final CalendarPageControllerInitializer pageControllerInitializer;
// }

///
/// todo: [CalendarPageNext] is inappropriate as enum
///
enum CalendarPageNext {
  correspondingDay,
  correspondingWeekAndDay,
  firstDateOfMonth,
  firstDateOfFirstWeek,
  lastDateOfMonth,
  lastDateOfLastWeek,
}