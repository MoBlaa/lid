import 'package:flutter/material.dart';
import 'package:lid/infrastructure/owner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OwnerScreen extends StatelessWidget {
  final Owner _owner;

  OwnerScreen(this._owner) : super();

  @override
  Widget build(BuildContext context) {
    final c_width = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      appBar: AppBar(
        title: Text("Identity"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                this._owner.name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28
                ),
              ),
              QrImage(
                data: this._owner.publicKeyASN1,
                version: QrVersions.auto,
                size: c_width,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
