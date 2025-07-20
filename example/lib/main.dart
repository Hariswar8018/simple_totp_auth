import 'package:flutter/material.dart';
import 'package:simple_totp_auth/simple_totp_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOTP Demo',
      debugShowCheckedModeBanner: false,
      home: TOTPExamplePage(),
    );
  }
}

class TOTPExamplePage extends StatefulWidget {
  @override
  State<TOTPExamplePage> createState() => _TOTPExamplePageState();
}

class _TOTPExamplePageState extends State<TOTPExamplePage> {
  TOTP _totp = TOTP(secret: 'JBSWY3DPEHPK3PXP'); //Demo will be uypdated
  String _code = '';
  String _inputCode = '';
  String _result = '';

  void _generateCode() {
    generate();
    setState(() {
      _code = _totp.now();
    });
  }

  void _verifyCode() {
    final isValid = _totp.verify(_inputCode);
    setState(() {
      _result = isValid ? '✅ Valid Code' : '❌ Invalid Code';
    });
  }

  void generate() {
    final secret = TOTP.generateSecret();
    print('Generated secret: $secret');
    _totp = TOTP(secret: secret);
  }

  @override
  void initState() {
    super.initState();
    _generateCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'TOTP Example',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff7F00FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TOTPQrWidget(
              secret: _totp.secret,
              issuer: "My Mentos",
              accountName: "ayush@gmail.com",
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text('Generated TOTP Secret: ${_totp.secret}',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            TextField(
              decoration:
                  const InputDecoration(labelText: 'Enter code to verify'),
              onChanged: (val) => _inputCode = val,
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _verifyCode,
              child: button("Verify OTP", Color(0xff7F00FF)),
            ),
            const SizedBox(height: 10),
            Text(_result,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const Spacer(),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: _generateCode,
                    child: button("Generate New", Colors.red),
                  ),
                  InkWell(
                    onTap: () async {
                      String code = _totp.secret;
                      String s = await TOTP.copyToClipboard(code);
                      ScaffoldMessenger(
                        //Error here
                        child: SnackBar(
                          content: Text(s),
                        ),
                      );
                    },
                    child: button("ClipBoard Copy", Colors.pinkAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget button(String str, Color color) {
    return Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
          child: Text(
        str,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black),
      )),
    );
  }
}
