class WellnessEntry {
  final String id;
  final DateTime date;
  final double? weight;
  final String? bloodPressure;
  final int? mood; // 1-5 scale
  final String notes;
  final List<String> symptoms;

  WellnessEntry({
    required this.id,
    required this.date,
    this.weight,
    this.bloodPressure,
    this.mood,
    this.notes = '',
    this.symptoms = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weight': weight,
      'bloodPressure': bloodPressure,
      'mood': mood,
      'notes': notes,
      'symptoms': symptoms,
    };
  }

  factory WellnessEntry.fromJson(Map<String, dynamic> json) {
    return WellnessEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      weight: json['weight'] as double?,
      bloodPressure: json['bloodPressure'] as String?,
      mood: json['mood'] as int?,
      notes: json['notes'] as String? ?? '',
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
