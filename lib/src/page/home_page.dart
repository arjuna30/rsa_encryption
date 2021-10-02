import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:public_key_encryption/src/model/encryption.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const _BodyHomePage();
  }
}

class _BodyHomePage extends StatefulWidget {
  const _BodyHomePage({Key? key}) : super(key: key);

  @override
  _BodyHomePageState createState() => _BodyHomePageState();
}

class _BodyHomePageState extends State<_BodyHomePage>
    with SingleTickerProviderStateMixin {
  final _plainTextController = TextEditingController();
  final _privateKeyController = TextEditingController();
  final _encryptedController = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSA Encryption'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.black,
              controller: _tabController,
              tabs: const [
                Tab(text: 'Encrypt'),
                Tab(text: 'Decrypt'),
              ],
            ),
            Expanded(
                child: TabBarView(
              controller: _tabController,
              children: [_tab1(context), _tab2(context)],
            ))
          ],
        ),
      ),
    );
  }

  Widget _tab1(BuildContext context) {
    final provider = Provider.of<Encryption>(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            Form(
              child: TextFormField(
                controller: _plainTextController,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Color(0xFFD5D5DC)),
                  hintStyle: TextStyle(color: Color(0xFFD5D5DC), fontSize: 14),
                  filled: true,
                  fillColor: Color(0xFFF6F7F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            CustomMainButton(
              text: 'Generate Public & Private Key',
              color: Colors.blueGrey,
              onPressed: () {
                final random = Provider.of<Encryption>(context, listen: false)
                    .secureRandom();
                Provider.of<Encryption>(context, listen: false)
                    .generateRsaKeyPair(random);
              },
            ),
            const SizedBox(height: 25),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Public Key',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: SelectableText(provider.publicKey),
                        ),
                      ),
                      if (provider.publicKey.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            child: Text('Copy'),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: provider.publicKey));
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Private Key',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: SelectableText(provider.privateKey),
                        ),
                      ),
                      if (provider.privateKey.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            child: Text('Copy'),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: provider.privateKey));
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            CustomMainButton(
              text: 'Encrypt',
              color: Colors.blueGrey,
              onPressed: (provider.publicKey.isNotEmpty)
                  ? () {
                      Provider.of<Encryption>(context, listen: false)
                          .rsaEncrypt(
                              Provider.of<Encryption>(context, listen: false)
                                  .rsaKeyPair
                                  .publicKey,
                              Uint8List.fromList(
                                  utf8.encode(_plainTextController.text)));
                    }
                  : null,
            ),
            const SizedBox(height: 25),
            SelectableText(provider.encrypted),
            if (provider.encrypted.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text('Copy'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: provider.encrypted));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tab2(BuildContext context) {
    final provider = Provider.of<Encryption>(context);
    final _formKey = GlobalKey<FormState>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _privateKeyController,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null) {
                        'Please input private key';
                      }
                      if (value != null && value.isEmpty) {
                        'Please input private key';
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Input Private Key',
                      filled: true,
                      fillColor: Color(0xFFF6F7F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: _encryptedController,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null) {
                        'Please input encrypted text';
                      }
                      if (value != null && value.isEmpty) {
                        'Please input encrypted text';
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Input Encrypted Text',
                      filled: true,
                      fillColor: Color(0xFFF6F7F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            CustomMainButton(
              text: 'Decrypt',
              color: Colors.blueGrey,
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  final rsaPrivateKey = Provider.of<Encryption>(context,
                          listen: false)
                      .generatePrivateKeyFromPem(_privateKeyController.text);
                  Provider.of<Encryption>(context, listen: false).rsaDecrypt(
                      rsaPrivateKey, base64Decode(_encryptedController.text));
                }
              },
            ),
            const SizedBox(height: 25),
            const Text(
              'Plain Text',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: SelectableText(provider.decrypted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomMainButton extends StatelessWidget {
  final Color color;
  final String text;
  final void Function()? onPressed;

  const CustomMainButton({
    Key? key,
    required this.color,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all<double>(0),
        backgroundColor: MaterialStateProperty.all<Color>(
            onPressed != null ? color : Colors.black12),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
      child: Container(
          height: 58,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ],
          )),
      onPressed: onPressed,
    );
  }
}
