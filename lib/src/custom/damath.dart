import 'package:damath/damath.dart';

///
///
/// print this on dynamic
/// implements [DatesContainer.firstDate]
///
///

extension DExtension on double {
  static double lerpLinearForwardReverse(double value) =>
      (1 - (1 - 2 * value).abs());

  static double lerpLinearReverseForward(double value) =>
      (1 - 2 * value).abs();
}

extension DCExtension on DatesContainer {
  DateTime get firstDate {
    final date = dates.first;
    return DateTime(date.$1, date.$2, date.$3);
  }
}

///
/// [DTExt]
///

///
///
///
extension DTExt on DateTime {
  static double pageFrom(DateTime start, DateTime target, int weeksPerPage) =>
      (target.difference(start).inDays + 1) /
      (DateTime.daysPerWeek * weeksPerPage);
}
