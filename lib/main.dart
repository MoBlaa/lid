import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lid/bloc/landingpage.dart';
import 'package:lid/infrastructure/owner.dart';
import 'package:lid/infrastructure/repo.dart';
import 'package:lid/screens/setup.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureProvider(
      create: (_) => Repository.create(),
      lazy: true,
      child: MaterialApp(
        title: 'LID',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: LandingPage(),
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LID"),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Consumer<Repository>(
                builder: (BuildContext context, Repository value, _) {
                  if (value == null) {
                    return CircularProgressIndicator();
                  }
                  final bloc = LandingPageBloc(value);
                  return StreamBuilder<Owner>(
                    stream: bloc.owner,
                    builder: (BuildContext context, AsyncSnapshot<Owner> snapshot) {
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData) {
                        return _buildStartSetupButton(bloc);
                      } else {
                        return _buildOwner(context, snapshot.data);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOwner(BuildContext context, Owner owner) {
    final c_width = MediaQuery.of(context).size.width * 0.8;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Name: ${owner.name}"),
        QrImage(
          data: owner.publicKeyASN1,
          version: QrVersions.auto,
          size: c_width,
        )
      ],
    );
  }

  Widget _buildStartSetupButton(LandingPageBloc bloc) {
    return RaisedButton(
      onPressed: () async {
        final owner = await Navigator.push(context, MaterialPageRoute(
          builder: (context) => SetupScreen()
        ));
        bloc.setOwner(owner);
      },
      child: Text("Create Identity"),
    );
  }
}
