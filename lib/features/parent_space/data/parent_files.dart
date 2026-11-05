import 'dart:io';

import 'package:open_file/open_file.dart';

/// Opens a PDF the API sent (contract, amendment, receipt): written to a temporary file,
/// then handed to the system viewer (share, print, save from there).
class ParentFiles {
  const ParentFiles();

  /// Returns false when no application could open the file.
  Future<bool> openPdf(List<int> bytes, String name) async {
    final safe = name.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
    final file = File('${Directory.systemTemp.path}/$safe');
    await file.writeAsBytes(bytes, flush: true);
    final result =
        await OpenFile.open(file.path, type: 'application/pdf');
    return result.type == ResultType.done;
  }
}
