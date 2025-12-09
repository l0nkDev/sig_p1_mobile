import 'package:sig_p1_mobile/models/route.dart';

class Line {
  final int id;
  final String name;
  final String color;
  final List<Route> routes;

  Line({required this.id, required this.name, required this.routes, required this.color});

  factory Line.fromJson(Map<String, dynamic> json) {
    var routesListJson = json['routes'] as List;
    List<Route> routesList = routesListJson.map((r) => Route.fromJson(r)).toList();
    return Line(
      id: json['id'],
      name: json['name'],
      routes: routesList,
      color: json['color']
    );
  }
}