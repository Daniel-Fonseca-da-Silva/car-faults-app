/// Donation details shown on the Support screen. Mirrors
/// `car-faults-web/lib/support-constants.ts` and the static Pix "BR Code"
/// pre-computed from `car-faults-web/lib/pix/generate-pix-br-code.ts` with
/// the same key/merchant data (amount left open, so the code below is
/// stable and doesn't need to be regenerated on-device).
abstract final class AppSupport {
  static const mbwayNumber = '+351 913 619 053';
  static const wisePayLink = 'https://wise.com/pay/me/danielf6030';
  static const pixKey = '309ecf2b-ec2b-4f9a-916b-061e298ab6fc';
  static const pixBrCode =
      '00020126580014br.gov.bcb.pix0136309ecf2b-ec2b-4f9a-916b-061e298ab6fc'
      '5204000053039865802BR5923DANIEL FONSECA DA SILVA6009TRES RIOS'
      '62070503***6304A7C1';
}
