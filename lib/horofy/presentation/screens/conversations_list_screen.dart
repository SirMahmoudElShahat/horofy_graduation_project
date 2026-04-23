import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:horofy/core/constants/levels.dart';
import 'package:horofy/core/constants/strings.dart';
import 'package:horofy/core/style/app_colors.dart';
import 'package:horofy/core/style/font_style.dart';
import 'package:horofy/core/widgets/loading_widget.dart';
import 'package:horofy/horofy/data/datasources/chat_remote_datasource.dart';
import 'package:horofy/horofy/domain/entities/child_entity.dart';
import 'package:horofy/horofy/presentation/cubit/chat_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/chat_state.dart';
import 'package:horofy/horofy/presentation/cubit/child_cubit.dart';
import 'package:horofy/horofy/presentation/cubit/child_state.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadConversations();
    context.read<ChildCubit>().loadChildren();
  }

  // ── Open existing conversation ────────────────────────────
  void _onOpenConversation(ChatConversationModel conv) {
    Navigator.pushNamed(
      context,
      chatScreen,
      arguments: conv,
    ).then((_) => context.read<ChatCubit>().loadConversations());
  }

  // ── Select Child → show dialog to pick a child ────────────────────
  void _onSelectChild() {
    final children = _getChildrenFromState();

    if (children.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'لا توجد أطفال',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'يجب أن تضيف طفل أولاً قبل بدء محادثة',
            style: TextStyle(color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBF8FFE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'حسناً',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, childInformationScreen);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'إضافة طفل',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      return;
    }

    // Show bottom sheet with children list
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// عنوان النافذة
                Text(
                  'اختر الطفل',
                  style: AppTextStyles.blackFont.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
            
                const SizedBox(height: 20),
            
                /// قائمة الأطفال
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: children.length,
                  itemBuilder: (_, i) {
                    final child = children[i];
            
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.pop(context);
                        _onNewConversation(child.id ?? 0);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
            
                        child: Row(
                          children: [
                            /// السهم (يسار)
                            const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.primary,
                              size: 20,
                            ),
            
                            const SizedBox(width: 14),
            
                            /// النصوص
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    child.name,
                                    textAlign: TextAlign.right,
                                    style: AppTextStyles.blackFont.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    levelEnToArabic(child.level),
                                    textAlign: TextAlign.right,
                                    style: AppTextStyles.greyFont.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
            
                            const SizedBox(width: 14),
            
                            /// الصورة الشخصية (يمين)
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(child.avatar),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Find child by ID from ChildCubit state ─────────────
  ChildEntity? _findChildById(ChildState childState, int? childId) {
    if (childId == null) return null;
    if (childState is ChildLoaded) {
      for (final child in childState.children) {
        if (child.id == childId) return child;
      }
    }
    return null;
  }

  // ── Get children from ChildCubit state ──────────────────
  List<ChildEntity> _getChildrenFromState() {
    final childState = context.read<ChildCubit>().state;
    if (childState is ChildLoaded) {
      return childState.children;
    }
    return [];
  }

  // ── New conversation with child ID ─────────────────────
  void _onNewConversation(int childId) {
    Navigator.pushNamed(
      context,
      chatScreen,
      arguments: {'childId': childId},
    ).then((_) => context.read<ChatCubit>().loadConversations());
  }

  // ── Delete with confirm dialog ────────────────────────────
  void _onDelete(ChatConversationModel conv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'حذف المحادثة',
          style: TextStyle(
            color: Color(0xFFE57373),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'هل أنت متأكد من حذف "${conv.title}"؟',
          style: const TextStyle(color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBF8FFE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<ChatCubit>().deleteConversation(conv.id);
                  Get.snackbar(
                    'تم',
                    'تم حذف المحادثة',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.9),
                    colorText: Colors.white,
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    duration: const Duration(seconds: 2),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE57373),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'حذف',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Format date ───────────────────────────────────────────
  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ══════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'محادثات شلبى',
          style: AppTextStyles.blackFont.copyWith(fontSize: 22),
        ),
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
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _onSelectChild,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            Get.snackbar(
              'خطأ',
              state.message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent.withOpacity(0.9),
              colorText: Colors.white,
              icon: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ChatLoading)
            return const LoadingWidget(fullScreen: true);

          if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) return _buildEmpty();
            final childState = context.watch<ChildCubit>().state;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: state.conversations.length,
              itemBuilder: (_, i) {
                final conv = state.conversations[i];
                final child = _findChildById(childState, conv.childId);
                return _buildConversationCard(conv, child);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/chat_image.png',
            height: 160,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.chat_bubble_outline,
              size: 100,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'مافيش محادثات لحد دلوقتى',
            style: AppTextStyles.blackFont.copyWith(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'ابدأ محادثة جديدة مع شلبى 👇',
            style: AppTextStyles.greyFont.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Conversation card ─────────────────────────────────────
  Widget _buildConversationCard(
    ChatConversationModel conv,
    ChildEntity? child,
  ) {
    final hasLastMessage =
        conv.lastMessage != null && conv.lastMessage!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _onOpenConversation(conv),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromRGBO(99, 208, 201, 0.32),
                              Color.fromRGBO(99, 208, 201, 0.16),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Image(
                            image: AssetImage('assets/images/shalby_image.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conv.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.blackFont.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(conv.createdAt),
                              style: AppTextStyles.greyFont.copyWith(
                                fontSize: 12,
                                color: AppColors.primary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _onDelete(conv),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE57373).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFE57373),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (child != null) ...[
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage(child.avatar),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${child.name} - ${levelEnToArabic(child.level)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.blackFont.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else if (conv.childId != null) ...[
                          Text(
                            '\u0631\u0642\u0645 \u0627\u0644\u0637\u0641\u0644: ${conv.childId}',
                            style: AppTextStyles.blackFont.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (child != null || conv.childId != null)
                          const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                hasLastMessage
                                    ? Icons.chat_bubble_outline_rounded
                                    : Icons.mark_chat_unread_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                hasLastMessage
                                    ? conv.lastMessage!
                                    : '\u0644\u0627 \u062a\u0648\u062c\u062f \u0631\u0633\u0627\u0626\u0644 \u0628\u0639\u062f',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.greyFont.copyWith(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: hasLastMessage
                                      ? Colors.black87
                                      : Colors.black45,
                                  fontStyle: hasLastMessage
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
