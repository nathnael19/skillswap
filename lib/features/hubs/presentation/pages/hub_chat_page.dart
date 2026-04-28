import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillswap/core/layout/responsive.dart';
import 'package:skillswap/core/theme/theme.dart';
import 'package:skillswap/features/hubs/data/models/hub_message_model.dart';
import 'package:skillswap/features/hubs/data/services/hub_backend_service.dart';
import 'package:skillswap/init_dependencies.dart';

class HubChatPage extends StatefulWidget {
  final String hubId;
  final String hubName;

  const HubChatPage({super.key, required this.hubId, required this.hubName});

  @override
  State<HubChatPage> createState() => _HubChatPageState();
}

class _HubChatPageState extends State<HubChatPage> {
  final HubBackendService _service = serviceLocator<HubBackendService>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _poller;
  bool _loading = true;
  List<HubMessage> _messages = const [];
  String? _error;
  bool _requestInFlight = false;

  @override
  void initState() {
    super.initState();
    _load();
    _poller = Timer.periodic(const Duration(seconds: 3), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _poller?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false, bool force = false}) async {
    if (_requestInFlight && !force) return;
    _requestInFlight = true;
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await _service.getMessages(widget.hubId);
      if (!mounted) return;
      setState(() {
        _messages = data;
        _loading = false;
        _error = null;
      });
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    } finally {
      _requestInFlight = false;
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    try {
      await _service.sendMessage(widget.hubId, text);
      await _load(silent: true, force: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: Text(widget.hubName)),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.error)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(Responsive.contentHorizontalPadding(context) * 0.5 + 4),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final mine = message.senderId == myUid;
                          return Align(
                            alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              constraints: BoxConstraints(
                                maxWidth: (MediaQuery.sizeOf(context).width * 0.76)
                                    .clamp(0.0, 560.0),
                              ),
                              decoration: BoxDecoration(
                                color: mine ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                message.text,
                                style: TextStyle(color: mine ? Colors.white : AppColors.textPrimary),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask a quick question...',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
