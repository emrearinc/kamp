// lib/data/models.dart
import 'dart:convert';

class ChecklistItem {
  final String id;
  final String category;
  final String label;
  bool isChecked;
  final int sortOrder;

  ChecklistItem({
    required this.id,
    required this.category,
    required this.label,
    this.isChecked = false,
    required this.sortOrder,
  });

  ChecklistItem copyWith({
    String? id,
    String? category,
    String? label,
    bool? isChecked,
    int? sortOrder,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      category: category ?? this.category,
      label: label ?? this.label,
      isChecked: isChecked ?? this.isChecked,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as String,
      category: map['category'] as String,
      label: map['label'] as String,
      isChecked: map['isChecked'] as bool? ?? false,
      sortOrder: map['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'label': label,
      'isChecked': isChecked,
      'sortOrder': sortOrder,
    };
  }
}

class Camp {
  final String id;
  String title;
  DateTime date;
  String location;
  String note;
  List<ChecklistItem> items;
  List<String> photoPaths;

  Camp({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.note,
    required this.items,
    required this.photoPaths,
  });

  Camp copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? location,
    String? note,
    List<ChecklistItem>? items,
    List<String>? photoPaths,
  }) {
    return Camp(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      note: note ?? this.note,
      items: items ?? this.items,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }

  factory Camp.fromMap(Map<String, dynamic> map) {
    return Camp(
      id: map['id'] as String,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      location: map['location'] as String,
      note: map['note'] as String? ?? '',
      items: (map['items'] as List<dynamic>)
          .map((e) => ChecklistItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      photoPaths: (map['photoPaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'location': location,
      'note': note,
      'items': items.map((e) => e.toMap()).toList(),
      'photoPaths': photoPaths,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory Camp.fromJson(String source) =>
      Camp.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
