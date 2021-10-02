import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/export.dart';
import 'package:public_key_encryption/src/repository/encryption_repository.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

class Encryption with ChangeNotifier, DiagnosticableTreeMixin {
  final encryptionRepository = EncryptionRepository();
  String _publicKey = '';
  String _privateKey = '';
  String _encrypted = '';
  String _decrypted = '';
  late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> rsaKeyPair;

  String get publicKey => _publicKey;
  String get privateKey => _privateKey;
  String get encrypted => _encrypted;
  String get decrypted => _decrypted;

  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRsaKeyPair(
      SecureRandom secureRandom,
      {int? bitLength}) {
    rsaKeyPair = encryptionRepository.generateRsaKeyPair(secureRandom);
    final rawPublicKey =
        RsaKeyHelper().encodePublicKeyToPemPKCS1(rsaKeyPair.publicKey);
    _publicKey = rawPublicKey.substring(32, (rawPublicKey.length - 30));
    final rawPrivateKey =
        RsaKeyHelper().encodePrivateKeyToPemPKCS1(rsaKeyPair.privateKey);
    _privateKey = rawPrivateKey.substring(33, (rawPrivateKey.length - 30));
    notifyListeners();
    return rsaKeyPair;
  }

  SecureRandom secureRandom() => encryptionRepository.secureRandom();

  void rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
    final generated = encryptionRepository.rsaEncrypt(myPublic, dataToEncrypt);
    _encrypted = base64Encode(generated);
    notifyListeners();
  }

  void rsaDecrypt(RSAPrivateKey myPrivate, Uint8List cipherText) {
    final decrypt = encryptionRepository.rsaDecrypt(myPrivate, cipherText);
    _decrypted = utf8.decode(decrypt);
    notifyListeners();
  }

  RSAPrivateKey generatePrivateKeyFromPem(String pemString) =>
      encryptionRepository.generatePrivateKeyFromPem(pemString);
}
