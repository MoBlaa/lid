import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:lid/utils/rsa.dart';
import 'package:pointycastle/export.dart';
import 'package:hive/hive.dart';

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