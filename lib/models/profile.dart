import 'package:pocketbase/pocketbase.dart';

class Profile {
  final String? id;
  final String userId;
  final String phone;
  final String address;
  final DateTime? birthdate;
  final double bonusBalance;

  Profile({
    this.id,
    required this.userId,
    this.phone = '',
    this.address = '',
    this.birthdate,
    this.bonusBalance = 0,
  });

  factory Profile.fromRecord(RecordModel r) => Profile(
        id: r.id,
        userId: r.getStringValue('user'),
        phone: r.getStringValue('phone'),
        address: r.getStringValue('address'),
        birthdate: DateTime.tryParse(r.getStringValue('birthdate')),
        bonusBalance: r.getDoubleValue('bonus_balance'),
      );

  Map<String, dynamic> toJson() => {
        'user': userId,
        'phone': phone,
        'address': address,
        'birthdate': birthdate?.toIso8601String(),
        'bonus_balance': bonusBalance,
      };
}