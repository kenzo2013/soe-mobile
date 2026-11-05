import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/features/tutor_space/data/tutor_money_api.dart';
import 'package:soe/features/tutor_space/data/tutor_money_models.dart';

/// Answers every request with [status] and [body]; keeps the last request.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.status, this.body);

  final int status;
  final Map<String, dynamic> body;
  RequestOptions? last;
  String? sentBody;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    last = options;
    if (requestStream != null) {
      sentBody = utf8.decode(
          await requestStream.fold<List<int>>([], (all, c) => all..addAll(c)));
    }
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

(TutorMoneyApi, _FakeAdapter) _api(int status, Map<String, dynamic> body) {
  final adapter = _FakeAdapter(status, body);
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v2'))
    ..httpClientAdapter = adapter;
  return (TutorMoneyApi(dio), adapter);
}

void main() {
  group('TutorMoneyApi', () {
    test('reads a page of statements', () async {
      final (api, adapter) = _api(200, {
        'data': [
          {
            'id': 3,
            'period': '2026-10-01',
            'receipt_number': 'R-1',
            'amount': 58500,
            'sessions': 9,
            'status': 'paid',
            'status_label': 'Versé',
            'paid_at': '2026-11-06T10:00:00Z',
            'has_receipt': true,
          }
        ],
        'meta': {
          'page': 2,
          'per_page': 20,
          'total_count': 21,
          'total_pages': 2
        },
      });
      final page = await api.statements(page: 2);
      expect(adapter.last!.path, '/tutor/earnings/history');
      expect(adapter.last!.queryParameters['page'], 2);
      expect(page.items.single.receiptNumber, 'R-1');
      expect(page.page, 2);
      expect(page.hasMore, isFalse);
    });

    test('asks a receipt link', () async {
      final (api, adapter) = _api(200, {
        'data': {
          'url': 'https://api.test/api/v2/tutor/downloads?token=abc',
          'expires_at': '2026-11-05T10:05:00Z',
        },
        'meta': <String, dynamic>{},
      });
      final link = await api.receiptLink(3);
      expect(adapter.last!.path, '/tutor/earnings/receipts/3');
      expect(link.url.queryParameters['token'], 'abc');
      expect(link.expiresAt, isNotNull);
    });

    test('asks a contract PDF in a language', () async {
      final (api, adapter) = _api(200, {
        'data': {'url': 'https://x.test/d', 'expires_at': null},
        'meta': <String, dynamic>{},
      });
      await api.contractPdfLink(7, 'en');
      expect(adapter.last!.path, '/tutor/contracts/7/pdf');
      expect(adapter.last!.queryParameters['lang'], 'en');
    });

    test('sends a payout change with the details of its kind only', () async {
      final (api, adapter) = _api(201, {
        'data': {
          'id': 9,
          'action': 'add_mobile',
          'summary': 'MTN •• 4412',
          'sent_at': '2026-11-05T10:00:00Z',
          'expires_at': '2026-11-05T10:15:00Z',
          'confirmed_at': null,
        },
        'meta': <String, dynamic>{},
      });
      final change = await api.requestPayoutChange(
          const TutorPayoutChangeRequest(
              kind: TutorPayoutChangeKind.addMobile,
              currentPassword: 'secret',
              operator: 'mtn',
              phone: '677214412',
              bank: {'iban': 'X'}));
      expect(adapter.last!.path, '/tutor/payout_method_changes');
      final sent = jsonDecode(adapter.sentBody!) as Map<String, dynamic>;
      expect(sent, {
        'kind': 'add_mobile',
        'current_password': 'secret',
        'operator': 'mtn',
        'phone': '677214412',
      });
      expect(change.id, 9);
      expect(change.summary, 'MTN •• 4412');
    });

    test('a wrong code becomes a CodeFailure with the server message',
        () async {
      final (api, _) = _api(422, {
        'errors': [
          {
            'code': 'code_invalid',
            'message': 'Code incorrect.',
            'field': 'code'
          }
        ],
      });
      expect(
          () => api.confirmPayoutChange(9, '123456'),
          throwsA(isA<CodeFailure>()
              .having((f) => f.problem, 'problem', CodeProblem.invalid)
              .having((f) => f.message, 'message', 'Code incorrect.')));
    });

    test('too many requests becomes a RateLimitedFailure', () async {
      final (api, _) = _api(429, {
        'errors': [
          {'code': 'rate_limited', 'message': 'Trop de demandes.'}
        ],
      });
      expect(
          () => api.requestPayoutChange(const TutorPayoutChangeRequest(
              kind: TutorPayoutChangeKind.makeDefault,
              currentPassword: 'x',
              methodId: 1)),
          throwsA(isA<RateLimitedFailure>()));
    });

    test('reads the amendments of a contract', () async {
      final (api, adapter) = _api(200, {
        'data': [
          {
            'id': 4,
            'contract_id': 7,
            'reference': 'AV-1',
            'status': 'to_sign',
            'status_label': 'À signer',
            'created_at': '2026-10-20T10:00:00Z',
            'signed_at': null,
            'can_sign': true,
          }
        ],
        'meta': {
          'page': 1,
          'per_page': 100,
          'total_count': 1,
          'total_pages': 1
        },
      });
      final list = await api.amendments(7);
      expect(adapter.last!.path, '/tutor/contracts/7/amendments');
      expect(list.single.canSign, isTrue);
    });
  });

  group('TutorPayoutChangeRequest', () {
    test('a removal of the default sends its replacement', () {
      expect(
        const TutorPayoutChangeRequest(
                kind: TutorPayoutChangeKind.remove,
                currentPassword: 'p',
                methodId: 1,
                replacementId: 2)
            .toJson(),
        {
          'kind': 'remove',
          'current_password': 'p',
          'payment_information_id': 1,
          'replacement_id': 2,
        },
      );
    });

    test('a bank account sends the bank fields', () {
      final json = const TutorPayoutChangeRequest(
          kind: TutorPayoutChangeKind.addBank,
          currentPassword: 'p',
          bank: {'iban': 'CM21', 'bic': 'AFRI'}).toJson();
      expect(json['iban'], 'CM21');
      expect(json.containsKey('operator'), isFalse);
    });
  });
}
