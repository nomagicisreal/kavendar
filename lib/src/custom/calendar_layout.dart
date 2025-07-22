part of 'calendar.dart';

// ///
// ///
// /// [shapeFrom], ...
// ///
// ///
// abstract class CalendarSetup {
//   final ResponsiveShape shape;
//   final ScrollWay? scrollWay; // null means not scrollable
//   final Alignment? headerAlignment; // null means no header
//
//   const CalendarSetup(this.shape, this.scrollWay, [this.headerAlignment])
//     : assert(
//         (shape == ResponsiveShape.horizontalRail ||
//                 shape == ResponsiveShape.verticalRail) &&
//             (scrollWay == ScrollWay.graph),
//         "it's bad design to scroll navigation rail with 2 dimension",
//       ),
//       assert(
//         shape == ResponsiveShape.horizontalView ||
//             shape == ResponsiveShape.almostSquare ||
//             shape == ResponsiveShape.verticalView,
//         'unimplement scroll way ($scrollWay)',
//       ),
//       assert(
//         scrollWay == null || scrollWay == ScrollWay.horizontal,
//         'unimplement shape ($shape)',
//       ),
//       assert(
//         headerAlignment == null || headerAlignment == Alignment.topCenter,
//         'unimplement header alignment ($headerAlignment)',
//       );
//
//   ///
//   /// statics
//   ///
//
//   /// [aspectRatio] is width/height, which is the standard convention
//   static ResponsiveShape shapeFrom(double aspectRatio) => switch (aspectRatio) {
//     >= _ratioToHorizontalRail => ResponsiveShape.horizontalRail,
//     >= _ratioToHorizontalView => ResponsiveShape.horizontalView,
//     > _ratioToVerticalView => ResponsiveShape.almostSquare,
//     > _ratioToVerticalRail => ResponsiveShape.verticalView,
//     > 0 => ResponsiveShape.verticalRail,
//     double() => throw StateError('invalid aspect ratio: $aspectRatio'),
//   };
//
//   static const double _ratioToHorizontalRail = 2.0; // 2:1
//   static const double _ratioToHorizontalView = 1.25; // 5:4
//   static const double _ratioToVerticalView = 0.8; // 4:5
//   static const double _ratioToVerticalRail = 0.5; // 1:2
// }
