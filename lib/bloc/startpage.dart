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

  Future<void> genNewRsa() async {
    final keyPair = await compute(genRsaKeypair, newRandom());

    // encode
    final publicKey = keyPair.publicKey as RSAPublicKey;
    final seq = ASN1Sequence();
    seq.add(ASN1Integer(publicKey.modulus));
    seq.add(ASN1Integer(publicKey.exponent));
    final encoded = base64.encode(seq.encodedBytes);
    debugPrint("Encoded: $encoded");
    this._identity.add(encoded);
  }

  Future<void> genNewEcdsa() async {
    final keyPair = await compute(genEcKeypair, newRandom());

    // encode
    final publicKey = keyPair.publicKey as ECPublicKey;
    final seq = ASN1Sequence();
    seq.add(ASN1BitString(publicKey.Q.getEncoded()));
    final encoded = base64.encode(seq.encodedBytes);
    debugPrint("Encoded: $encoded");
    this._identity.add(encoded);

    /*
    //Decode the public key:
    final decoded = base64.decode(encoded);
    final parser = ASN1Parser(decoded);
    final decseq = parser.nextObject() as ASN1Sequence;
    final bistring = decseq.elements[0].contentBytes();

    final params = ECCurve_prime256v1();
    final decompressed = params.curve.decodePoint(bistring);
    publicKey = ECPublicKey(decompressed, params);
    // Encode again to check
    seq = ASN1Sequence();
    seq.add(ASN1BitString(publicKey.Q.getEncoded()));
    var encoded2 = base64.encode(seq.encodedBytes);
    assert(encoded == encoded2);
     */
    return;
  }
}

SecureRandom newRandom() {
  final rnd = FortunaRandom();
  final random = Random.secure();
  final seed = List<int>.generate(32, (_) => random.nextInt(256));
  rnd.seed(KeyParameter(Uint8List.fromList(seed)));
  return rnd;
}

AsymmetricKeyPair<PublicKey, PrivateKey> genEcKeypair(SecureRandom rnd) {
  final params = ECKeyGeneratorParameters(ECCurve_prime256v1());

  final gen = ECKeyGenerator();
  gen.init(ParametersWithRandom(params, rnd));

  return gen.generateKeyPair();
}

AsymmetricKeyPair<PublicKey, PrivateKey> genRsaKeypair(SecureRandom rnd) {
  final params = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64);

  final gen = RSAKeyGenerator();
  gen.init(ParametersWithRandom(params, rnd));

  return gen.generateKeyPair();
}

final bloc = StartPageBloc();