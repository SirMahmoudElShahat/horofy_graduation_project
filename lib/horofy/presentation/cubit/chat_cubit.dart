import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horofy/horofy/data/datasources/chat_remote_datasource.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRemoteDataSource dataSource;

  ChatCubit({required this.dataSource}) : super(ChatInitial());

  // ── Load all conversations ────────────────────────────────
  Future<void> loadConversations() async {
    emit(ChatLoading());
    try {
      final conversations = await dataSource.getConversations();
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ── Delete a conversation ─────────────────────────────────
  Future<void> deleteConversation(int id) async {
    try {
      await dataSource.deleteConversation(id);
      await loadConversations();
    } catch (e) {
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ── Load messages (page=1, limit=10) ─────────────────────
  Future<void> loadMessages(int conversationId) async {
    emit(MessagesLoaded([], isLoading: true));
    try {
      final messages = await dataSource.getMessages(
        conversationId,
        page: 1,
        limit: 10,
      );
      final hasMore = messages.length == 10;
      emit(MessagesLoaded(messages, currentPage: 1, hasMoreMessages: hasMore));
    } catch (e) {
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ── Load more messages (scroll up) ─────────────────────────
  Future<void> loadMoreMessages(int conversationId) async {
    final currentState = state;
    if (currentState is! MessagesLoaded) return;
    if (!currentState.hasMoreMessages || currentState.isLoadingMore) return;

    try {
      emit(currentState.copyWith(isLoadingMore: true));

      final nextPage = currentState.currentPage + 1;
      final newMessages = await dataSource.getMessages(
        conversationId,
        page: nextPage,
        limit: 10,
      );
      final combined = [...currentState.messages, ...newMessages];
      final hasMore = newMessages.length == 10;
      emit(
        currentState.copyWith(
          messages: combined,
          currentPage: nextPage,
          hasMoreMessages: hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ── Create conversation + send first message ──────────────
  // Returns the created conversation so the screen can navigate
  Future<ChatConversationModel?> createConversationAndSend({
    required String firstMessage,
    required int childId,
  }) async {
    try {
      // Title = first 30 chars of the message
      final title = firstMessage.length > 30
          ? '${firstMessage.substring(0, 30)}...'
          : firstMessage;

      final conv = await dataSource.createConversation(
        title: title,
        childId: childId,
      );

      // Send the first message (fire and forget here —
      // loadMessages will fetch both user msg + AI reply after)
      await dataSource.sendMessage(conv.id, firstMessage);

      return conv;
    } catch (e) {
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
      return null;
    }
  }

  // ── Create & load first message (emits loading immediately) ────
  Future<ChatConversationModel?> createAndLoadFirstMessage({
    required String firstMessage,
    required int childId,
  }) async {
    // صدر loading state فوراً مع تعطيل الكتابة
    emit(MessagesLoaded([], isLoading: true, isSending: true));

    try {
      final title = firstMessage.length > 30
          ? '${firstMessage.substring(0, 30)}...'
          : firstMessage;

      final conv = await dataSource.createConversation(
        title: title,
        childId: childId,
      );
      await dataSource.sendMessage(conv.id, firstMessage);

      // الآن حمّل الرسايل
      final messages = await dataSource.getMessages(
        conv.id,
        page: 1,
        limit: 10,
      );
      final hasMore = messages.length == 10;

      emit(MessagesLoaded(messages, currentPage: 1, hasMoreMessages: hasMore));

      return conv;
    } catch (e) {
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
      return null;
    }
  }

  // ── Send message to existing conversation ─────────────────
  Future<void> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    final currentState = state;
    if (currentState is! MessagesLoaded) return;

    // 1. Optimistically add user's message to UI immediately
    final userMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch, // temp local id
      content: content,
      isFromUser: true,
      createdAt: DateTime.now(),
    );

    emit(
      currentState.copyWith(
        messages: [userMsg, ...currentState.messages],
        isSending: true, // show "شلبى بيفكر..."
      ),
    );

    try {
      // 2. POST to API → returns Shalby's AI reply (senderId=999)
      final aiReply = await dataSource.sendMessage(conversationId, content);

      final updated = state as MessagesLoaded;
      emit(
        updated.copyWith(
          messages: [aiReply, ...updated.messages],
          isSending: false,
        ),
      );
    } catch (e) {
      // Remove sending indicator even on error
      if (state is MessagesLoaded) {
        emit((state as MessagesLoaded).copyWith(isSending: false));
      }
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
