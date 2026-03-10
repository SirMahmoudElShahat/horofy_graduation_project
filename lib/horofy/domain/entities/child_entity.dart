import 'package:equatable/equatable.dart';

class ChildEntity extends Equatable {
  final int? id;
  final String name;
  final String birthDate;
  final int gender;
  final String avatar;
  final String level;

  const ChildEntity({
    this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.avatar,
    String? level,
  }) : level = level ?? 'level1';

  @override
  List<Object?> get props => [id, name, birthDate, gender, avatar, level];
}
