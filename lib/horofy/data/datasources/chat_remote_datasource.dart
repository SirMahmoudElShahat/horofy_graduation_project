import 'package:dio/dio.dart';
import 'package:horofy/core/cache/cache_helper.dart';
import 'package:horofy/core/constants/app_apis.dart';

// ── AI sender ID (senderId = 999 means Shalby's reply) ───────────────────────
const int _aiSenderId = 999;

// ═════════════════════════════════════════════════════════════════════════════
//  Models
// ═════════════════════════════════════════════════════════════════════════════

class ChatConversationModel {
  final int id;
  final String title;
  final int? childId;
  final String? lastMessage;
  final DateTime createdAt;

  const ChatConversationModel({
    required this.id,
    required this.title,
    this.childId,
    this.lastMessage,
    required this.createdAt,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    String? lastMessage;
    final childId = json['childId'] is int
        ? json['childId'] as int
        : int.tryParse(json['childId']?.toString() ?? '');

    final rawLastMessage = json['lastMessage'] ?? json['last_message'];
    if (rawLastMessage is String) {
      lastMessage = rawLastMessage;
    } else if (rawLastMessage is Map<String, dynamic>) {
      lastMessage = rawLastMessage['content'] as String?;
    }

    final rawMessages = json['messages'] as List<dynamic>?;
    if (rawMessages != null && rawMessages.isNotEmpty) {
      final parsedMessages = rawMessages
          .whereType<Map<String, dynamic>>()
          .map((item) => ChatMessageModel.fromJson(item))
          .toList();
      if (parsedMessages.isNotEmpty) {
        parsedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        lastMessage = parsedMessages.last.content;
      }
    }

    return ChatConversationModel(
      id: json['id'] as int,
      title: json['title'] ?? 'محادثة',
      childId: childId,
      lastMessage: lastMessage,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class ChatMessageModel {
  final int id;
  final String content;
  final bool isFromUser; // true = user message, false = Shalby reply
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.isFromUser,
    required this.createdAt,
  });

  // senderId == 999 → Shalby (AI), anything else → user
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final senderId = json['senderId'] as int? ?? 0;
    return ChatMessageModel(
      id: json['id'] as int,
      content: json['content'] ?? '',
      isFromUser: senderId != _aiSenderId,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Abstract
// ═════════════════════════════════════════════════════════════════════════════

abstract class ChatRemoteDataSource {
  Future<List<ChatConversationModel>> getConversations();
  Future<ChatConversationModel> createConversation({
    required String title,
    required int childId,
    String status = 'active',
  });
  Future<void> deleteConversation(int id);
  Future<List<ChatMessageModel>> getMessages(
    int conversationId, {
    int page = 1,
    int limit = 10,
  });
  // Returns Shalby's AI reply
  Future<ChatMessageModel> sendMessage(int conversationId, String content);
}

// ═════════════════════════════════════════════════════════════════════════════
//  Implementation
// ═════════════════════════════════════════════════════════════════════════════

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl({required this.dio});

  Options get _authOptions {
    final token = CacheHelper.getString('accessToken') ?? '';
    return Options(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  void _throwIfError(Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.data['message'] ?? 'حدث خطأ، حاول تاني');
    }
  }

  // ── GET conversations ─────────────────────────────────────
  @override
  Future<List<ChatConversationModel>> getConversations() async {
    final response = await dio.get(
      AppApis.getUserConversations,
      options: _authOptions,
    );
    _throwIfError(response);
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => ChatConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── CREATE conversation ───────────────────────────────────
  @override
  Future<ChatConversationModel> createConversation({
    required String title,
    required int childId,
    String status = 'active',
  }) async {
    final response = await dio.post(
      AppApis.createConversation,
      options: _authOptions,
      data: {'childId': childId, 'title': title, 'status': status},
    );
    _throwIfError(response);
    return ChatConversationModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  // ── DELETE conversation ───────────────────────────────────
  @override
  Future<void> deleteConversation(int id) async {
    final response = await dio.delete(
      AppApis.deleteConversation(id.toString()),
      options: _authOptions,
    );
    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception(response.data['message'] ?? 'فشل الحذف');
    }
  }

  // ── GET messages ──────────────────────
  @override
  Future<List<ChatMessageModel>> getMessages(
    int conversationId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await dio.get(
      AppApis.getMessages(conversationId.toString()),
      options: _authOptions,
      queryParameters: {'page': page, 'limit': limit},
    );
    _throwIfError(response);
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── SEND message → returns Shalby's AI reply ─────────────
  // Response example:
  // { "data": { "id": 22, "senderId": 999, "content": "أنا متعافى", ... } }
  // senderId = 999 → always Shalby's reply
  @override
  Future<ChatMessageModel> sendMessage(
    int conversationId,
    String content,
  ) async {
    final response = await dio.post(
      AppApis.sendMessage(conversationId.toString()),
      options: _authOptions,
      data: {'content': content, 'type': 'text', 'metadata': {}},
    );
    _throwIfError(response);
    return ChatMessageModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
