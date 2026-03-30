import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const BoxShadow dropShadowForButtons = BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(2, 2),
    blurRadius: 25,
  );

  static const List<BoxShadow> button = <BoxShadow>[dropShadowForButtons];
}
