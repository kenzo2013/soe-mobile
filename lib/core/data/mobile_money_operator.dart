/// The Mobile Money operators SOE takes (payment of an invoice), and how a Cameroonian number
/// tells which one it belongs to.
///
/// Prefixes of the 9-digit national numbers, to confirm with NotchPay; the web
/// (`soe` repository, MobileMoneyOperator) uses the same table:
/// - MTN: 650–654, 670–679, 680–684
/// - Orange: 640, 655–659, 686–689, 690–699
/// Any other prefix is unknown: the parent chooses the operator.
enum MobileMoneyOperator {
  mtn(apiValue: 'mtn', logoAsset: 'assets/images/payment/mtn_momo.png'),
  orange(
      apiValue: 'orange', logoAsset: 'assets/images/payment/orange_money.png');

  const MobileMoneyOperator({required this.apiValue, required this.logoAsset});

  /// The `operator` sent to `POST /parent/invoices/:id/pay`.
  final String apiValue;
  final String logoAsset;

  static const countryCode = '+237';

  /// The 9 national digits of [input] (spaces, dashes and a leading +237 / 00237 / 237 dropped),
  /// as far as typed.
  static String nationalDigits(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00237')) digits = digits.substring(5);
    if (digits.startsWith('237') && digits.length > 9) {
      digits = digits.substring(3);
    }
    return digits.length > 9 ? digits.substring(0, 9) : digits;
  }

  /// The number to send: +237 and the 9 digits.
  static String e164(String input) => '$countryCode${nationalDigits(input)}';

  /// The operator of [input], once its first 3 digits are typed; null when the prefix is unknown.
  static MobileMoneyOperator? detect(String input) {
    final digits = nationalDigits(input);
    if (digits.length < 3) return null;
    final prefix = int.parse(digits.substring(0, 3));
    if ((prefix >= 650 && prefix <= 654) ||
        (prefix >= 670 && prefix <= 679) ||
        (prefix >= 680 && prefix <= 684)) {
      return mtn;
    }
    if (prefix == 640 ||
        (prefix >= 655 && prefix <= 659) ||
        (prefix >= 686 && prefix <= 689) ||
        (prefix >= 690 && prefix <= 699)) {
      return orange;
    }
    return null;
  }

  static MobileMoneyOperator? fromApi(String? value) =>
      values.where((operator) => operator.apiValue == value).firstOrNull;
}
