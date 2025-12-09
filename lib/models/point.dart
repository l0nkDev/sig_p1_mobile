class Point {
  final double xCoord;
  final double yCoord;

  Point({required this.xCoord, required this.yCoord});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      xCoord: json['x_coord'],
      yCoord: json['y_coord'],
    );
  }
}