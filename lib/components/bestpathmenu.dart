import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sig_p1_mobile/config.dart';
import 'package:sig_p1_mobile/models/renderedroute.dart';
import 'package:search_map_place_updated/search_map_place_updated.dart';

class Bestpathmenu extends StatefulWidget {
  final void Function(bool) startPick;
  final void Function(bool) updatePick;
  final void Function(bool, Place) updatePickPlace;
  final LatLng centerPos;
  const Bestpathmenu({super.key, required this.startPick, required this.updatePick, required this.updatePickPlace, required this.centerPos});

  @override
  State<Bestpathmenu> createState() => _BestpathmenuState();
}

class _BestpathmenuState extends State<Bestpathmenu> {

  Future<List<RenderedRoute>> fetchLineRoutes(int line_id) async {
    final response = await http.get(
      Uri.parse('$API_BASE_URL/api/lines/$line_id/routes'),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<RenderedRoute> routes =
          jsonList.map((i) => RenderedRoute.fromJson(i)).toList();
      return routes;
    } else {
      throw Exception("Failed to load routes");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {widget.startPick(true);},
              icon: Icon(Icons.location_on_outlined),
              highlightColor: Colors.red,
            ),
            Flexible(
              child: SearchMapPlaceWidget(
                apiKey: "AIzaSyBFfRITJfq9-5WrMBG5hlZXk1U9XvPpgC0",
                onSelected: (Place place) {
                  widget.updatePickPlace(true, place);
                },
                location: widget.centerPos,
                radius: 10000,
                bgColor: Colors.white,
                textColor: Colors.black,
              )
            ),
            IconButton(
              onPressed: () {widget.updatePick(true);},
              icon: Icon(Icons.add),
              highlightColor: Colors.red,
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            IconButton(
              onPressed: () {widget.startPick(false);},
              icon: Icon(Icons.location_on_outlined),
              highlightColor: Colors.red,
            ),
            Flexible(
              child: SearchMapPlaceWidget(
                apiKey: "AIzaSyBFfRITJfq9-5WrMBG5hlZXk1U9XvPpgC0",
                onSelected: (Place place) {
                  widget.updatePickPlace(false, place);
                },
                location: widget.centerPos,
                radius: 10000,
                bgColor: Colors.white,
                textColor: Colors.black,
              )
            ),
            IconButton(
              onPressed: () {widget.updatePick(false);},
              icon: Icon(Icons.add),
              highlightColor: Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}
