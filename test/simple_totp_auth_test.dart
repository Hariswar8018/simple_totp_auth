import 'package:flutter_test/flutter_test.dart';
import 'package:simple_totp_auth/simple_totp_auth.dart' show TOTP;

void main() {
  test('Generate and verify TOTP', () {
    final totp = TOTP(secret: 'JBSWY3DPEHPK3PXP');
    final code = totp.now();
    expect(totp.verify(code), true);
  });
}
