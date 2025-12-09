import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sig_p1_mobile/models/line.dart';
import 'package:sig_p1_mobile/models/renderedroute.dart';

class Radiusmenu extends StatefulWidget {
  final void Function(double) setRadius;
  Radiusmenu({super.key, required this.setRadius});

  @override
  State<Radiusmenu> createState() => _RadiusmenuState();
}

class _RadiusmenuState extends State<Radiusmenu> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Line>> _linesFuture;
  double _radius = 50;

  String _searchText = '';

  Future<List<Line>> fetchLines() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.11:8000/api/lines'),
    );
    print(response);
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<Line> lines = jsonList.map((i) => Line.fromJson(i)).toList();
      return lines;
    } else {
      throw Exception("Failed to load lines");
    }
  }

  Future<List<RenderedRoute>> fetchLineRoutes(int line_id) async {
    final response = await http.get(
      Uri.parse('http://192.168.0.11:8000/api/lines/$line_id/routes'),
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
    _linesFuture = fetchLines();
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
