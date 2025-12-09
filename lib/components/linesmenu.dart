import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sig_p1_mobile/models/line.dart';
import 'package:sig_p1_mobile/models/renderedroute.dart';

class Linesmenu extends StatefulWidget {
  final void Function(List<RenderedRoute>, Color) setLineRoute;
  Linesmenu({super.key, required this.setLineRoute});

  @override
  State<Linesmenu> createState() => _LinesmenuState();
}

class _LinesmenuState extends State<Linesmenu> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Line>> _linesFuture;

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
      widget.setLineRoute(routes, hexToColor(routes[0].lineColor));
      return routes;
    } else {
      throw Exception("Failed to load routes");
    }
  }

  Color hexToColor(String hexString) {
    final hexCode = hexString.replaceAll('#', '');
    final fullHexCode = hexCode.length == 6 ? 'FF$hexCode' : hexCode;
    return Color(int.parse(fullHexCode, radix: 16));
  }

  @override
  void initState() {
    super.initState();
    _linesFuture = fetchLines();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: SearchBar(
              controller: _searchController,
              hintText: "Buscar...",
              leading: const Icon(Icons.search),
              onChanged:
                  (v) => {
                    setState(() {
                      _searchText = v;
                    }),
                  },
            ),
          ),
          FutureBuilder(
            future: _linesFuture,
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
                List<Line> lines =
                    _searchText.isNotEmpty
                        ? snapshot.data!
                            .where((l) => l.name.contains(_searchText))
                            .toList()
                        : snapshot.data!;
                return Expanded(
                  child: ListView.builder(
                    itemCount: lines.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              '${int.parse((lines[index].name.substring(1)))}',
                            ),
                          ),
                          title: Text(
                            'Linea ${int.parse((lines[index].name.substring(1)))}',
                          ),
                          onTap: () async {
                            await fetchLineRoutes(lines[index].id);
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
