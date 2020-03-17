import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/export.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pointycastle/pointycastle.dart';

class StartPageBloc {
  final _identity = BehaviorSubject<String>();

  Stream<String> get identity => _identity.stream;

  AsymmetricKeyPair<PublicKey, PrivateKey> keyPair;

  StartPageBloc() {
    final rnd = FortunaRandom();
    final random = Random.secure();
    final seed = List<int>.generate(32, (_) => random.nextInt(512));
    rnd.seed(KeyParameter(Uint8List.fromList(seed)));

    final params = RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 12);
    
    final gen = RSAKeyGenerator();
    gen.init(ParametersWithRandom(params, rnd));

    this.keyPair = gen.generateKeyPair();
    final publicKey = this.keyPair.publicKey as RSAPublicKey;

    // Using ASN1 format for PEM files as stated here https://medium.com/flutter-community/asymmetric-key-generation-in-flutter-ad2b912f3309
    final topLevel = ASN1Sequence();
    topLevel.add(ASN1Integer(publicKey.modulus));
    topLevel.add(ASN1Integer(publicKey.exponent));
    final encoded = base64.encode(topLevel.encodedBytes);

    _identity.add(encoded);
  }
}

final bloc = StartPageBloc();