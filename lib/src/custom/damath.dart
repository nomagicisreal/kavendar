import 'package:damath/damath.dart';

///
/// prevent error message be string in [Object] extension
/// rename [printThing] to printThis with mapper and Object?
/// update all DateTime utc functions to normal construction, utc must named with utc
///
/// set next(covariant NodeNext<T, N>? node) =>
/// to N?
///

typedef ListenListener = void Function(void Function());
typedef IndexingDate = DateTime Function(int index);

extension NodeNextExtension<T, N extends NodeNext<T, N>> on N {
  bool contains(T value) {
    for (N? node = this; node != null; node = node.next) {
      if (value == node.data) return true;
    }
    return false;
  }

  N? nodeFrom(T value) {
    for (
      N? current = this, next = current.next;
      next != null;
      current = next, next = next.next
    ) {
      if (value == current?.data) return current;
    }
    return null;
  }

  static const String cuttingOnHeadNode = 'cutting on head node';

  ///
  /// [cutFirst] for example:
  /// ```dart
  /// print(node); // A - A - B - B - C - C
  /// print(node.cutFirst(B)); // false
  /// print(node); // A - A - B - C - C
  ///
  /// print(node2); // B - B - C - C
  /// if (node2.cutFirst(B)) { // true
  ///   node2 = node2.next;
  /// }
  /// print(node2); // B - C - C
  /// ```
  ///
  bool cutFirst(T value) {
    if (value == data) return false;
    for (
      N? current = this, next = current.next, nextNext = next?.next;
      next != null;
      current = next, next = next.next, nextNext = next?.next
    ) {
      if (value == next.data) {
        current?.next = nextNext;
        return true;
      }
    }
    return true;
  }
}

///
///
///
extension DTExt on DateTime {
  ///
  ///
  ///
  static double pageFrom(DateTime start, DateTime target, int weeksPerPage) =>
      (target.difference(start).inDays + 1) /
      (DateTime.daysPerWeek * weeksPerPage);

  ///
  ///
  ///
  static bool predicateFalse(DateTime date) => false;

  static bool predicateToday(DateTime date) => date.isSameDate(DateTime.now());

  static bool predicateWeekend(DateTime date) {
    final day = date.weekday;
    return day == DateTime.sunday || day == DateTime.saturday;
  }

  static bool predicateWeekday(DateTime date) {
    final day = date.weekday;
    return day == DateTime.monday ||
        day == DateTime.tuesday ||
        day == DateTime.wednesday ||
        day == DateTime.thursday ||
        day == DateTime.friday;
  }

  ///
  ///
  ///
  static DateTime max(DateTime date1, DateTime date2) =>
      date1.isBefore(date2) ? date2 : date1;

  static DateTime min(DateTime date1, DateTime date2) =>
      date1.isBefore(date2) ? date1 : date2;

  ///
  ///
  ///
  static IndexingDate daysToDateClampFrom(
    DateTime start,
    DateTime end, {
    bool fullWeek = true,
    int startingWeekday = DateTime.sunday,
    int times = 1,
  }) {
    if (fullWeek) {
      start = start.firstDateOfWeek(startingWeekday);
      end = end.firstDateOfWeek(startingWeekday);
    } else {
      throw UnimplementedError();
    }
    return (days) {
      final date = DateTime(start.year, start.month, start.day + days * times);
      return date.isAfter(end) ? end : date;
    };
  }

  ///
  /// [isSameDate], [isDifferentDate]
  /// [isSameTime], [isDifferentTime]
  ///
  bool isSameDate(DateTime another) =>
      year == another.year && month == another.month && day == another.day;

  bool isDifferentDate(DateTime another) =>
      year != another.year || month != another.month || day != another.day;

  bool isSameTime(DateTime another) =>
      hour == another.hour &&
      minute == another.minute &&
      second == another.second;

  bool isDifferentTime(DateTime another) =>
      hour != another.hour ||
      minute != another.minute ||
      second != another.second;

  ///
  /// [dateOnly], [timeOnly], [plus]
  ///
  DateTime get dateOnly => DateTime(year, month, day);

  Duration get timeOnly =>
      Duration(hours: hour, minutes: minute, seconds: second);

  DateTime plus({
    int year = 0,
    int month = 0,
    int day = 0,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  }) => DateTime(
    this.year + year,
    this.month + month,
    this.day + day,
    this.hour + hour,
    this.minute + minute,
    this.second + second,
    this.millisecond + millisecond,
    this.microsecond + microsecond,
  );

  ///
  /// [addYears], [dateAddYears]
  ///
  DateTime addYears(
    int n, {
    bool keepMonth = true,
    bool keepDay = true,
    bool keepHour = false,
    bool keepMinute = false,
    bool keepSecond = false,
    bool keepMillisecond = false,
    bool keepMicrosecond = false,
  }) => DateTime(
    year + n,
    keepMonth ? month : 0,
    keepDay ? day : 0,
    keepHour ? hour : 0,
    keepMinute ? minute : 0,
    keepSecond ? second : 0,
    keepMillisecond ? millisecond : 0,
    keepMicrosecond ? microsecond : 0,
  );

  DateTime dateAddYears(int n) => DateTime(year + n, month, day);

  ///
  /// [addMonths], [dateAddMonths]
  ///
  DateTime addMonths(
    int n, {
    bool keepDay = true,
    bool keepHour = false,
    bool keepMinute = false,
    bool keepSecond = false,
    bool keepMillisecond = false,
    bool keepMicrosecond = false,
  }) => DateTime(
    year,
    month + n,
    keepDay ? day : 0,
    keepHour ? hour : 0,
    keepMinute ? minute : 0,
    keepSecond ? second : 0,
    keepMillisecond ? millisecond : 0,
    keepMicrosecond ? microsecond : 0,
  );

  DateTime dateAddMonths(int n) => DateTime(year, month + n, day);

  DateTime dateAddDays(int n) => DateTime(year, month, day + n);

  ///
  ///
  ///
  DateTime addDays(
    int n, {
    bool keepHour = false,
    bool keepMinute = false,
    bool keepSecond = false,
    bool keepMillisecond = false,
    bool keepMicrosecond = false,
  }) => DateTime(
    year,
    month,
    day + n,
    keepHour ? hour : 0,
    keepMinute ? minute : 0,
    keepSecond ? second : 0,
    keepMillisecond ? millisecond : 0,
    keepMicrosecond ? microsecond : 0,
  );

  ///
  /// [datesGenerateFrom], [datesGenerate]
  /// [datesGenerateBegin], [datesGenerateBack]
  ///
  List<DateTime> datesGenerateFrom(int length, [int from = 0]) =>
      List.generate(length, (i) => DateTime(year, month, day + from + i));

  List<DateTime> datesGenerate(int length) =>
      List.generate(length, (i) => DateTime(year, month, day + i));

  List<DateTime> datesGenerateBegin(int length, [int begin = 0]) =>
      List.generate(length, (i) => DateTime(year, month, day + begin - i));

  List<DateTime> datesGenerateBack(int length) =>
      List.generate(length, (i) => DateTime(year, month, day - i));
}
