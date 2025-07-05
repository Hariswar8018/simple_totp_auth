# 🔐 simple_totp_auth

![simple_totp_auth](https://i.ibb.co/7N0Yr8wb/Add-a-subheading.png)

A lightweight Flutter package for **generating**, **verifying**, and **sharing** Time-based One-Time Passwords (TOTP) using QR codes — perfect for adding secure 2FA (Two-Factor Authentication) to any app.

> ✅ Compatible with Google Authenticator, Microsoft Authenticator, Authy, and more!

---
## Demo Screenshots
![Demo Screenshot](https://i.ibb.co/HTLrsGnS/Screenshot-272.png)

![Demo Screenshot](https://i.ibb.co/qLZQ199P/Screenshot-271.png)

---

## ✨ Features

- 🔑 Generate secure Base32 TOTP secrets
- 🕒 Create & verify 6-digit TOTP codes (RFC 6238)
- 📱 Generate otpauth:// URIs
- 📷 Display QR codes for Authenticator setup
- 📋 Copy secrets to clipboard (cross-platform support)
- 🧩 Flutter Widget for QR with custom size, color, and logo

---

## 🚀 Installation

```yaml
dependencies:
  simple_totp_auth: ^0.0.1
```
---
# 🧪 Usage
## 🔐 Generate a Secure Secret Key
```
final secret = TOTP.generateSecret();
```

## 🧮 Generate a TOTP Code (Valid for 30 seconds)
```
final totp = TOTP(secret: secret);
final code = totp.now();
print("Code: $code");
```

## ✅ Verify a Code
```
final totp = TOTP(secret: secret);
final code = totp.now();
print("Code: $code");
```
## 📡 Generate QR-Compatible URI
```
final uri = totp.generateOTPAuthURI(
  issuer: "MyApp",
  account: "user@example.com",
);
print(uri);
// otpauth://totp/MyApp:user@example.com?secret=xxxxx&issuer=MyApp

```
## 📷 Display the QR Code in Your App
```
TOTPQrWidget(
  secret: secret,
  issuer: 'MyApp',
  accountName: 'user@example.com',
  logo: const AssetImage('images/logo.png'),
  width: 200,
  height: 200,
  color: Colors.white,
  radius: 16,
  radiuscolor: Colors.blue,
  radiuswidth: 2,
  padding: 8,
  margin: 8,
)

```
## 📋 Copy Secret to Clipboard (with feedback)
```
final result = await TOTPUtils.copyToClipboard(secret);
print(result); // "Success" or error message

```

## 📦 **Platform Support**
>
> | Platform  | Support |
> |-----------|---------|
> | ✅ Android | Yes     |
> | ✅ iOS     | Yes     |
> | ✅ Web     | Yes     |
> | ✅ Windows | Yes     |
> | ✅ macOS   | Yes     |
> | ✅ Linux   | Yes     |
>
> Works across all 6 major platforms with no native plugins!

---

## ☕ Support the Developer

If you found this package helpful, consider buying me a coffee:

[![Buy Me a Coffee](https://img.shields.io/badge/☕-Buy%20Me%20a%20Coffee-yellow?logo=buy-me-a-coffee&style=for-the-badge)](https://buymeacoffee.com/hariswarsax)

---

Thanks for using `simple_totp_auth` ❤️

