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

  // ── Local DB (SQLite) ─────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remoteId': remoteId,
      'name': name,
      'birthDate': birthDate,
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
      birthDate: map['birthDate'],
      gender: map['gender'],
      avatar: map['avatar'],
      level: map['level'] ?? 'level1',
    );
  }

  // ── Remote API (Server) ───────────────────────────────────
  // Matches exactly the server's expected request body:
  // { "name": "Omar", "birthDate": "01/01/2020", "gender": 1, "avatar": "...", "level": "level1" }
  Map<String, dynamic> toRemoteJson() {
    if (name.trim().isEmpty) {
      throw Exception('اسم الطفل لا يمكن أن يكون فارغاً');
    }
    final body = {
      'name': name.trim(),
      'birthDate': birthDate,
      'gender': gender, // int as-is: 1 = boy, 0 = girl
      'avatar': avatar,
      'level': level,
    };
    print('=== Sending to Server ===');
    print('Request Body: $body');
    return body;
  }

  // Handles server response — gender may come back as int or string depending on server
  factory ChildModel.fromRemoteJson(Map<String, dynamic> json) {
    print('=== ChildModel.fromRemoteJson ===');
    print('Received JSON: $json');

    // Parse gender flexibly: server might return 1/0 or "male"/"female"
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
      birthDate: json['birthDate'] ?? '',
      gender: parsedGender,
      avatar: json['avatar'] ?? 'assets/images/child/avater1.jpg',
      level: json['level'] ?? 'level1',
    );
  }

  // Copy with local SQLite id after insert
  ChildModel copyWithLocalId(int localId) {
    return ChildModel(
      id: localId,
      remoteId: remoteId,
      name: name,
      birthDate: birthDate,
      gender: gender,
      avatar: avatar,
      level: level,
    );
  }
}
