import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

Future<List<POI>> getPOIs() async {
  final response =
      await http.get(Uri.parse('https://testapiwithjs.herokuapp.com/api'));

  List<POI> pois = [
    new POI(xKoordinate: 0, yKoordinate: 0, title: 'error', id: '-1', v: 0.0)
  ];

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var list = json.decode(response.body) as List;
    try {
      pois = list.map((i) => POI.fromJson(i)).toList();
    } on Exception catch (e) {
      print('error caught: $e');
      return pois;
    }
    print(pois);
    return pois;
    //var poi1 = [new POI(xKoordinate: 5, yKoordinate: 5,title: "test", id: 5, v: 5)];
    //return poi1;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load POIs');
    //var poi1 = [new POI(xKoordinate: 5, yKoordinate: 5,title: "test", id: 5, v: 5)];
    //return poi1;
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

class POI {
  final double xKoordinate;
  final double yKoordinate;
  final String title;
  final String id;
  final double v;

  POI({
    required this.xKoordinate,
    required this.yKoordinate,
    required this.title,
    required this.id,
    required this.v,
  });

  factory POI.fromJson(Map<String, dynamic> json) {
    print(json);
    try {
      return POI(
        xKoordinate: json['xKoordinate'].toDouble() as double,
        yKoordinate: json['yKoordinate'].toDouble() as double,
        title: json['title'] as String,
        id: json['_id'] as String,
        v: json['__v'].toDouble() as double,
      );
    } catch (e) {
      print('error caught: $e');
      return POI(
          xKoordinate: 0, yKoordinate: 0, title: 'error', id: '-1', v: 0.0);
    }
  }
}

class _MyMapState extends State<MyMap> {
  bool _isFavorited = true;
  int _favoriteCount = 41;

  final Map<String, Marker> _markers = {};

  Completer<GoogleMapController> _controller = Completer();

  Future<void> _onMapCreated(GoogleMapController controller) async {
    String _mapStyle = "";
    loadPins();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    controller.setMapStyle(_mapStyle);
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

  Future<void> loadPins() async {
    print("loading pins");
    List<POI> pois = [
      new POI(xKoordinate: 0, yKoordinate: 0, title: 'error', id: '-1', v: 0.0)
    ];
    try {
      pois = await getPOIs();
    } on Exception catch (e) {
      print('error caught: $e');
    }

    setState(() {
      _markers.clear();
      for (final poi in pois) {
        //GET LOCATIONS
        print(poi.title +
            ', pos: ' +
            poi.xKoordinate.toString() +
            ' ' +
            poi.yKoordinate.toString());
        final marker = Marker(
          markerId: MarkerId("${poi.title}"),
          position: LatLng(poi.xKoordinate, poi.yKoordinate),
          infoWindow: InfoWindow(title: "${poi.title}"),
        );
        _markers[poi.title] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition:
            CameraPosition(target: LatLng(47.9977, 7.8399), zoom: 14.5),
        zoomControlsEnabled: false,

        markers: _markers.values.toSet(),

        // _markers,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loadPins,
        label: Text('        '),
        icon: Icon(Icons.refresh),
      ),
    );
  }
}
