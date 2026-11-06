import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Hands a text to the phone's share sheet (WhatsApp, SMS…) or to the clipboard. A provider, so
/// widget tests replace it with a fake.
class ShareService {
  const ShareService();

  Future<void> share(String text, {String? subject}) =>
      Share.share(text, subject: subject);

  Future<void> copy(String text) =>
      Clipboard.setData(ClipboardData(text: text));
}

final shareServiceProvider =
    Provider<ShareService>((_) => const ShareService());
