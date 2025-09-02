import 'package:flutter/material.dart';

/// 一個會依可用空間自動縮放字體大小的文字元件。
///
/// 此元件會先以固定基準字級量測文字尺寸，再根據外部提供的
/// [constraints] 計算可縮放比例，讓文字盡可能完整顯示於指定範圍內。
class AutoScaleText extends StatelessWidget {
  /// 要顯示的文字內容。
  final String text;

  /// 文字的基礎樣式。
  ///
  /// 元件會以此樣式為基底，動態覆寫 `fontSize` 來產生最終顯示效果。
  final TextStyle baseStyle;

  /// 此文字元件可使用的版面限制。
  ///
  /// 通常由父層版面配置提供，用來決定文字可縮放到的最大範圍。
  final BoxConstraints constraints;

  /// 建立一個可自動縮放文字大小的 [AutoScaleText]。
  const AutoScaleText({
    super.key,
    required this.text,
    required this.baseStyle,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 TextPainter 先以固定字級進行文字量測，
    // 作為後續計算縮放比例的基準尺寸。
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: baseStyle.copyWith(fontSize: 100)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    // 計算文字在寬度方向可縮放的比例。
    double scaleX = constraints.maxWidth / textPainter.width;

    // 計算文字在高度方向可縮放的比例。
    double scaleY = constraints.maxHeight / textPainter.height;

    // 取寬、高兩方向中較小的縮放值，
    // 確保文字可同時容納於可用寬度與高度內，
    // 並額外保留一些安全邊距避免貼齊邊界。
    double scale = (scaleX < scaleY ? scaleX : scaleY) * 0.85; // 保留安全邊距

    return Text(
      text,
      textAlign: TextAlign.center,
      // 依計算後的比例動態調整字級。
      style: baseStyle.copyWith(fontSize: 100 * scale),
    );
  }
}
