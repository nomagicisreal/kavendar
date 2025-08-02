// mamion nullable child
// implement AnimatedContainer
// between.double0To1
// between.offsetTo ltrb
// update private typedef names

import 'package:datter/datter.dart';
import 'package:flutter/material.dart';

extension FAni on Ani {
  static void consumeForwardThenReverse(AnimationController controller) =>
      controller.forward().then((_) => controller.reverse());

  static void Function(AnimationController controller) decideForwardThenReverse(
    bool trigger,
  ) => trigger ? consumeForwardThenReverse : Ani.consumeNothing;
}
