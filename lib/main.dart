import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'services/mock_chat_service.dart';

void main() => runApp(const ChatLabApp());

class ChatLabApp extends StatelessWidget {
  const ChatLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat — 실습 1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6FE4)),
        useMaterial3: true,
      ),
      home: const ChatPage(),
    );
  }
}

/// 대화 한 줄. 서버 없이 화면만 만들기 위한 최소 모델.
class ChatMessage {
  const ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.initialMessages = const [
    ChatMessage(text: '오늘 뭐 배워?', isUser: true),
    ChatMessage(text: 'AI 챗봇에 움직이는 응답을 붙입니다.', isUser: false),
    ChatMessage(text: '타이핑 점은 왜 필요해요?', isUser: true),
    ChatMessage(text: '응답이 1초를 넘으면 앱이 멈춘 것처럼 보이기 때문입니다.', isUser: false),
  ]});

  final List<ChatMessage> initialMessages;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final List<ChatMessage> _messages = List.of(widget.initialMessages);
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _chatService = MockChatService();
  Timer? _replyTimer;
  bool _isTyping = false;

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isTyping) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToLatest();
    _replyTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: _chatService.reply(text),
          isUser: false,
        ));
        _isTyping = false;
      });
      _scrollToLatest();
    });
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('AI Chat — 실습 1')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 40),
                            SizedBox(height: 16),
                            Text('무엇이든 물어보세요'),
                            SizedBox(height: 8),
                            Text('메시지를 보내 대화를 시작해 보세요.'),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isTyping && index == 0) {
                          return const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: TypingDots(),
                            ),
                          );
                        }
                        final messageIndex = index - (_isTyping ? 1 : 0);
                        return _Bubble(
                          message: _messages[_messages.length - 1 - messageIndex],
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        labelText: '메시지',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, child) => IconButton.filled(
                      tooltip: '메시지 전송',
                      onPressed: _isTyping || value.text.trim().isEmpty ? null : _send,
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: message.isUser ? colors.primaryContainer : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: message.isUser ? colors.onPrimaryContainer : colors.onSurface),
        ),
      ),
    );
  }
}

/// 응답 대기 중 세 점이 차례로 위아래로 움직인다.
class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.stop();
      _animation.value = 0;
    } else {
      _animation.repeat();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: 'AI가 응답을 작성하고 있습니다',
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final wave = math.sin((_animation.value * 2 * math.pi) - index * 0.8);
              return Transform.translate(
                offset: Offset(0, -4.0 * math.max(0.0, wave)),
                child: Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(color: colors.onSurfaceVariant, shape: BoxShape.circle),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
