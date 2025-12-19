import 'dart:convert';

class Ticket {
  final int? id;
  final String trainName;
  final String fromStation;
  final String toStation;
  final DateTime travelDate;
  final String filePath;

  Ticket({
    this.id,
    required this.trainName,
    required this.fromStation,
    required this.toStation,
    required this.travelDate,
    required this.filePath,
  });

  bool get isPdf => filePath.toLowerCase().endsWith('.pdf');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainName': trainName,
      'fromStation': fromStation,
      'toStation': toStation,
      'travelDate': travelDate.toIso8601String(),
      'pdfPath':
          filePath, // Keeping column name as pdfPath for database compatibility or renaming it if preferred
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'] as int?,
      trainName: map['trainName'] as String,
      fromStation: map['fromStation'] as String,
      toStation: map['toStation'] as String,
      travelDate: DateTime.parse(map['travelDate'] as String),
      filePath: map['pdfPath'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Ticket.fromJson(String source) =>
      Ticket.fromMap(json.decode(source) as Map<String, dynamic>);

  Ticket copyWith({
    int? id,
    String? trainName,
    String? fromStation,
    String? toStation,
    DateTime? travelDate,
    String? filePath,
  }) {
    return Ticket(
      id: id ?? this.id,
      trainName: trainName ?? this.trainName,
      fromStation: fromStation ?? this.fromStation,
      toStation: toStation ?? this.toStation,
      travelDate: travelDate ?? this.travelDate,
      filePath: filePath ?? this.filePath,
    );
  }
}
