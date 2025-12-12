import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sig_p1_mobile/config.dart';

class Bestpathlistmenu extends StatefulWidget {
  final LatLng originCoords;
  final LatLng destinationCoords;
  final void Function(dynamic) renderPath;
  final void Function(List<dynamic>) setCalculations;
  final List<dynamic>? paths;
  const Bestpathlistmenu({
    super.key,
    required this.originCoords,
    required this.destinationCoords,
    required this.renderPath,
    required this.setCalculations,
    required this.paths,
  });

  @override
  State<Bestpathlistmenu> createState() => _LinesmenuState();
}

class _LinesmenuState extends State<Bestpathlistmenu> {
  late Future<List<dynamic>> _pathsFuture;

  Future<List<dynamic>> fetchLines() async {
    final response = await http.get(
      Uri.parse(
        '$API_BASE_URL/api/routes/best/${widget.originCoords.latitude}/${widget.originCoords.longitude}/${widget.destinationCoords.latitude}/${widget.destinationCoords.longitude}',
      ),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      widget.setCalculations(jsonList);
      return jsonList;
    } else {
      throw Exception("Failed to load lines");
    }
  }

  Future<List<dynamic>> choosePathSource() async {
    if (widget.paths != null)
      return widget.paths!;
    else
      return await fetchLines();
  }

  Color hexToColor(String hexString) {
    final hexCode = hexString.replaceAll('#', '');
    final fullHexCode = hexCode.length == 6 ? 'FF$hexCode' : hexCode;
    return Color(int.parse(fullHexCode, radix: 16));
  }

  @override
  void initState() {
    super.initState();
    _pathsFuture = choosePathSource();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FutureBuilder(
            future: _pathsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Expanded(
                  child: Column(
                    children: [Spacer(), CircularProgressIndicator(), Spacer()],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                List<dynamic> lines = snapshot.data!;
                if (lines[0]["segments"].length == 0) {
                  return Text(
                    "No se pudieron calcular rutas, inténtelo con nuevos puntos.",
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: lines.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Builder(
                            builder: (context) {
                              List<Widget> segments = [];
                              lines[index]["segments"].forEach((e) {
                                segments.add(
                                  CircleAvatar(
                                    backgroundColor: hexToColor(
                                      e["route"]["line"]["color"],
                                    ),
                                    child: Text(
                                      "${int.parse(e["route"]["line"]["name"].substring(1))}",
                                    ),
                                  ),
                                );
                                segments.add(Icon(Icons.arrow_right_alt));
                              });
                              segments.removeLast();
                              return Column(
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(children: segments),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Distancia: ${lines[index]["distance"].toStringAsFixed(2)} m.",
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Trasbordos: ${lines[index]["segments"].length - 1}",
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          onTap: () {
                            widget.renderPath(lines[index]);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Column(
                  children: [Spacer(), Text("Sin datos"), Spacer()],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
