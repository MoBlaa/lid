import 'package:flutter/foundation.dart';
import 'package:lid/infrastructure/owner.dart';
import 'package:lid/infrastructure/repo.dart';
import 'package:rxdart/rxdart.dart';

class StartPageBloc {
  final _identity = BehaviorSubject<String>();
  final Repository repo;
  Owner _owner;

  Stream<String> get identity => _identity.stream;

  StartPageBloc(this.repo): _owner = repo.loadOwner() {
    this._identity.add(this._owner?.publicKeyASN1);
  }

  void setOwner(Owner owner) {
    this._owner = owner;
    this.repo.saveOwner(owner);
    this._identity.add(this._owner?.publicKeyASN1);
  }

  Future<void> genNew() async {
    final owner = await compute(genKeyPair, null);
    this.setOwner(owner);
    return;
  }
}

Future<Owner> genKeyPair(Object _) async => await Owner.generate();