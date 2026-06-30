class Task {
  final String id;
  final String familyCode;
  String title;
  String description;
  bool isDone;
  String? assignedTo;
  String createdBy;
  DateTime createdAt;
  DateTime? doneAt;

  Task({
    required this.id,
    required this.familyCode,
    required this.title,
    this.description = '',
    this.isDone = false,
    this.assignedTo,
    required this.createdBy,
    required this.createdAt,
    this.doneAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      familyCode: json['family_code'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      isDone: json['is_done'] as bool? ?? false,
      assignedTo: json['assigned_to'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      doneAt: json['done_at'] != null
          ? DateTime.parse(json['done_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_code': familyCode,
      'title': title,
      'description': description,
      'is_done': isDone,
      'assigned_to': assignedTo,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'done_at': doneAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'description': description,
      'is_done': isDone,
      'assigned_to': assignedTo,
      'done_at': doneAt?.toIso8601String(),
    };
  }

  Task copyWith({
    String? title,
    String? description,
    bool? isDone,
    String? assignedTo,
    DateTime? doneAt,
  }) {
    return Task(
      id: id,
      familyCode: familyCode,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy,
      createdAt: createdAt,
      doneAt: doneAt ?? this.doneAt,
    );
  }
}
