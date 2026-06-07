import '../../domain/entities/child_entity.dart';

class ChildModel extends ChildEntity {
  const ChildModel({
    super.id,
    super.remoteId,
    required super.name,
    required super.birthDate,
    required super.gender,
    required super.avatar,
    super.level,
  });

  // Strips ISO time part: "2016-01-28T00:00:00.000Z" → "2016-01-28"
  static String _normalizeBirthDate(dynamic rawBirthDate) {
    final value = rawBirthDate?.toString().trim() ?? '';
    if (value.isEmpty) return '';
    return value.split(RegExp(r'[T ]')).first;
  }

  // Converts any stored date to MM/DD/YYYY for API requests
  static String _birthDateForRequest(String rawBirthDate) {
    final value = rawBirthDate.trim();
    if (value.isEmpty) return '';

    final dt = DateTime.tryParse(value);
    if (dt != null) {
      return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}';
    }

    // Already MM/DD/YYYY (from add screen) — return as-is
    return value;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remoteId': remoteId,
      'name': name,
      'birthDate': _normalizeBirthDate(birthDate),
      'gender': gender,
      'avatar': avatar,
      'level': level,
    };
  }

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'],
      remoteId: map['remoteId'],
      name: map['name'],
      birthDate: _normalizeBirthDate(map['birthDate']),
      gender: map['gender'],
      avatar: map['avatar'],
      level: map['level'] ?? 'level1',
    );
  }

  Map<String, dynamic> toRemoteJson() {
    if (name.trim().isEmpty) {
      throw Exception('اسم الطفل لا يمكن أن يكون فارغاً');
    }
    final body = {
      'name': name.trim(),
      'birthDate': _birthDateForRequest(birthDate),
      'gender': gender,
      'avatar': avatar,
      'level': level,
    };
    print('=== Sending to Server ===');
    print('Request Body: $body');
    return body;
  }

  factory ChildModel.fromRemoteJson(Map<String, dynamic> json) {
    print('=== ChildModel.fromRemoteJson ===');
    print('Received JSON: $json');

    int parsedGender;
    final rawGender = json['gender'];
    if (rawGender is int) {
      parsedGender = rawGender;
    } else if (rawGender == 'male' || rawGender == 1) {
      parsedGender = 1;
    } else {
      parsedGender = 0;
    }

    final name = json['name']?.toString().trim() ?? '';
    print('Parsed Name: "$name"');
    print('Parsed Gender: $parsedGender');

    if (name.isEmpty) {
      throw Exception('اسم الطفل مفقود في استجابة الخادم: ${json.toString()}');
    }

    final remoteId = json['id']?.toString() ?? json['_id']?.toString();
    print('Parsed Remote ID: $remoteId');

    return ChildModel(
      id: remoteId != null ? int.tryParse(remoteId) : null,
      remoteId: remoteId,
      name: name,
      birthDate: _normalizeBirthDate(json['birthDate']),
      gender: parsedGender,
      avatar: json['avatar'] ?? 'assets/images/child/avater1.jpg',
      level: json['level'] ?? 'level1',
    );
  }

  ChildModel copyWithLocalId(int localId) {
    return ChildModel(
      id: localId,
      remoteId: remoteId,
      name: name,
      birthDate: _normalizeBirthDate(birthDate),
      gender: gender,
      avatar: avatar,
      level: level,
    );
  }
}
