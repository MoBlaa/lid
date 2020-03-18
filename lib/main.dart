import 'package:flutter/material.dart';
import 'package:lid/infrastructure/repo.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'bloc/startpage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: StartPage(),
    );
  }
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  Future<StartPageBloc> bloc =
      Repository.create().then((repo) => StartPageBloc(repo));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LID - Your Identity"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FutureBuilder<StartPageBloc>(
            future: this.bloc,
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              final bloc = snapshot.data;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () async {
                          await bloc.genNewEcdsa();
                        },
                        child: Text("Generate"),
                      ),
                      StreamBuilder<String>(
                        stream: bloc.identity,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.hasError) {
                            return Text("[Error] ${snapshot.error}");
                          } else if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }

                          final c_width =
                              MediaQuery.of(context).size.width * 0.8;

                          return QrImage(
                            data: snapshot.data,
                            version: QrVersions.auto,
                            size: c_width,
                          );
                        },
                      )
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
