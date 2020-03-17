import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pointycastle/pointycastle.dart';

class StartPageBloc {
  final _identity = BehaviorSubject<String>();

  Stream<String> get identity => _identity.stream;

  AsymmetricKeyPair<PublicKey, PrivateKey> keyPair;
  SecureRandom _rnd;

  StartPageBloc() {
    final rnd = FortunaRandom();
    final random = Random.secure();
    final seed = List<int>.generate(32, (_) => random.nextInt(512));
    rnd.seed(KeyParameter(Uint8List.fromList(seed)));
    this._rnd = rnd;
  }

  Future<void> genNew() async {
    this._identity.add(null);
    this.keyPair = await compute(genRsaKeypair, this._rnd);

    // encode
    final publicKey = this.keyPair.publicKey as RSAPublicKey;
    final seq = ASN1Sequence();
    seq.add(ASN1Integer(publicKey.modulus));
    seq.add(ASN1Integer(publicKey.exponent));
    final encoded = base64.encode(seq.encodedBytes);
    this._identity.add(encoded);
    return;
  }
}

AsymmetricKeyPair<PublicKey, PrivateKey> genRsaKeypair(SecureRandom rnd) {
  final params = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 12);

  final gen = RSAKeyGenerator();
  gen.init(ParametersWithRandom(params, rnd));

  return gen.generateKeyPair();
}

final bloc = StartPageBloc();