import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/data/mobile_money_operator.dart';

void main() {
  group('MobileMoneyOperator.detect', () {
    test('MTN prefixes: 650–654, 670–679, 680–684', () {
      for (final prefix in [650, 651, 652, 653, 654, 670, 675, 679, 680, 684]) {
        expect(MobileMoneyOperator.detect('${prefix}123456'),
            MobileMoneyOperator.mtn,
            reason: '$prefix');
      }
    });

    test('Orange prefixes: 640, 655–659, 686–689, 690–699', () {
      for (final prefix in [640, 655, 659, 686, 689, 690, 695, 699]) {
        expect(MobileMoneyOperator.detect('${prefix}123456'),
            MobileMoneyOperator.orange,
            reason: '$prefix');
      }
    });

    test('unknown prefixes and numbers too short are not recognised', () {
      for (final input in ['685123456', '660123456', '620123456', '65', '']) {
        expect(MobileMoneyOperator.detect(input), isNull, reason: input);
      }
    });

    test('detected from the first 3 digits, whatever the formatting', () {
      expect(MobileMoneyOperator.detect('677'), MobileMoneyOperator.mtn);
      expect(MobileMoneyOperator.detect('6 99 00 00 00'),
          MobileMoneyOperator.orange);
      expect(MobileMoneyOperator.detect('+237 650 00 00 00'),
          MobileMoneyOperator.mtn);
      expect(MobileMoneyOperator.detect('00237 690000000'),
          MobileMoneyOperator.orange);
    });
  });

  test('the number sent is +237 and the 9 digits', () {
    expect(MobileMoneyOperator.e164('6 78 26 72 82'), '+237678267282');
    expect(MobileMoneyOperator.e164('+237678267282'), '+237678267282');
    expect(MobileMoneyOperator.nationalDigits('237 6782672821'), '678267282');
  });

  test('operators read back from the API value', () {
    expect(MobileMoneyOperator.fromApi('orange'), MobileMoneyOperator.orange);
    expect(MobileMoneyOperator.fromApi('cm.mtn'), isNull);
  });
}
