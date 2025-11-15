class ChecklistItem {
  final String id;
  final String title;
  final String category;
  final bool isCompleted;
  final String? notes;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? category,
    bool? isCompleted,
    String? notes,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }
}
