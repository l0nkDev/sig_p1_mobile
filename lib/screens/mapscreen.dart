import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sig_p1_mobile/components/bestpathlistmenu.dart';
import 'package:sig_p1_mobile/components/bestpathmenu.dart';
import 'package:sig_p1_mobile/components/linesmenu.dart';
import 'package:sig_p1_mobile/components/radiusmenu.dart';
import 'package:sig_p1_mobile/models/point.dart';
import 'package:sig_p1_mobile/models/renderedroute.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late LatLng _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Circle> _circles = {};

  List<RenderedRoute> _lineRoutes = [];
  late Color _lineColor;
  bool _lineRouteIsSwapped = false;

  bool _pickingPosition = false;
  late LatLng _pickedPosition;
  bool _pickingRadius = false;
  double _pickedRadius = 50;

  bool _pickingOrigin = false;
  LatLng? _pickedOrigin;
  bool _pickingDestination = false;
  LatLng? _pickedDestination;
  late PersistentBottomSheetController _bottomSheetController;

  static const CameraPosition _kStartingPosition = CameraPosition(
    bearing: 0,
    target: LatLng(-17.783607, -63.180669),
    tilt: 0,
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void setMarkers(Set<Marker> markers) {
    setState(() {
      _markers = markers;
    });
  }

  Future<Set<Marker>> directionsFromRoute(RenderedRoute route) async {
    List<LatLng> points = [];
    Set<Marker> markers = {};
    AssetMapBitmap directionIcon = await BitmapDescriptor.asset(
      ImageConfiguration(),
      'assets/direction.png',
      width: 15,
      height: 15,
    );
    AssetMapBitmap originIcon = await BitmapDescriptor.asset(
      ImageConfiguration(),
      'assets/alt_marker.png',
      width: 15,
      height: 15,
    );
    AssetMapBitmap destinationIcon = await BitmapDescriptor.asset(
      ImageConfiguration(),
      'assets/marker.png',
      width: 15,
      height: 15,
    );
    route.path.forEach((p) => points.add(LatLng(p.xCoord, p.yCoord)));
    for (int i = 0; i < points.length; i++) {
      LatLng p = points[i];
      if (i == 0) {
        markers.add(
          Marker(
            markerId: MarkerId("${route.id}_$i"),
            position: p,
            icon: originIcon,
            anchor: Offset(0.5, 0.5),
          ),
        );
      } else if (i == points.length - 1) {
        markers.add(
          Marker(
            markerId: MarkerId("${route.id}_$i"),
            position: p,
            icon: destinationIcon,
            anchor: Offset(0.5, 0.5),
          ),
        );
      } else if (i % 5 == 0 && i != points.length - 1) {
        LatLng np = points[i + 1];
        double rot = Geolocator.bearingBetween(
          np.latitude,
          np.longitude,
          p.latitude,
          p.longitude,
        );
        print(rot);
        markers.add(
          Marker(
            markerId: MarkerId("${route.id}_$i"),
            position: p,
            icon: directionIcon,
            anchor: Offset(0.5, 0.5),
            rotation: rot + 90,
          ),
        );
      }
    }
    return markers;
  }

  Future<Set<Marker>> directionsFromRouteDynamic(dynamic route, bool isFirst, bool isLast) async {
    List<LatLng> points = [];
    Set<Marker> markers = {};
    AssetMapBitmap directionIcon = await BitmapDescriptor.asset(
      ImageConfiguration(),
      'assets/direction.png',
      width: 15,
      height: 15,
    );
    AssetMapBitmap originIcon = await BitmapDescriptor.asset(
      ImageConfiguration(),
      'assets/alt_marker.png',
      width: 15,
      height: 15,
    );
    AssetMapBitmap destinationIcon = await BitmapDescriptor.asset(
      ImageConfiguration(),
      'assets/marker.png',
      width: 15,
      height: 15,
    );
    AssetMapBitmap transferIcon = await BitmapDescriptor.asset(
      ImageConfiguration(),
      'assets/transfer.png',
      width: 30,
      height: 30,
    );
    route["path"].forEach(
      (p) => points.add(LatLng(p["x_coord"], p["y_coord"])),
    );
    for (int i = 0; i < points.length; i++) {
            LatLng p = points[i];
      if (i == 0) {
        markers.add(
          Marker(
            markerId: MarkerId("${route["route"]["id"]}_$i"),
            position: p,
            icon: isFirst ? originIcon : transferIcon,
            anchor: Offset(0.5, 0.5),
          ),
        );
      } else if (i == points.length - 1) {
        markers.add(
          Marker(
            markerId: MarkerId("${route["route"]["id"]}_$i"),
            position: p,
            icon: destinationIcon,
            anchor: Offset(0.5, 0.5),
          ),
        );
      } else if (i % 3 == 0 && i != points.length - 1) {
        LatLng np = points[i + 1];
        double rot = Geolocator.bearingBetween(
          np.latitude,
          np.longitude,
          p.latitude,
          p.longitude,
        );
        markers.add(
          Marker(
            markerId: MarkerId("${route["route"]["id"]}_${i}_mk"),
            position: p,
            icon: directionIcon,
            anchor: Offset(0.5, 0.5),
            rotation: rot + 90,
          ),
        );
      }
    }
    return markers;
  }

  Polyline fromRoute(RenderedRoute route, Color color) {
    List<LatLng> points = [];
    route.path.forEach((p) => points.add(LatLng(p.xCoord, p.yCoord)));
    return Polyline(
      polylineId: PolylineId('${route.id}'),
      points: points,
      color: color,
      width: 3,
    );
  }

  void setLineRoute(List<RenderedRoute> routes, Color color) async {
    RenderedRoute route = routes.firstOrNull!;
    Set<Marker> markers = await directionsFromRoute(route);
    setState(() {
      _lineRoutes = routes;
      _lineColor = color;
      _polylines = {fromRoute(route, _lineColor)};
      _markers = markers;
      _lineRouteIsSwapped = false;
    });
  }

  void swapLineRoute() async {
    if (_lineRoutes.isEmpty) return;
    RenderedRoute route = _lineRoutes[_lineRouteIsSwapped ? 1 : 0];
    Set<Marker> markers = await directionsFromRoute(route);
    setState(() {
      _polylines = {fromRoute(route, _lineColor)};
      _lineRouteIsSwapped = !_lineRouteIsSwapped;
      _markers = markers;
    });
  }

  void onCloseLinesButton() async {
    setState(() {
      _polylines = {};
      _lineRoutes = [];
      _lineRouteIsSwapped = false;
    });
    if (_pickingPosition) {
      _pickingPosition = false;
      _pickedPosition = await getCenterCoordinates();
      BitmapDescriptor marker = await BitmapDescriptor.asset(
        ImageConfiguration(),
        'assets/marker.png',
        width: 15,
        height: 15,
      );
      setState(() {
        _pickedPosition = _pickedPosition;
        _pickedRadius = 50;
        _markers = {
          Marker(
            markerId: MarkerId('r'),
            position: _pickedPosition,
            icon: marker,
            anchor: Offset(0.5, 0.5),
          ),
        };
        _circles = {
          Circle(
            circleId: CircleId('c'),
            center: _pickedPosition,
            radius: _pickedRadius,
            strokeWidth: 2,
            strokeColor: Colors.white,
            fillColor: Color.fromARGB(128, 255, 153, 0),
          ),
        };
      });
      showModalBottomSheet(
        barrierColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (BuildContext context) {
          return Radiusmenu(setRadius: setRadius);
        },
      );
    } else {
      await _getCurrentLocation();
      _goTo(_currentPosition);
      _pickingPosition = true;
    }
  }

  void setRadius(double radius) {
    setState(() {
      _pickedRadius = radius;
      _circles = {
        Circle(
          circleId: CircleId('c'),
          center: _pickedPosition,
          radius: _pickedRadius,
          strokeWidth: 2,
          strokeColor: Colors.white,
          fillColor: Color.fromARGB(128, 255, 153, 0),
        ),
      };
    });
  }

  Future<LatLng> getCenterCoordinates() async {
    final GoogleMapController controller = await _controller.future;
    LatLngBounds visibleRegion = await controller.getVisibleRegion();

    LatLng centerLatLng = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) /
          2,
    );
    return centerLatLng;
  }

  void startPick(bool isOrigin) {
    setState(() {
      _pickingOrigin = isOrigin;
      _pickingDestination = !isOrigin;
    });
  }

  void updatePick(bool isOrigin) async {
    LatLng centerCoordinates = await getCenterCoordinates();
    if (isOrigin && _pickingOrigin) {
      setState(() {
        _pickedOrigin = centerCoordinates;
      });
    }
    if (!isOrigin && _pickingDestination) {
      setState(() {
        _pickedDestination = centerCoordinates;
      });
    }
    BitmapDescriptor markerIcon = await BitmapDescriptor.asset(
      ImageConfiguration(),
      'assets/marker.png',
      width: 15,
      height: 15,
    );
    BitmapDescriptor altMarkerIcon = await BitmapDescriptor.asset(
      ImageConfiguration(),
      'assets/alt_marker.png',
      width: 15,
      height: 15,
    );
    Set<Marker> markers = {};
    if (_pickedOrigin != null) {
      markers.add(
        Marker(
          markerId: MarkerId('o'),
          position: _pickedOrigin!,
          icon: altMarkerIcon,
          anchor: Offset(0.5, 0.5),
        ),
      );
    }
    if (_pickedDestination != null) {
      markers.add(
        Marker(
          markerId: MarkerId('d'),
          position: _pickedDestination!,
          icon: markerIcon,
          anchor: Offset(0.5, 0.5),
        ),
      );
    }
    setState(() {
      _markers = markers;
      _pickingDestination = false;
      _pickingOrigin = false;
    });
  }

  void renderPath(dynamic path) async {
    Set<Polyline> segments = {};
    Set<Marker> markers = {};
    for (int i = 0; i < path["segments"].length; i++) {
      dynamic segment = path["segments"][i];
      markers.addAll(await directionsFromRouteDynamic(segment, i==0, i==path["segments"].length-1));
      print(markers);
      List<LatLng> points = [];
      segment["path"].forEach(
        (p) => points.add(LatLng(p["x_coord"], p["y_coord"])),
      );
      segments.add(
        Polyline(
          polylineId: PolylineId('${segment["route"]["id"]}_pll'),
          points: points,
          color: hexToColor(segment["route"]["line"]["color"]),
          width: 3,
        ),
      );
    }
    setState(() {
      _polylines = segments;
      _markers = markers;
    });
  }

  Color hexToColor(String hexString) {
    final hexCode = hexString.replaceAll('#', '');
    final fullHexCode = hexCode.length == 6 ? 'FF$hexCode' : hexCode;
    return Color(int.parse(fullHexCode, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kStartingPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _markers,
            polylines: _polylines,
            circles: _circles,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            tiltGesturesEnabled: false,
          ),
          if (_pickingPosition || _pickingDestination)
            Center(
              child: Image.asset('assets/marker.png', width: 15, height: 15),
            ),
          if (_pickingOrigin)
            Center(
              child: Image.asset(
                'assets/alt_marker.png',
                width: 15,
                height: 15,
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                _pickedOrigin = null;
                _pickedDestination = null;
                updatePick(true);
                showModalBottomSheet(
                  showDragHandle: true,
                  context: context,
                  builder: (BuildContext context) {
                    return Linesmenu(setLineRoute: setLineRoute);
                  },
                );
              },
              icon: Icon(Icons.directions_bus),
            ),
            IconButton(
              onPressed: _lineRoutes.length > 1 ? swapLineRoute : null,
              icon: Icon(Icons.swap_vert),
            ),
            //IconButton(
            //  onPressed: onCloseLinesButton,
            //  icon: Icon(Icons.swap_calls),
            //),
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _polylines = {};
                    });
                    _bottomSheetController = Scaffold.of(
                      context,
                    ).showBottomSheet((context) {
                      return Bestpathmenu(
                        startPick: startPick,
                        updatePick: updatePick,
                      );
                    }, showDragHandle: true);
                  },
                  icon: Icon(Icons.swap_calls),
                );
              },
            ),
            IconButton(
              onPressed:
                  _pickedOrigin != null && _pickedDestination != null
                      ? () {
                        setState(() {
                          _polylines = {};
                        });
                        showModalBottomSheet(
                          showDragHandle: true,
                          context: context,
                          builder: (BuildContext context) {
                            return Bestpathlistmenu(
                              originCoords: _pickedOrigin!,
                              destinationCoords: _pickedDestination!,
                              renderPath: renderPath,
                            );
                          },
                        );
                      }
                      : null,
              icon: Icon(Icons.list),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getCurrentLocation();
          _goTo(_currentPosition);
        },
        child: Icon(Icons.location_searching),
      ),
    );
  }

  Future<void> _goTo(LatLng location) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 15),
      ),
    );
  }
}
