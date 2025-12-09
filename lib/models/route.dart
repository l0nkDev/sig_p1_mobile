class Route {
  final int id;
  final bool isReturn;
  final double distance;
  final double time;

  Route({required this.id, required this.isReturn, required this.distance, required this.time});

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'],
      isReturn: json['isReturn'],
      distance: json['distance'],
      time: json['time'],
    );
  }
}