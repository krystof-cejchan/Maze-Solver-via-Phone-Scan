import 'package:flutter/material.dart';

mixin KeyGen {
  static int _c = 0;
  static Key get generate => Key((_c++).toString());
}
