import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/tutor_space/data/tutor_money_models.dart';

void main() {
  test('parses a statement', () {
    final s = TutorStatement.fromJson(const {
      'id': 1,
      'period': '2026-10-01',
      'receipt_number': null,
      'amount': 39000,
      'sessions': 6,
      'status': 'processing',
      'status_label': 'Virement en cours',
      'paid_at': null,
      'has_receipt': false,
    });
    expect(s.period, DateTime(2026, 10));
    expect(s.status, 'processing');
    expect(s.hasReceipt, isFalse);
  });

  test('parses a payout method', () {
    final m = TutorPayoutMethod.fromJson(const {
      'id': 2,
      'kind': 'bank',
      'operator': null,
      'name': 'Afriland First Bank',
      'detail': 'Compte •••• 0045',
      'default': false,
      'can_be_default': false,
    });
    expect(m.isMobile, isFalse);
    expect(m.isDefault, isFalse);
    expect(m.detail, 'Compte •••• 0045');
  });

  test('parses an amendment with its text', () {
    final a = TutorAmendment.fromJson(const {
      'id': 4,
      'contract_id': 7,
      'reference': 'AV-1',
      'status': 'pending',
      'status_label': 'En attente',
      'created_at': '2026-10-20T10:00:00Z',
      'signed_at': null,
      'can_sign': false,
      'lang': 'fr',
      'text_format': 'html',
      'text': '<p>Texte</p>',
    });
    expect(a.status, 'pending');
    expect(a.text, '<p>Texte</p>');
  });

  group('tutorHtmlBlocks', () {
    test('splits paragraphs, titles and items, decodes entities', () {
      final blocks = tutorHtmlBlocks(
          '<h2>1. Mission</h2><p>SOE confie &agrave; Daniel l&#39;&eacute;l&egrave;ve &amp; plus.</p>'
          '<ul><li>Un</li><li>Deux</li></ul><p><strong>Article 2</strong></p><p>a<br>b</p>');
      expect(blocks.map((b) => b.text), [
        '1. Mission',
        "SOE confie à Daniel l'élève & plus.",
        'Un',
        'Deux',
        'Article 2',
        'a',
        'b',
      ]);
      expect(blocks[0].heading, isTrue);
      expect(blocks[1].heading, isFalse);
      expect(blocks[2].item, isTrue);
      expect(blocks[4].heading, isTrue);
    });

    test('an empty text gives no block', () {
      expect(tutorHtmlBlocks(''), isEmpty);
    });
  });

  test('tutorPlainBlocks finds the numbered titles', () {
    final blocks = tutorPlainBlocks(
        '1. Mission\nSOE confie le soutien.\n\n2. Rémunération\n\n7 500 FCFA par séance.');
    expect(blocks.map((b) => b.text), [
      '1. Mission',
      'SOE confie le soutien.',
      '2. Rémunération',
      '7 500 FCFA par séance.',
    ]);
    expect(blocks.where((b) => b.heading).length, 2);
  });
}
