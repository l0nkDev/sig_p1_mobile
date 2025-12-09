import 'package:sig_p1_mobile/models/point.dart';

class RenderedRoute {
  final int id;
  final bool isReturn;
  final double distance;
  final double time;
  final String lineColor;
  final List<Point> path;

  RenderedRoute({required this.id, required this.isReturn, required this.distance, required this.time, required this.path, required this.lineColor});

  factory RenderedRoute.fromJson(Map<String, dynamic> json) {
    var pointsListJson = json['path'] as List;
    List<Point> pointsList = pointsListJson.map((r) => Point.fromJson(r)).toList();
    return RenderedRoute(
      id: json['id'],
      isReturn: json['isReturn'],
      distance: json['distance'],
      time: json['time'],
      lineColor: json['lineColor'],
      path: pointsList
    );
  }
}