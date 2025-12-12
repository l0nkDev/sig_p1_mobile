import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sig_p1_mobile/config.dart';
import 'package:sig_p1_mobile/models/renderedroute.dart';

class Radiusmenu extends StatefulWidget {
  final void Function(double) setRadius;
  Radiusmenu({super.key, required this.setRadius});

  @override
  State<Radiusmenu> createState() => _RadiusmenuState();
}

class _RadiusmenuState extends State<Radiusmenu> {
  double _radius = 50;

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
  Widget build(BuildContext context) {
    return Slider(
      value: _radius,
      onChanged: (v) {
        setState(() {
          _radius = v;
        });
        widget.setRadius(v);
      },
      min: 0,
      max: 1000,
    );
  }
}
