import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/cupertino.dart';
import 'package:pointycastle/export.dart';
import 'package:hive/hive.dart';

class Owner {
  static ECDomainParameters get params => ECCurve_prime256v1();

  AsymmetricKeyPair<PublicKey, PrivateKey> _keyPair;

  String get publicKeyEncoded {
    final publicKey = this._keyPair.publicKey as ECPublicKey;
    final seq = ASN1Sequence();
    seq.add(ASN1BitString(publicKey.Q.getEncoded()));
    return base64.encode(seq.encodedBytes);
  }

  Owner(this._keyPair);

  @override
  String toString() => this.publicKeyEncoded;
}

class OwnerAdapter extends TypeAdapter<Owner> {
  @override
  int get typeId => 165;

  @override
  Owner read(BinaryReader reader) {
    final params = Owner.params;

    final b64 = reader.readString();
    final parser = ASN1Parser(base64.decode(b64));
    final seq = parser.nextObject() as ASN1Sequence;
    final pubEncoded = seq.elements[0] as ASN1BitString;
    final privBigint = seq.elements[1] as ASN1Integer;

    final pub = ECPublicKey(params.curve.decodePoint(pubEncoded.contentBytes()), params);
    final priv = ECPrivateKey(privBigint.valueAsBigInteger, params);
    return Owner(AsymmetricKeyPair(pub, priv));
  }

  @override
  void write(BinaryWriter writer, Owner obj) {
    final publicKey = obj._keyPair.publicKey as ECPublicKey;
    final privateKey = obj._keyPair.privateKey as ECPrivateKey;

    final seq = ASN1Sequence();
    seq.add(ASN1BitString(publicKey.Q.getEncoded()));
    seq.add(ASN1Integer(privateKey.d));

    final b64 = base64.encode(seq.encodedBytes);
    debugPrint("Storing: $b64");

    writer.writeString(b64);
  }

}