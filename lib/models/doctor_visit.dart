class DoctorVisit {
  final String id;
  final DateTime date;
  final String doctorName;
  final String notes;
  final List<String> testResults;
  final List<String> questionsToAsk;
  final double? weight;
  final String? bloodPressure;

  DoctorVisit({
    required this.id,
    required this.date,
    this.doctorName = '',
    this.notes = '',
    this.testResults = const [],
    this.questionsToAsk = const [],
    this.weight,
    this.bloodPressure,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'doctorName': doctorName,
      'notes': notes,
      'testResults': testResults,
      'questionsToAsk': questionsToAsk,
      'weight': weight,
      'bloodPressure': bloodPressure,
    };
  }

  factory DoctorVisit.fromJson(Map<String, dynamic> json) {
    return DoctorVisit(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      doctorName: json['doctorName'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      testResults: (json['testResults'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      questionsToAsk: (json['questionsToAsk'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      weight: json['weight'] as double?,
      bloodPressure: json['bloodPressure'] as String?,
    );
  }

  DoctorVisit copyWith({
    String? id,
    DateTime? date,
    String? doctorName,
    String? notes,
    List<String>? testResults,
    List<String>? questionsToAsk,
    double? weight,
    String? bloodPressure,
  }) {
    return DoctorVisit(
      id: id ?? this.id,
      date: date ?? this.date,
      doctorName: doctorName ?? this.doctorName,
      notes: notes ?? this.notes,
      testResults: testResults ?? this.testResults,
      questionsToAsk: questionsToAsk ?? this.questionsToAsk,
      weight: weight ?? this.weight,
      bloodPressure: bloodPressure ?? this.bloodPressure,
    );
  }
}
