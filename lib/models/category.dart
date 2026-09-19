import 'package:pocketbase/pocketbase.dart';

class Category {
  final String? id;
  final String name;
  final String description;
  final String? parentId;

  Category({this.id, required this.name, this.description = '', this.parentId});

  factory Category.fromRecord(RecordModel r) => Category(
        id: r.id,
        name: r.getStringValue('name'),
        description: r.getStringValue('description'),
        parentId: r.getStringValue('parent').isEmpty ? null : r.getStringValue('parent'),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'parent': parentId,
      };
}