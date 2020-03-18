import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/foundation.dart';
import 'package:lid/infrastructure/owner.dart';
import 'package:lid/infrastructure/repo.dart';
import 'package:pointycastle/export.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pointycastle/pointycastle.dart';

class StartPageBloc {
  final _identity = BehaviorSubject<String>();
  final Repository repo;
  Owner _owner;

  Stream<String> get identity => _identity.stream;

  StartPageBloc(this.repo): _owner = repo.loadOwner() {
    this._identity.add(this._owner?.publicKeyEncoded);
  }

  void setOwner(Owner owner) {
    this._owner = owner;
    this.repo.saveOwner(owner);
    this._identity.add(this._owner.publicKeyEncoded);
  }

  Future<void> genNewEcdsa() async {
    final keyPair = await compute(genEcKeypair, newRandom());

    this.setOwner(Owner(keyPair));

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