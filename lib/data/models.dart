// lib/data/models.dart
import 'dart:convert';

class ChecklistItem {
  final String id;
  final String category;
  final String label;
  final double quantity;
  final QuantityUnit unit;
  bool isChecked;
  final int sortOrder;

  ChecklistItem({
    required this.id,
    required this.category,
    required this.label,
    this.quantity = 1,
    this.unit = QuantityUnit.piece,
    this.isChecked = false,
    required this.sortOrder,
  });

  ChecklistItem copyWith({
    String? id,
    String? category,
    String? label,
    double? quantity,
    QuantityUnit? unit,
    bool? isChecked,
    int? sortOrder,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      category: category ?? this.category,
      label: label ?? this.label,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as String,
      category: map['category'] as String,
      label: map['label'] as String,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1,
      unit: QuantityUnit.values.firstWhere(
        (u) => u.name == map['unit'],
        orElse: () => QuantityUnit.piece,
      ),
      isChecked: map['isChecked'] as bool? ?? false,
      sortOrder: map['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'label': label,
      'quantity': quantity,
      'unit': unit.name,
      'isChecked': isChecked,
      'sortOrder': sortOrder,
    };
  }
}

enum QuantityUnit { piece, litre, kg }

extension QuantityUnitLabels on QuantityUnit {
  String get label {
    switch (this) {
      case QuantityUnit.piece:
        return 'Adet';
      case QuantityUnit.litre:
        return 'Litre';
      case QuantityUnit.kg:
        return 'Kilogram';
    }
  }

  String get shortLabel {
    switch (this) {
      case QuantityUnit.piece:
        return 'ad';
      case QuantityUnit.litre:
        return 'L';
      case QuantityUnit.kg:
        return 'kg';
    }
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
  List<String> participants;
  List<String> categories;

  Camp({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.note,
    required this.items,
    required this.photoPaths,
    required this.participants,
    required this.categories,
  });

  Camp copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? location,
    String? note,
    List<ChecklistItem>? items,
    List<String>? photoPaths,
    List<String>? participants,
    List<String>? categories,
  }) {
    return Camp(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      note: note ?? this.note,
      items: items ?? this.items,
      photoPaths: photoPaths ?? this.photoPaths,
      participants: participants ?? this.participants,
      categories: categories ?? this.categories,
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
      participants: (map['participants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      categories: (map['categories'] as List<dynamic>?)
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
      'participants': participants,
      'categories': categories,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory Camp.fromJson(String source) =>
      Camp.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
