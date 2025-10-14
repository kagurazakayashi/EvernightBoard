import 'package:flutter/material.dart';

/// 可依可用空間自動縮放字體大小的文字元件。
///
/// 此元件會將整段文字視為單一排版區塊，並透過 [FittedBox]
/// 在既有約束下等比例縮放，讓文字盡可能以最大的尺寸顯示於可用範圍內。
///
/// 行為特性如下：
///
/// - 支援透過 `\n` 顯式換行
/// - 不會因容器寬度不足而自動換行
/// - 文字內容會維持水平與垂直置中
/// - 縮放時會保留固定比例的安全邊距，避免內容過度貼齊容器邊界
class AutoScaleText extends StatelessWidget {
  /// 要顯示的文字內容。
  final String text;

  /// 文字的基礎樣式。
  ///
  /// 實際顯示大小可能會依可用空間由元件自動縮放。
  final TextStyle baseStyle;

  /// 父層提供的版面約束。
  ///
  /// 此欄位通常用於描述此元件所處的可用空間範圍。
  final BoxConstraints constraints;

  /// 建立一個可自動縮放文字大小的元件。
  ///
  /// [text] 為要顯示的文字內容。
  /// [baseStyle] 為文字的基礎樣式設定。
  /// [constraints] 為父層提供的版面約束資訊。
  const AutoScaleText({
    super.key,
    required this.text,
    required this.baseStyle,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    // Center 用於確保整個文字元件維持置中顯示。
    return Center(
      // FractionallySizedBox 用於預留 15% 的安全邊距，避免文字過度貼齊邊界。
      child: FractionallySizedBox(
        widthFactor: 0.85,
        heightFactor: 0.85,
        // FittedBox 會讓內部元件依外部可用空間等比例縮放，
        // 並透過 BoxFit.contain 確保內容完整顯示且不變形。
        child: FittedBox(
          fit: BoxFit.contain,
          // 由於 Text 被 FittedBox 包裹後，排版時可視為擁有寬鬆的可用寬度，
          // 因此不會因容器寬度不足而自動換行；只有在文字中明確包含 '\n'
          // 時才會換行，並將整個多行文字區塊視為單一整體進行縮放。
          child: Text(text, textAlign: TextAlign.center, style: baseStyle),
        ),
      ),
    );
  }
}
