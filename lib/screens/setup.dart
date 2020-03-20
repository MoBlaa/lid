import 'package:flutter/material.dart';
import 'package:lid/bloc/setup.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bloc = SetupBloc();

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
                    snapshot.data == SetupState.GeneratingOwner ? LinearProgressIndicator() : Container(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: this._validateName,
                        decoration: InputDecoration(
                          hintText: "Enter a name people will identify you with",
                          labelText: "Name"
                        ),
                        onFieldSubmitted: (String value) => _createIdentity(this._bloc, value),
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
