import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_app/app.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    listenCurrentLocation();
  }

  late GoogleMapController googleMapController;
  Position? _position;
  LatLng? _latLng;
  final Set<Marker> _marker = {};

  Future<void> getCurrentLocation() async {
    final isGranted = await isLocationPermissionGranted();
    if (isGranted) {
      final isServicesEnable = await checkGPSServicesEnable();
      if (isServicesEnable) {
        Position currentLocation = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
              timeLimit: Duration(seconds: 20),
              accuracy: LocationAccuracy.bestForNavigation),
        );
        _position = currentLocation;
        _marker.add(
          Marker(
            markerId: MarkerId("current-location"),
            position: LatLng(_position!.latitude, _position!.longitude),
            infoWindow: InfoWindow(title: "Current Location"),
          ),
        );
        setState(() {});
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestLocationPermission();
      if (result) {
        getCurrentLocation();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

  Future<void> listenCurrentLocation() async {
    final isGranted = await isLocationPermissionGranted();
    if (isGranted) {
      final isServicesEnable = await checkGPSServicesEnable();
      if (isServicesEnable) {
        Geolocator.getPositionStream().listen((pos) {
          print(pos);
        });
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestLocationPermission();
      if (result) {
        getCurrentLocation();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkGPSServicesEnable() async {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Real-Time "),
        backgroundColor: Colors.green,
      ),
      body: GoogleMap(
        onTap: (LatLng latLng) {
          _marker.add(
            Marker(
              draggable: true,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              markerId: MarkerId("tap-marker"),
              position: latLng,
              infoWindow: InfoWindow(
                title: "${latLng.latitude},${latLng.longitude}",
              ),
            ),
          );
          _latLng = latLng;
          setState(() {});
        },
        trafficEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        initialCameraPosition: CameraPosition(
          zoom: 16,
          target: LatLng(
            23.737886925830523,
            90.41440192809809,
          ),
        ),
        markers: _marker,
        polylines: <Polyline>{
          if (_position != null && _latLng != null)
            Polyline(
              color: Colors.blue,
              width: 3,
              jointType: JointType.mitered,
              polylineId: const PolylineId('initial-polyline'),
              points: <LatLng>[
                LatLng(_position!.latitude, _position!.longitude),
                LatLng(_latLng!.latitude, _latLng!.longitude),
              ],
            ),
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                zoom: 17,
                target: LatLng(
                  23.737886925830523,
                  90.41440192809809,
                ),
              ),
            ),
          );
        },
        child: Icon(Icons.my_location),
      ),
    );
  }
}
