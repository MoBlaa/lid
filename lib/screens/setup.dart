import 'package:core/bloc/setup.dart';
import 'package:core/domain/crypto/module.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lidwebplugin/core.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bloc = SetupBloc(kIsWeb ? CorePlugin() : FlutterCryptoModule());

  String _validateName(String value) {
    if (value.isEmpty) {
      return 'Please enter a Name';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Setup"),
        ),
        body: Form(
          key: _formKey,
          child: StreamBuilder<SetupState>(
              stream: this._bloc.setupState,
              builder: (context, snapshot) {
                return Column(
                  children: <Widget>[
                    snapshot.data == SetupState.GeneratingId || snapshot.data == SetupState.GeneratingOwner
                        ? Column(
                          children: <Widget>[
                            LinearProgressIndicator(),
                            StreamBuilder<String>(
                              stream: this._bloc.id,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Container();
                                } else if (!snapshot.hasData) {
                                  return Container();
                                }
                                return Center(
                                    child: Text("Your id: ${snapshot.data}")
                                );
                              },
                            )
                          ],
                        )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              validator: this._validateName,
                              autofocus: true,
                              decoration: InputDecoration(
                                  hintText:
                                      "Enter a name people will identify you with",
                                  labelText: "Name"),
                              onFieldSubmitted: (String value) =>
                                  _createIdentity(this._bloc, value),
                            ),
                          ),
                  ],
                );
              }),
        ));
  }

  void _createIdentity(SetupBloc bloc, String name) async {
    final owner = await bloc.generate(name);
    Navigator.pop(context, owner);
  }
}
