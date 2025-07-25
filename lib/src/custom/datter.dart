import 'package:damath/damath.dart';
import 'package:flutter/material.dart';
import 'package:kavendar/kavendar.dart';
import 'package:kavendar/src/custom/damath.dart';

///
/// remove [printThis]
/// remove all utc
///
typedef ConstraintsDateBuilder =
    Widget Function(BoxConstraints constraints, DateTime date);

typedef ConstraintsDateCellTypeBuilder =
    Widget? Function(
      BoxConstraints constraints,
      DateTime date,
      CalendarCellType cellType,
    );

///
///
///
typedef PageStepper =
Future<void> Function({required Duration duration, required Curve curve});

typedef PageStepperBuilder = Widget Function(PageStepper stepper);

///
/// remove StylePositionedLayout
///
typedef PositionedLayout =
    Positioned4Double Function(BoxConstraints constraints);

///
///
/// DateTimeExtension static to instance
///
///
extension DTRExt on DateTimeRange {
  DateTimeRange get normalized => DateTimeRange(start: start.normalized, end: end.normalized);

  ///
  /// [scopeFrom], [scopeMonthsFrom]
  ///
  static DateTimeRange scopeFrom(
    DateTime date, {
    int yearsBefore = 0,
    int monthsBefore = 0,
    int daysBefore = 0,
    int hoursBefore = 0,
    int minutesBefore = 0,
    int secondsBefore = 0,
    int yearsAfter = 0,
    int monthsAfter = 0,
    int daysAfter = 0,
    int hoursAfter = 0,
    int minutesAfter = 0,
    int secondsAfter = 0,
  }) => DateTimeRange(
    start: date.plus(
      year: -yearsBefore,
      month: -monthsBefore,
      day: -daysBefore,
      hour: -hoursBefore,
      minute: -minutesBefore,
      second: -secondsBefore,
    ),
    end: date.plus(
      year: yearsAfter,
      month: monthsAfter,
      day: daysAfter,
      hour: hoursAfter,
      minute: minutesAfter,
      second: secondsAfter,
    ),
  );

  static DateTimeRange scopeMonthsFrom(
    DateTime date, {
    int before = 0,
    int after = 0,
  }) => DateTimeRange(
    start: date.plus(month: -before).firstDateOfMonth,
    end: date.plus(month: after).lastDateOfMonth,
  );

  ///
  ///
  ///
  bool contains(DateTime dateTime, [bool inclusive = true]) =>
      (dateTime.isAfter(start) && dateTime.isBefore(end)) ||
      (!inclusive || dateTime.isSameDate(start) || dateTime.isSameDate(end));
}
