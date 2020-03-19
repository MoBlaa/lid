
import 'package:flutter/foundation.dart';
import 'package:lid/infrastructure/owner.dart';
import 'package:rxdart/rxdart.dart';

enum SetupState {
  WaitingForInput, GeneratingOwner, Finished
}

class SetupBloc {
  final _step = BehaviorSubject<SetupState>.seeded(SetupState.WaitingForInput);

  Stream<SetupState> get setupState => _step.stream;

  Future<Owner> generate(String name) async {
    _step.add(SetupState.GeneratingOwner);
    final owner = await compute(genOwner, name);
    _step.add(SetupState.Finished);
    return owner;
  }
}

Future<Owner> genOwner(String name) async => Owner.generate(name);