import 'package:damath/damath.dart' as da;

extension DateTimeExtension on DateTime {
  static DateTime normalizeDate(DateTime datetime) =>
      DateTime.utc(datetime.year, datetime.month, datetime.day);

  static int dayOfYear(DateTime date) =>
      DateTime.utc(
        date.year,
      ).difference(DateTime.utc(date.year, date.month, date.day)).inDays +
      1;

  ///
  ///
  ///
  static DateTime clamp(
    DateTime value,
    DateTime lowerLimit,
    DateTime upperLimit,
  ) {
    if (value.isBefore(lowerLimit)) return lowerLimit;
    if (value.isAfter(upperLimit)) return upperLimit;
    return value;
  }

  static bool isBeforeMonth(DateTime day1, DateTime day2) =>
      day1.year == day2.year ? day1.month < day2.month : day1.isBefore(day2);

  static bool isAfterMonth(DateTime day1, DateTime day2) =>
      day1.year == day2.year ? day1.month > day2.month : day1.isBefore(day2);

  static bool isWithin(DateTime day, DateTime start, DateTime end) {
    if (da.DateTimeExtension.predicateSameDate(day, start) ||
        da.DateTimeExtension.predicateSameDate(day, end)) {
      return true;
    }
    if (day.isAfter(start) && day.isBefore(end)) return true;
    return false;
  }

  ///
  ///
  ///
  static DateTime firstDateOfMonth(DateTime date) =>
      DateTime.utc(date.year, date.month);

  static DateTime lastDateOfMonth(DateTime date) => DateTime.utc(
    date.year,
    date.month + 1,
  ).subtract(da.DurationExtension.day1);

  // in dart, -1 % 7 = 6
  static DateTime firstDateOfWeek(
    DateTime date, [
    int startingDay = DateTime.sunday,
  ]) => date.subtract(
    da.DurationExtension.day1 * ((date.weekday - startingDay) % 7),
  );

  static DateTime lastDateOfWeek(
    DateTime date, [
    int startingDay = DateTime.sunday,
  ]) => date.add(
    da.DurationExtension.day1 * ((startingDay - 1 - date.weekday) % 7),
  );

  ///
  ///
  ///
  static DateTime firstDateOfWeekInMonth(
    DateTime date, [
    int startingDay = DateTime.sunday,
  ]) => firstDateOfMonth(
    date,
  ).subtract(da.DurationExtension.day1 * ((date.weekday - startingDay) % 7));

  static DateTime lastDateOfWeekInMonth(
    DateTime date, [
    int startingDay = DateTime.sunday,
  ]) => lastDateOfMonth(
    date,
  ).add(da.DurationExtension.day1 * ((startingDay - 1 - date.weekday) % 7));

  static int monthRowsOf(DateTime date, [int startingDay = DateTime.sunday]) =>
      (1 +
          firstDateOfWeekInMonth(
            date,
          ).difference(lastDateOfWeekInMonth(date, startingDay)).inDays) ~/
      7;
}
