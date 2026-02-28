import '../../domain/entities/child_entity.dart';

class ChildModel extends ChildEntity {
  const ChildModel({
    super.id,
    required super.name,
    required super.birthDate,
    required super.gender,
    required super.avatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate,
      'gender': gender,
      'avatar': avatar,
    };
  }

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'],
      name: map['name'],
      birthDate: map['birthDate'],
      gender: map['gender'],
      avatar: map['avatar'],
    );
  }
}
