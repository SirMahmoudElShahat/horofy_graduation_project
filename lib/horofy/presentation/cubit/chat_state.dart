import 'package:equatable/equatable.dart';
import 'package:horofy/horofy/data/datasources/chat_remote_datasource.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

// ── Conversations list ────────────────────────────────────────────────────────
class ConversationsLoaded extends ChatState {
  final List<ChatConversationModel> conversations;

  const ConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

// ── Messages inside a conversation ───────────────────────────────────────────
class MessagesLoaded extends ChatState {
  final List<ChatMessageModel> messages;
  final bool isSending; // true while waiting for AI reply
  final int currentPage; // current page loaded
  final bool hasMoreMessages; // هل في رسايل أكتر
  final bool isLoadingMore; // هل جاري تحميل رسايل اكتر
  final bool isLoading; // هل جاري تحميل رسايل الأولى

  const MessagesLoaded(
    this.messages, {
    this.isSending = false,
    this.currentPage = 1,
    this.hasMoreMessages = true,
    this.isLoadingMore = false,
    this.isLoading = false,
  });

  MessagesLoaded copyWith({
    List<ChatMessageModel>? messages,
    bool? isSending,
    int? currentPage,
    bool? hasMoreMessages,
    bool? isLoadingMore,
    bool? isLoading,
  }) {
    return MessagesLoaded(
      messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      currentPage: currentPage ?? this.currentPage,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    isSending,
    currentPage,
    hasMoreMessages,
    isLoadingMore,
    isLoading,
  ];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
