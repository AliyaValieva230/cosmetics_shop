import 'package:pocketbase/pocketbase.dart';

class Brand {
  final String? id;
  final String name;
  final String country;
  final String description;

  Brand({this.id, required this.name, this.country = '', this.description = ''});

  factory Brand.fromRecord(RecordModel r) => Brand(
        id: r.id,
        name: r.getStringValue('name'),
        country: r.getStringValue('country'),
        description: r.getStringValue('description'),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'description': description,
      };
}