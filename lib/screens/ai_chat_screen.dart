import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_background.dart';
import '../services/ai_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();

  final List<Message> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingAnimationController;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _loadConversation();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadConversation() async {
    await _aiService.loadConversation();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        Message(
          text:
              "السلام عليكم ورحمة الله وبركاته! 🌙\n\nأنا مساعدك الذكي المتخصص في الشؤون الإسلامية.\n\nيمكنني مساعدتك في:\n• البحث في القرآن والحديث\n• الإجابة عن أسئلة الفقه والعبادات\n• شرح الأحكام الشرعية\n• تقديم الأدعية والأذكار\n\nاسألني عن أي شيء! 💚",
          isUser: false,
          type: AIResponseType.unknown,
        ),
      );
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    final response = await _aiService.processQuery(text);

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(
        Message(
          text: response.text,
          isUser: false,
          results: response.results,
          type: response.type,
          suggestions: response.suggestions,
        ),
      );
    });
    _scrollToBottom();

    // حفظ المحادثة
    await _aiService.saveConversation();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleAction(String action, AIResultItem item) {
    switch (action) {
      case 'copy':
        Clipboard.setData(ClipboardData(text: item.content));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم النسخ ✓'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 'explain':
        _sendMessage('اشرح لي: ${item.content.substring(0, 50)}...');
        break;
      case 'tafsir':
        _sendMessage('فسر لي: ${item.meta}');
        break;
      case 'listen':
        // يمكن إضافة تشغيل الصوت هنا
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ميزة الاستماع قريباً إن شاء الله')),
        );
        break;
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح المحادثة'),
        content: const Text('هل تريد مسح جميع الرسائل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _aiService.clearHistory();
                _addWelcomeMessage();
              });
              Navigator.pop(context);
            },
            child: const Text('مسح', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "المساعد الذكي",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "متصل • جاهز للمساعدة",
                  style: GoogleFonts.cairo(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearChat,
            tooltip: 'مسح المحادثة',
          ),
        ],
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GlassBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _buildTypingIndicator(colorScheme);
                  }
                  final msg = _messages[index];
                  return _buildMessageBubble(msg, colorScheme);
                },
              ),
            ),

            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textDirection: TextDirection.rtl,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "اسأل عن آية، حديث، أو حكم شرعي...",
                        hintStyle: GoogleFonts.cairo(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.chat_bubble_outline,
                          color: colorScheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: () => _sendMessage(_controller.text),
                    mini: true,
                    elevation: 0,
                    backgroundColor: colorScheme.primary,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "جاري التفكير",
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _typingAnimationController,
                builder: (context, child) {
                  return Row(
                    children: List.generate(3, (index) {
                      final delay = index * 0.2;
                      final value =
                          (_typingAnimationController.value + delay) % 1.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(
                              alpha: 0.3 + (value * 0.7),
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message msg, ColorScheme colorScheme) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: isUser
                  ? LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    )
                  : null,
              color: isUser ? null : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 4 : 20),
                bottomRight: Radius.circular(isUser ? 20 : 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: GoogleFonts.cairo(
                    color: isUser ? Colors.white : colorScheme.onSurface,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),

                // Results
                if (msg.results != null && msg.results!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...msg.results!.map(
                    (item) => _buildResultCard(item, colorScheme),
                  ),
                ],
              ],
            ),
          ),

          // Suggestions
          if (msg.suggestions != null && msg.suggestions!.isNotEmpty)
            _buildSuggestions(msg.suggestions!, colorScheme),
        ],
      ),
    );
  }

  Widget _buildResultCard(AIResultItem item, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.content,
            style: GoogleFonts.amiri(
              fontSize: 17,
              height: 1.9,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.meta,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          if (item.actions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: item.actions.map((action) {
                return ActionChip(
                  label: Text(
                    action.label,
                    style: GoogleFonts.cairo(fontSize: 11),
                  ),
                  avatar: Icon(_getIconData(action.icon), size: 16),
                  onPressed: () => _handleAction(action.action, item),
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestions(List<String> suggestions, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.end,
        children: suggestions.map((suggestion) {
          return ActionChip(
            label: Text(suggestion, style: GoogleFonts.cairo(fontSize: 12)),
            avatar: Icon(
              Icons.lightbulb_outline,
              size: 14,
              color: colorScheme.primary,
            ),
            onPressed: () => _sendMessage(suggestion),
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'copy':
        return Icons.copy;
      case 'info':
        return Icons.info_outline;
      case 'book':
        return Icons.menu_book;
      case 'play':
        return Icons.play_circle_outline;
      default:
        return Icons.help_outline;
    }
  }
}

class Message {
  final String text;
  final bool isUser;
  final List<AIResultItem>? results;
  final AIResponseType? type;
  final List<String>? suggestions;

  Message({
    required this.text,
    required this.isUser,
    this.results,
    this.type,
    this.suggestions,
  });
}
