import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/cupertino.dart';
import 'package:pointycastle/export.dart';
import 'package:hive/hive.dart';

SecureRandom newRandom() {
  final rnd = FortunaRandom();
  final random = Random.secure();
  final seed = List<int>.generate(32, (_) => random.nextInt(256));
  rnd.seed(KeyParameter(Uint8List.fromList(seed)));
  return rnd;
}

AsymmetricKeyPair<PublicKey, PrivateKey> genKeyPair(SecureRandom rnd) {
  final params = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 12);

  final gen = RSAKeyGenerator();
  gen.init(ParametersWithRandom(params, rnd));

  return gen.generateKeyPair();
}

RSAPublicKey publicKeyFromASN1(Uint8List encoded) {
  final parser = ASN1Parser(encoded);
  final sequence = parser.nextObject() as ASN1Sequence;
  if (sequence.elements.length != 2) {
    throw "Public Key has to contain modulus and exponent";
  }

  final modulus = sequence.elements[0] as ASN1Integer;
  final exponent = sequence.elements[1] as ASN1Integer;
  return RSAPublicKey(modulus.valueAsBigInteger, exponent.valueAsBigInteger);
}

String publicKeyToASN1(RSAPublicKey publicKey) {
  final sequence = ASN1Sequence();
  sequence.add(ASN1Integer(publicKey.modulus));
  sequence.add(ASN1Integer(publicKey.exponent));
  return base64.encode(sequence.encodedBytes);
}

String privateKeyToASN1(RSAPrivateKey privateKey) {
  final sequence = ASN1Sequence();
  // Add modulus -- n
  sequence.add(ASN1Integer(privateKey.modulus));
  // Add public exponent -- e
  sequence.add(ASN1Integer(privateKey.exponent));
  // Add prime1 -- p
  sequence.add(ASN1Integer(privateKey.p));
  // Add prime2 -- q
  sequence.add(ASN1Integer(privateKey.q));
  return base64.encode(sequence.encodedBytes);
}

RSAPrivateKey privateKeyFromASN1(Uint8List encoded) {
  final parser = ASN1Parser(encoded);
  final sequence = parser.nextObject() as ASN1Sequence;
  if (sequence.elements.length != 4) {
    throw "Public Key ASN.1 has to contain 4 values, got: ${sequence.elements.length}";
  }
  final modulus = sequence.elements[0] as ASN1Integer;
  final exponent = sequence.elements[1] as ASN1Integer;
  final p = sequence.elements[2] as ASN1Integer;
  final q = sequence.elements[3] as ASN1Integer;
  return RSAPrivateKey(modulus.valueAsBigInteger, exponent.valueAsBigInteger,
      p.valueAsBigInteger, q.valueAsBigInteger);
}

class Owner {
  AsymmetricKeyPair<PublicKey, PrivateKey> _keyPair;

  /// https://tools.ietf.org/html/rfc3447#appendix-A
  String get publicKeyASN1 =>
      publicKeyToASN1(this._keyPair.publicKey as RSAPublicKey);

  /// https://tools.ietf.org/html/rfc3447#appendix-A but omits the values not needed by pointycastle.
  String get _privateKeyASN1 =>
      privateKeyToASN1(this._keyPair.privateKey as RSAPrivateKey);

  Owner(this._keyPair);

  Owner.generate() : this(genKeyPair(newRandom()));

  Owner.fromASN1(Uint8List pubEncoded, Uint8List privEncoded)
      : this(AsymmetricKeyPair(
            publicKeyFromASN1(pubEncoded), privateKeyFromASN1(privEncoded)));

  @override
  String toString() => this.publicKeyASN1;
}

class OwnerAdapter extends TypeAdapter<Owner> {
  @override
  int get typeId => 165;

  @override
  Owner read(BinaryReader reader) {
    try {
      final b64Public = reader.readString();
      final b64Private = reader.readString();
      return Owner.fromASN1(base64.decode(b64Public), base64.decode(b64Private));
    } catch (e) {
      debugPrint("Got error while loading owner: '$e'. Returning empty");
      return null;
    }
  }

  @override
  void write(BinaryWriter writer, Owner obj) {
    writer.writeString(obj.publicKeyASN1);
    writer.writeString(obj._privateKeyASN1);
  }
}
