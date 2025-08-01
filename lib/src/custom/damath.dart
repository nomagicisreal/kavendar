import 'package:damath/damath.dart';

///
///
/// implements [DatesContainer.firstDate]
///
///

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
