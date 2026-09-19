import 'package:flutter/material.dart';

enum ScreenSize { compact, medium, expanded }

ScreenSize screenSizeOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w < 600) return ScreenSize.compact;
  if (w < 1200) return ScreenSize.medium;
  return ScreenSize.expanded;
}

T byScreen<T>(BuildContext context,
    {required T compact, T? medium, T? expanded}) {
  return switch (screenSizeOf(context)) {
    ScreenSize.compact => compact,
    ScreenSize.medium => medium ?? compact,
    ScreenSize.expanded => expanded ?? medium ?? compact,
  };
}