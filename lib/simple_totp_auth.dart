import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:base32/base32.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:pretty_qr_code/pretty_qr_code.dart';

class TOTP {
  final String secret;
  final int interval;
  final int digits;

  TOTP({
    required this.secret,
    this.interval = 30,
    this.digits = 6,
  });

  /// Generates a random Base32-encoded secret key (e.g., 160-bit key = 32 chars).
  static String generateSecret({int bytes = 10}) {
    final random = Random.secure();
    final keyBytes = List<int>.generate(bytes, (_) => random.nextInt(256));
    final encoded = base32.encode(Uint8List.fromList(keyBytes));
    return encoded.replaceAll('=', ''); // Remove padding
  }


  int _getTimeCounter({int? time}) {
    final secondsSinceEpoch = (time ?? DateTime.now().millisecondsSinceEpoch) ~/ 1000;
    return secondsSinceEpoch ~/ interval;
  }

  String _generateHOTP(int counter) {
    final key = base32.decode(secret);
    final counterBytes = _intToBytelist(counter);
    final hmac = Hmac(sha1, key).convert(counterBytes).bytes;

    final offset = hmac.last & 0x0f;
    final binaryCode = ((hmac[offset] & 0x7f) << 24) |
    ((hmac[offset + 1] & 0xff) << 16) |
    ((hmac[offset + 2] & 0xff) << 8) |
    (hmac[offset + 3] & 0xff);

    final otp = binaryCode % pow(10, digits).toInt();
    return otp.toString().padLeft(digits, '0');
  }

  String now() {
    return _generateHOTP(_getTimeCounter());
  }

  bool verify(String code, {int tolerance = 1}) {
    final currentCounter = _getTimeCounter();
    for (int i = -tolerance; i <= tolerance; i++) {
      if (_generateHOTP(currentCounter + i) == code) {
        return true;
      }
    }
    return false;
  }

  List<int> _intToBytelist(int value) {
    final result = List.filled(8, 0);
    for (int i = 7; i >= 0; i--) {
      result[i] = value & 0xff;
      value >>= 8;
    }
    return result;
  }

  /// Generates otpauth:// URI for use in QR codes
  String generateOTPAuthURI({
    required String issuer,
    required String account,
  }) {
    return 'otpauth://totp/$issuer:$account?secret=$secret&issuer=$issuer&digits=$digits&period=$interval';
  }

  static Future<String> copyToClipboard(String text) async {
    try {
      if (kIsWeb) {
        // Browsers only allow clipboard access during user interaction (click/tap)
        // So this works only in a user-triggered callback
        await Clipboard.setData(ClipboardData(text: text));
      } else {
        await Clipboard.setData(ClipboardData(text: text));
      }
      return "Success";
    } catch (e) {
      return "Clipboard not supported: $e";
    }
  }
}

@immutable
enum LogoType { asset, network, none }

@immutable
class TOTPQrWidget extends StatelessWidget {
  final String secret;
  final String issuer;
  final String accountName;
  final LogoType logoType;
  final String? logoPath;

  final double width, height;
  final Color color, radiusColor;
  final double radius, radiusWidth, margin, padding;

  const TOTPQrWidget({
    super.key,
    required this.secret,
    required this.issuer,
    required this.accountName,
    this.logoType = LogoType.none,
    this.logoPath,
    this.width = 100,
    this.height = 100,
    this.color = Colors.white,
    this.radiusColor = Colors.white,
    this.radius = 0,
    this.radiusWidth = 0,
    this.padding = 0,
    this.margin = 0,
  });

  ImageProvider? get logo {
    if (logoType == LogoType.asset && logoPath != null) {
      return AssetImage(logoPath!);
    } else if (logoType == LogoType.network && logoPath != null) {
      return NetworkImage(logoPath!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final totp = TOTP(secret: secret);
    final uri = totp.generateOTPAuthURI(issuer: issuer, account: accountName);

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: radiusColor,
          width: radiusWidth,
        ),
      ),
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.all(padding),
      width: width,
      height: width,
      child: PrettyQrView.data(
        data: uri,
        decoration: PrettyQrDecoration(
          image: logo != null ? PrettyQrDecorationImage(image: logo!) : PrettyQrDecorationImage(image: NetworkImage("https://ibb.co/3Y80JG2P")),
          quietZone: PrettyQrQuietZone.standart,
        ),
      ),
    );
  }
}
