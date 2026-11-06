import 'package:soe/core/push/push_client.dart';

/// Records the calls instead of reaching the OneSignal SDK.
class FakePushClient implements PushClient {
  FakePushClient({this.granted = false, this.canRequest = true});

  final List<String> calls = [];
  bool granted;
  bool canRequest;
  void Function(Map<String, dynamic> data)? openedHandler;

  @override
  bool get enabled => true;

  @override
  Future<void> login(String externalId) async => calls.add('login:$externalId');

  @override
  Future<void> logout() async => calls.add('logout');

  @override
  Future<void> setLanguage(String languageCode) async =>
      calls.add('language:$languageCode');

  @override
  bool get permissionGranted => granted;

  @override
  Future<bool> canRequestPermission() async => canRequest;

  @override
  Future<bool> requestPermission() async {
    calls.add('requestPermission');
    return true;
  }

  @override
  void onOpened(void Function(Map<String, dynamic> data) handler) =>
      openedHandler = handler;
}
