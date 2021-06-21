import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'google_map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: SecondRoute(),
    );
  }
}

Future<LocationData> getLocation() async {
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      throw Exception('Location service disabled');
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      throw Exception('Location permission not granted');
    }
  }

  return await location.getLocation();
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Location location = new Location();

  //MyMap map = new MyMap();
  //String inputValue = map.getPOIS();
  String inputValue = 'hallo';
  String lat = "";
  String long = "";

  bool ableToSee = false;

  Future<LocationData> getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        throw Exception('Location service disabled');
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permission not granted');
      }
    }

    return await location.getLocation();
  }

  Future<http.Response> createLocation(
      String title, String lat, String long) async {
    print("message sent");
    Future<LocationData> result = getLocation();
    LocationData locdat = await result;

    return http.post(
      Uri.parse('https://testapiwithjs.herokuapp.com/api'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        "xKoordinate": locdat.latitude.toString(),
        "yKoordinate": locdat.longitude.toString(),
        /*
        "xKoordinate": lat,
        "yKoordinate": long,

        */
      }),
    );
  }

  void giveVisibleState() {
    setState(() {
      ableToSee = !ableToSee;
    });

    inputValue = myController.text;
    lat = latController.text;
    long = longController.text;

    createLocation(inputValue, lat, long);
  }

  final myController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      body: Container(
        /* decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  "https://images.pexels.com/photos/1005644/pexels-photo-1005644.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940")),
        ), */

        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Stack(
          children: <Widget>[
            MyMap(),
            Text(inputValue),
            Visibility(
                visible: ableToSee,
                child: AlertDialog(
                  title: const Text("Neue Kunst in Freiburg: "),
                  titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: [
                        Text("Hier kannst du ein neues Kunstwerk speichern: "),
                        TextFormField(
                          decoration: const InputDecoration(
                              hintText: "Wie heißt deine Kunst Entdeckung? "),
                          controller: myController,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: giveVisibleState,
                            child: const Text("submit"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [],
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: giveVisibleState,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),
            image: DecorationImage(
              image: AssetImage("assets/titlepage_with_title.png"),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.arrow_forward_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyHomePage(
                          title: 'TrackArt',
                        )),
              );
            }));
  }
}
