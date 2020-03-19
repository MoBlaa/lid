import 'package:flutter/material.dart';
import 'package:lid/bloc/setup.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bloc = SetupBloc();
  String _name = "";

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      validator: this._validateName,
                      onChanged: (name) =>
                          this.setState(() => this._name = name),
                    ),
                    snapshot.data == SetupState.WaitingForInput
                        ? _buildGenButton(context, this._bloc)
                        : _buildGeneratingIndicator()
                  ],
                );
              }),
        ));
  }

  Widget _buildGenButton(BuildContext context, SetupBloc bloc) {
    return RaisedButton(
      onPressed: () async {
        if (_formKey.currentState.validate()) {
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text('Generating ...')));
          final owner = await bloc.generate(this._name);
          Navigator.pop(context, owner);
        }
      },
      child: Text('Generate Identity'),
    );
  }

  Widget _buildGeneratingIndicator() {
    return CircularProgressIndicator();
  }
}
