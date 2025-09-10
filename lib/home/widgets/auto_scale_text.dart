import 'package:flutter/material.dart';

/// 一個會依可用空間自動縮放字體大小的文字元件。
///
/// 此元件會先以固定基準字級量測文字尺寸，再根據外部提供的
/// [constraints] 計算適合的縮放比例，讓文字盡可能完整顯示於指定範圍內。
///
/// 適合用於：
/// - 卡片標題
/// - 儀表板數值
/// - 需在固定區塊內完整顯示的短文字
///
/// 注意：
/// - 此元件較適合單行或短文字內容。
/// - 若 [constraints] 為無界（infinite），縮放結果可能不如預期。
class AutoScaleText extends StatelessWidget {
  /// 要顯示的文字內容。
  final String text;

  /// 文字的基礎樣式。
  ///
  /// 元件會以此樣式為基底，動態覆寫 `fontSize`，
  /// 以產生最終顯示效果。
  final TextStyle baseStyle;

  /// 此文字元件可使用的版面限制。
  ///
  /// 通常由父層版面配置提供，用來決定文字可縮放的最大範圍。
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
    // 先用固定的大字級進行量測，取得文字的基準寬高，
    // 後續再依據可用空間換算出實際顯示時應使用的縮放比例。
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: baseStyle.copyWith(fontSize: 100)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    // 當可用寬度或高度為無界，或量測結果異常時，
    // 輸出除錯資訊，方便追查版面配置來源。
    if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
      debugPrint(
        '[AutoScaleText] 收到無界 constraints，可能影響文字縮放結果。'
        ' width=${constraints.maxWidth}, height=${constraints.maxHeight}',
      );
    }

    if (textPainter.width == 0 || textPainter.height == 0) {
      debugPrint(
        '[AutoScaleText] 文字量測結果為 0，請檢查 text 或 baseStyle。'
        ' text="$text", width=${textPainter.width}, height=${textPainter.height}',
      );
    }

    // 計算文字在寬度方向可縮放的比例。
    final double scaleX = constraints.maxWidth / textPainter.width;

    // 計算文字在高度方向可縮放的比例。
    final double scaleY = constraints.maxHeight / textPainter.height;

    // 取寬、高兩方向中較小的縮放值，
    // 確保文字可同時容納於可用寬度與高度內。
    //
    // 再乘上 0.85 預留安全邊距，避免文字過度貼齊容器邊界，
    // 讓視覺上保有較自然的留白。
    double scale = (scaleX < scaleY ? scaleX : scaleY) * 0.85;

    // 避免因極端版面條件導致字級為 0、負值或非數值，
    // 進而造成顯示異常。
    if (scale.isNaN || scale.isInfinite || scale <= 0) {
      debugPrint(
        '[AutoScaleText] 計算出的縮放比例異常，改用預設比例 1.0。'
        ' scale=$scale, scaleX=$scaleX, scaleY=$scaleY',
      );
      scale = 1.0;
    }

    return Text(
      text,
      textAlign: TextAlign.center,
      // 依計算後的比例動態調整字級，
      // 以固定基準字級 100 為換算基底。
      style: baseStyle.copyWith(fontSize: 100 * scale),
    );
  }
}
