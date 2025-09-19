import 'package:flutter/material.dart';
import 'package:evernight_board/global.dart';

/// 文字编辑对话框。
///
/// 用于让使用者输入或编辑单行／多行文字，并在按下确认后
/// 透过 [onConfirm] 将最新文字内容回传给呼叫端。
class EditTextDialog extends StatefulWidget {
  /// 对话框标题。
  final String title;

  /// 初始显示的文字内容。
  final String initialValue;

  /// 是否启用多行输入模式。
  ///
  /// - `true`：输入框可输入多行文字。
  /// - `false`：输入框仅允许单行输入。
  final bool isMultiline;

  /// 使用者按下确认按钮时的回呼函式。
  ///
  /// 传入值为目前输入框中的文字内容。
  final Function(String) onConfirm;

  /// 建立一个文字编辑对话框。
  const EditTextDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onConfirm,
    this.isMultiline = false,
  });

  @override
  State<EditTextDialog> createState() => _EditTextDialogState();
}

/// [EditTextDialog] 的状态物件。
///
/// 负责管理输入框控制器生命週期，以及确认／取消操作。
class _EditTextDialogState extends State<EditTextDialog> {
  /// 文字输入控制器。
  ///
  /// 用于控制输入框内容，并在确认时读取最新文字。
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    // 以外部传入的初始值建立控制器，确保对话框开启时可直接显示既有内容。
    _textController = TextEditingController(text: widget.initialValue);

    debugPrint(
      '[EditTextDialog] title: ${widget.title}，'
      'isMultiline: ${widget.isMultiline}，'
      'initialValueLength: ${widget.initialValue.length}',
    );
  }

  @override
  void dispose() {
    // 釋放文字控制器，避免記憶體洩漏。
    debugPrint('[EditTextDialog] 釋放 TextEditingController');
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 根據輸入模式決定鍵盤型態與最大行數。
    final keyboardType = widget.isMultiline
        ? TextInputType.multiline
        : TextInputType.text;
    final maxLines = widget.isMultiline ? null : 1;

    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _textController,
        autofocus: true,

        // 多行模式下不限制行數；單行模式固定為 1 行。
        maxLines: maxLines,

        // 多行模式使用 multiline 鍵盤，其餘使用一般文字鍵盤。
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: t.entercontent,
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            debugPrint('[EditTextDialog] 使用者取消編輯');
            Navigator.pop(context);
          },
          child: Text(t.cancel),
        ),
        TextButton(
          onPressed: () {
            final value = _textController.text;

            debugPrint('[EditTextDialog] 使用者確認編輯，輸入長度: ${value.length}');

            // 將最新輸入內容回傳給呼叫端。
            widget.onConfirm(value);

            // 關閉目前對話框並返回上一層。
            Navigator.pop(context);
          },
          child: Text(t.ok),
        ),
      ],
    );
  }
}
