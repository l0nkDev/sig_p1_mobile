import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sig_p1_mobile/models/line.dart';
import 'package:sig_p1_mobile/models/renderedroute.dart';

class Bestpathmenu extends StatefulWidget {
  final void Function(bool) startPick;
  final void Function(bool) updatePick;
  const Bestpathmenu({super.key, required this.startPick, required this.updatePick});

  @override
  State<Bestpathmenu> createState() => _BestpathmenuState();
}

class _BestpathmenuState extends State<Bestpathmenu> {
  final TextEditingController _OriginController = TextEditingController();
  final TextEditingController _DestinationController = TextEditingController();
  late Future<List<Line>> _linesFuture;

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
              child: TextField(
                controller: _OriginController,
                decoration: InputDecoration(
                  labelText: 'Origen',
                  border: OutlineInputBorder(),
                ),
              ),
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
              child: TextField(
                controller: _DestinationController,
                decoration: InputDecoration(
                  labelText: 'Destino',
                  border: OutlineInputBorder(),
                ),
              ),
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
