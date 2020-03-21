import 'package:core/bloc/landingpage.dart';
import 'package:core/infrastructure/owner.dart';
import 'package:core/infrastructure/repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lid/screens/owner.dart';
import 'package:lid/screens/setup.dart';
import 'package:provider/provider.dart';

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
    final repo = Provider.of<Repository>(context);
    if (repo == null) {
      return Container();
    }
    final bloc = LandingPageBloc(repo);
    return Scaffold(
      appBar: AppBar(
        title: Text("LID"),
        actions: <Widget>[
          StreamBuilder<Owner>(
              stream: bloc.owner,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return IconButton(
                    icon: Icon(Icons.warning),
                    onPressed: null,
                  );
                } else if (!snapshot.hasData) {
                  return Container();
                }
                return IconButton(
                  icon: Icon(Icons.perm_identity),
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (context) => OwnerScreen(snapshot.data)
                    ));
                    this.setState(() {});
                  }
                );
              })
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder<Owner>(
                stream: bloc.owner,
                builder: (BuildContext context, AsyncSnapshot<Owner> snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData) {
                    return _buildStartSetupButton(bloc);
                  } else {
                    return _buildActionsList(bloc);
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartSetupButton(LandingPageBloc bloc) {
    return RaisedButton(
      onPressed: () async {
        final owner = await Navigator.push(
            context, MaterialPageRoute(builder: (context) => SetupScreen()));
        bloc.setOwner(owner);
      },
      child: Text("Create Identity"),
    );
  }

  Widget _buildActionsList(LandingPageBloc bloc) {
    return Column(
      children: <Widget>[
        OutlineButton(
          onPressed: null,
          child: Text("Add Device"),
        )
      ],
    );
  }
}
