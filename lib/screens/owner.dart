import 'package:core/bloc/owner.dart';
import 'package:core/domain/owner.dart';
import 'package:core/infrastructure/repo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OwnerScreen extends StatefulWidget {
  final Owner _owner;

  OwnerScreen(this._owner) : super();

  @override
  _OwnerScreenState createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<Repository>(context);
    if (repo == null) {
      return CircularProgressIndicator();
    }
    final bloc = OwnerPageBloc(repo);
    final c_width = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      appBar: AppBar(
        title: Text("Identity"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                this.widget._owner.name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    fontSize: 18),
              ),
            ),
            Text(
              this.widget._owner.id
            ),
            Divider(),
            QrImage(
              data: "${this.widget._owner.id}::${this.widget._owner.name}::${this.widget._owner.module.algorithm}::${this.widget._owner.publicKeyASN1}",
              version: QrVersions.auto,
              size: c_width,
            ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlineButton(
                    borderSide: BorderSide(color: Colors.red),
                    textColor: Colors.red,
                    onPressed: () => _deleteIdentity(bloc),
                    child: Text("Delete"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _deleteIdentity(OwnerPageBloc bloc) {
    bloc.deleteOwner();
    Navigator.pop(context);
  }
}
