@JS()
library worker;

import 'package:core/infrastructure/owner.dart';
import 'package:core/utils/random.dart';
import 'package:core/utils/rsa.dart';
import 'package:core/utils/worker.dart';
import 'package:js/js.dart';

@anonymous
@JS()
abstract class MessageEvent {
  external dynamic get data;
}

@JS('postMessage')
external void PostMessage(obj);

@JS('onmessage')
external void set onMessage(f);

void main() {
  print('Worker created!');

  onMessage = allowInterop((event) {
    final e = event as MessageEvent;
    final data = WorkerEvent.resolve(e.data as String);

    // TODO: Do this in WASM to speed things up
    switch (data.type) {
      case GenIdType:
        final event = data as GenIdEvent;
        print("Generating Id with length: ${event.length}");
        PostMessage(generateRandomString(event.length));
        break;
      case GenOwnerType:
        final event = data as GenOwnerEvent;
        print("Generating Owner with id: ${event.id}, name: ${event.name}");
        final random = newRandom();
        final keyPair = genKeyPair(random);

        PostMessage(Owner(event.id, event.name, keyPair).toString());
        break;
      default:
        throw 'Unsupported EventType: ${data.type}';
    }
  });
}