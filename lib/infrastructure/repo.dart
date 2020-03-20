import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'owner.dart';

class Repository {
  final Box<Owner> _ownerBox;
  
  Repository._(this._ownerBox);

  static Future<Repository> create() async {
    await Hive.initFlutter();
    Hive.registerAdapter(OwnerAdapter());
    final ownerBox = await Hive.openBox<Owner>("owner");
    return Repository._(ownerBox);
  }

  void saveOwner(Owner owner) async {
    await this._ownerBox.put("owner", owner);
  }

  Owner loadOwner() => this._ownerBox.get("owner");

  void deleteOwner() async => await this._ownerBox.delete("owner");
}