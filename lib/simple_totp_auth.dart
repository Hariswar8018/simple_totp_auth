import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:base32/base32.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:pretty_qr_code/pretty_qr_code.dart';

/// A class for generating and verifying Time-based One-Time Passwords (TOTP)
/// compatible with Google Authenticator, Authy, etc.
class TOTP {
  /// The Base32-encoded secret key.
  final String secret;

  /// The validity period for each code in seconds. Default is 30 seconds.
  final int interval;

  /// Number of digits in the generated OTP code. Default is 6 digits.
  final int digits;

  /// Creates a [TOTP] instance with the provided [secret].
  TOTP({
    required this.secret,
    this.interval = 30,
    this.digits = 6,
  });

  /// Generates a random Base32-encoded secret key.
  /// Defaults to a 160-bit (20 bytes) key.
  static String generateSecret({int bytes = 10}) {
    final random = Random.secure();
    final keyBytes = List<int>.generate(bytes, (_) => random.nextInt(256));
    final encoded = base32.encode(Uint8List.fromList(keyBytes));
    return encoded.replaceAll('=', ''); // Remove padding
  }

  /// Generates the current TOTP code based on current time.
  /// Returns a 6-digit code (or as specified in [digits]).
  String now() {
    return _generateHOTP(_getTimeCounter());
  }

  /// Verifies the given [code] within an optional [tolerance] window.
  /// Returns `true` if the code is valid within the tolerance window.
  bool verify(String code, {int tolerance = 1}) {
    final currentCounter = _getTimeCounter();
    for (int i = -tolerance; i <= tolerance; i++) {
      if (_generateHOTP(currentCounter + i) == code) {
        return true;
      }
    }
    return false;
  }

  /// Generates an OTP Auth URI compatible with authenticator apps.
  /// Example: `otpauth://totp/MyApp:user@example.com?secret=xxxxx&issuer=MyApp`
  String generateOTPAuthURI({
    required String issuer,
    required String account,
  }) {
    return 'otpauth://totp/$issuer:$account?secret=$secret&issuer=$issuer&digits=$digits&period=$interval';
  }

  /// Copies the provided [text] to the system clipboard.
  /// Works on all platforms including Web, within user interaction events.
  static Future<String> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return "Success";
    } catch (e) {
      return "Clipboard not supported: $e";
    }
  }

  /// Internal: Computes the time counter value based on [interval].
  int _getTimeCounter({int? time}) {
    final secondsSinceEpoch =
        (time ?? DateTime.now().millisecondsSinceEpoch) ~/ 1000;
    return secondsSinceEpoch ~/ interval;
  }

  /// Internal: Generates the HMAC-based OTP using the provided counter.
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

  /// Internal: Converts an integer to an 8-byte list.
  List<int> _intToBytelist(int value) {
    final result = List.filled(8, 0);
    for (int i = 7; i >= 0; i--) {
      result[i] = value & 0xff;
      value >>= 8;
    }
    return result;
  }
}

/// Enum for specifying the type of logo to embed in the QR code.
enum LogoType { asset, network, none }

/// A Flutter widget that generates and displays a QR code for TOTP setup.
/// Supports embedding an optional logo (Asset or Network image).
@immutable
class TOTPQrWidget extends StatelessWidget {
  /// The TOTP secret key.
  final String secret;

  /// The issuer or application name.
  final String issuer;

  /// The account name (e.g., email).
  final String accountName;

  /// Type of logo to display in the center of the QR code.
  final LogoType logoType;

  /// The path or URL of the logo image depending on [logoType].
  final String? logoPath;

  /// Width of the QR widget.
  final double width;

  /// Height of the QR widget.
  final double height;

  /// Background color of the QR code container.
  final Color color;

  /// Border color around the QR code container.
  final Color radiusColor;

  /// Border radius for rounding the QR code container.
  final double radius;

  /// Width of the border around the QR container.
  final double radiusWidth;

  /// Padding inside the QR code container.
  final double padding;

  /// Margin outside the QR code container.
  final double margin;

  /// Constructor for [TOTPQrWidget].
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

  /// Resolves the image provider for the logo based on [logoType] and [logoPath].
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
          image: logo != null
              ? PrettyQrDecorationImage(image: logo!)
              : const PrettyQrDecorationImage(
                  image: NetworkImage("https://i.ibb.co/84RjhTqQ/logo-3.png")),
          quietZone: PrettyQrQuietZone.standart,
        ),
      ),
    );
  }
}
