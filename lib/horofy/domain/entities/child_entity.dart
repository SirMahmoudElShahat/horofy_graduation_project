import 'package:equatable/equatable.dart';

class ChildEntity extends Equatable {
  final int? id;
  final String name;
  final String birthDate;
  final int gender;
  final String avatar;

  const ChildEntity({
    this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.avatar,
  });

  @override
  List<Object?> get props =>
      [id, name, birthDate, gender, avatar];
}
