import 'package:damath/damath.dart';

///
/// rename [printThing] to printThis with mapper and Object?
///
///
extension DTExt on DateTime {
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

  DateTime dateAddDays(int n) => DateTime(year, month, day + n);

  ///
  /// [dates], [datesFromNowTo]
  /// [datesFrom], [datesToNowFrom]
  ///
  List<DateTime> dates(int length, [int from = 0]) =>
      List.generate(length, (i) => DateTime(year, month, day + from + i));

  List<DateTime> datesFromNowTo(int length) =>
      List.generate(length, (i) => DateTime(year, month, day + i));

  List<DateTime> datesFrom(int length, [int begin = 0]) =>
      List.generate(length, (i) => DateTime(year, month, day + begin - i));

  List<DateTime> datesToNowFrom(int length) =>
      List.generate(length, (i) => DateTime(year, month, day - i));
}
