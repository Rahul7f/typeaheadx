import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Defines customizable styles for TypeAheadX.
class TypeAheadXStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color highlightColor;
  final Color textColor;
  final TextStyle hintStyle;
  final TextStyle textStyle;
  final BorderRadius borderRadius;
  final double borderWidth;

  const TypeAheadXStyle({
    this.backgroundColor = AppColors.white,
    this.borderColor = AppColors.border,
    this.highlightColor = AppColors.highlight,
    this.textColor = AppColors.black,
    this.hintStyle = const TextStyle(fontSize: 14, color: Colors.grey),
    this.textStyle = const TextStyle(fontSize: 14, color: Colors.black),
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.borderWidth = 1.0,
  });
}
