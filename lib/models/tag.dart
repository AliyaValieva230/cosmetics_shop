import 'package:pocketbase/pocketbase.dart';

class Tag {
  final String? id;
  final String name;
  Tag({this.id, required this.name});
  factory Tag.fromRecord(RecordModel r) => Tag(id: r.id, name: r.getStringValue('name'));
  Map<String, dynamic> toJson() => {'name': name};
}