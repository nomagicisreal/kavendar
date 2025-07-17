import 'package:damath/damath.dart' as da;

///
/// DirectionIn4 -> ltrb,
/// predicate same date -> not null
///
/// [TextFormatter], ...
/// [IterableExt], ...
/// [DateTimeExtension], ...
///
///
///

typedef TextFormatter = String Function(DateTime date, dynamic locale);

// ltrb (left, top, right, bottom) or (start, top, right, bottom)
typedef PositionedOffset = (double?, double?, double?, double?);

///
///
///
extension IterableExt on Iterable {
  static Iterable<S> mapNotNull<I, S>(
    Iterable<I> iterable,
    da.Mapper<I, S?> mapper,
  ) sync* {
    for (final item in iterable) {
      final value = mapper(item);
      if (value == null) continue;
      yield value;
    }
  }

  static List<S> mapToListNotNull<I, S>(
    Iterable<I> iterable,
    da.Mapper<I, S?> mapper,
  ) {
    final list = <S>[];
    for (final item in iterable) {
      list.addIfNotNull(mapper(item));
    }
    return list;
  }
}

///
///
///
extension DateTimeExtension on DateTime {
  static DateTime normalizeDate(DateTime datetime) =>
      DateTime.utc(datetime.year, datetime.month, datetime.day);

  static int dayOfYear(DateTime date) =>
      DateTime.utc(
        date.year,
      ).difference(DateTime.utc(date.year, date.month, date.day)).inDays +
      1;

  static int weekYearIndexOf(
    DateTime date, [
    int startingDay = DateTime.sunday,
  ]) {
    final startingDate = DateTime.utc(date.year);
    final days = startingDate.difference(normalizeDate(date)).inDays;
    final remains = days % DateTime.daysPerWeek;
    final weeks = days ~/ 7;
    if (remains == 0) return weeks;

    final previousDays = (startingDate.weekday - startingDay) % 7;
    if (remains + previousDays > DateTime.daysPerWeek) return weeks + 1;
    return weeks;
  }

  ///
  ///
  ///
  static bool anyInvalidWeekday(Set<int> days) =>
      days.any((day) => day < DateTime.monday || day > DateTime.sunday);

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

  static bool predicateBefore(
    DateTime date,
    DateTime lastDate, [
    bool inclusive = true,
  ]) =>
      date.isBefore(lastDate) ||
      (inclusive && da.DateTimeExtension.predicateSameDate(date, lastDate));

  static bool predicateAfter(
    DateTime date,
    DateTime firstDate, [
    bool inclusive = true,
  ]) =>
      date.isAfter(firstDate) ||
      (inclusive && da.DateTimeExtension.predicateSameDate(date, firstDate));

  ///
  ///
  ///
  static bool predicateBeforeMonth(DateTime day1, DateTime day2) =>
      day1.year == day2.year ? day1.month < day2.month : day1.isBefore(day2);

  static bool predicateAfterMonth(DateTime day1, DateTime day2) =>
      day1.year == day2.year ? day1.month > day2.month : day1.isBefore(day2);

  static bool predicateIn(DateTime day, DateTime start, DateTime end) {
    if (day.isAfter(start) && day.isBefore(end)) return true;
    return false;
  }

  static bool predicateWithin(DateTime day, DateTime start, DateTime end) {
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

  // static int monthRowsOf(DateTime date, [int startingDay = DateTime.sunday]) =>
  //     (1 +
  //         firstDateOfWeekInMonth(
  //           date,
  //         ).difference(lastDateOfWeekInMonth(date, startingDay)).inDays) ~/
  //     7;
}
