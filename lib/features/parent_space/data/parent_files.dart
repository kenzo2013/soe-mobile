import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

/// Opens a PDF the API sent (contract, amendment, receipt): written to a temporary file,
/// then shown by the system viewer (share, print, save from there).
///
/// On iOS the app's own QuickLook screen (`soe/pdf_preview`, see `AppDelegate.swift`) wraps
/// the preview in a bar with a close button: the bare system preview has none.
class ParentFiles {
  const ParentFiles({this.preview = const MethodChannel('soe/pdf_preview')});

  final MethodChannel preview;

  /// Returns false when no application could open the file.
  Future<bool> openPdf(List<int> bytes, String name,
      {String? title, String? closeLabel}) async {
    final safe = name.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
    final file = File('${Directory.systemTemp.path}/$safe');
    await file.writeAsBytes(bytes, flush: true);
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        await _preview(file.path, title, closeLabel)) {
      return true;
    }
    final result = await OpenFile.open(file.path, type: 'application/pdf');
    return result.type == ResultType.done;
  }

  /// True when the app's preview showed the file; false sends it to the system viewer.
  Future<bool> _preview(String path, String? title, String? close) async {
    try {
      return await preview.invokeMethod<bool>(
              'open', {'path': path, 'title': title, 'close': close}) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
