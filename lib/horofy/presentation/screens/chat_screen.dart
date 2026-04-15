import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:horofy/core/helper/orientation_helper.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/core/widgets/loading_widget.dart';
import 'package:horofy/horofy/data/datasources/chat_remote_datasource.dart';
import 'package:horofy/horofy/presentation/cubit/chat_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/chat_state.dart';
import 'package:horofy/horofy/presentation/widgets/message_bubble.dart.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatConversationModel? _conversation;
  bool _isNewMode = false;
  int? _childId;
  bool _shouldScrollToBottom = false;
  bool _shouldScrollAfterSend = false;

  @override
  void initState() {
    super.initState();
    OrientationHelper.portrait();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is ChatConversationModel) {
      if (_conversation == null) {
        _conversation = arg;
        _shouldScrollToBottom = true;
        context.read<ChatCubit>().loadMessages(_conversation!.id);
      }
    } else if (arg is Map<String, dynamic> && arg.containsKey('childId')) {
      _isNewMode = true;
      _childId = arg['childId'] is int
          ? arg['childId'] as int
          : int.tryParse(arg['childId'].toString());
    } else {
      _isNewMode = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0); // since reverse: true, 0 is bottom
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {});

    if (_isNewMode && _conversation == null) {
      if (_childId == null) {
        Get.snackbar(
          'خطأ',
          'لم يتم تحديد الطفل لبدء المحادثة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          colorText: Colors.white,
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        );
        return;
      }
      final conv = await context.read<ChatCubit>().createAndLoadFirstMessage(
        firstMessage: text,
        childId: _childId!,
      );
      if (!mounted) return;
      if (conv != null) {
        setState(() {
          _conversation = conv;
          _isNewMode = false;
        });
        _scrollToBottom();
      }
    } else if (_conversation != null) {
      _shouldScrollAfterSend = true;
      await context.read<ChatCubit>().sendMessage(
        conversationId: _conversation!.id,
        content: text,
      );
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: _conversation != null
            ? Text(
                _conversation!.title,
                style: AppTextStyles.blackFont.copyWith(fontSize: 16),
              )
            : null,
        centerTitle: true,
        actions: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(99, 208, 201, 0.28),
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/shalby_image.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state is ChatError) {
          Get.snackbar(
            'خطأ',
            state.message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent.withOpacity(0.9),
            colorText: Colors.white,
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          );
        }
        if (state is MessagesLoaded &&
            !state.isLoadingMore &&
            !state.isLoading &&
            (_shouldScrollToBottom || _shouldScrollAfterSend)) {
          _shouldScrollToBottom = false;
          _shouldScrollAfterSend = false;
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        if (state is ChatLoading) {
          return const LoadingWidget();
        }
        if (state is MessagesLoaded) {
          if (state.isLoading) {
            return const LoadingWidget();
          }
          if (state.messages.isEmpty && _isNewMode && _conversation == null) {
            return _buildWelcome();
          }
          return Column(
            children: [
              // مؤشر تحميل "تحميل رسائل أقدم"
              if (state.isLoadingMore)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'جاري تحميل رسائل أقدم...',
                          style: AppTextStyles.blackFont.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    // إذا وصل لأعلى القائمة (نهاية القائمة بسبب reverse) وفي رسايل أكتر، حمّل المزيد
                    if (scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 100 &&
                        _conversation != null) {
                      final state = context.read<ChatCubit>().state;
                      if (state is MessagesLoaded &&
                          !state.isLoadingMore &&
                          state.hasMoreMessages) {
                        context.read<ChatCubit>().loadMoreMessages(
                          _conversation!.id,
                        );
                      }
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true, // newest at bottom
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    itemCount:
                        state.messages.length + (state.isSending ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (state.isSending && i == 0) {
                        return _buildTypingMessage();
                      }

                      final msg = state.messages[state.isSending ? i - 1 : i];
                      return MessageBubble(
                        text: msg.content,
                        isMe: msg.isFromUser,
                        hasButton: false,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
        return _buildWelcome();
      },
    );
  }

  Widget _buildWelcome() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'مرحبًا أنا شلبى كيف يمكنني مساعدتك اليوم؟',
                style: AppTextStyles.blackFont.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Image.asset('assets/images/chat_image.png', height: 350),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final state = context.watch<ChatCubit>().state;
    final isSending = state is MessagesLoaded && state.isSending;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textDirection: TextDirection.rtl,
              enabled: !isSending,
              decoration: InputDecoration(
                hintTextDirection: TextDirection.rtl,
                hintStyle: const TextStyle(color: Colors.grey),
                hintText: 'ﺇسأل شلبى الشاطر',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black, size: 20),
              onPressed: (_controller.text.trim().isEmpty || isSending)
                  ? null
                  : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const _TypingIndicator(),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            var t = (_controller.value - delay) % 1.0;
            if (t < 0) t += 1.0;
            double yOffset = 0;
            if (t < 0.2) {
              yOffset = -5 * (t / 0.2);
            } else if (t < 0.4) {
              yOffset = -5 * (1 - ((t - 0.2) / 0.2));
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Transform.translate(
                offset: Offset(0, yOffset),
                child: const CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.white,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
