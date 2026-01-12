import 'package:flutter/material.dart';

import 'agents/agent_controller.dart';
import 'agents/openai_client.dart';
import 'secrets.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'pro_access.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _text = TextEditingController();
  bool _loading = false;

  // Simple chat history: user + assistant messages
  final List<Map<String, String>> _messages = [];

  late final AgentController _agent;

  // ===== Premium persistent memory config =====
  static const String _kPrefChatMessages = 'wf_pro_chat_messages_v1';
  static const int _kMaxStoredMessages = 50;

  @override
  void initState() {
    super.initState();
    _agent = AgentController(
      openAIClient: OpenAIClient(apiKey: openAIApiKey),
    );

    // Load saved chat ONLY if Pro is enabled
    _loadProMemoryIfEnabled();
  }

  // ===============================
  // Premium memory helpers
  // ===============================
  Future<void> _loadProMemoryIfEnabled() async {
    if (!ProAccess.isPro) return;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kPrefChatMessages);

    if (stored == null || stored.isEmpty) return;

    try {
      final decoded = jsonDecode(stored);
      if (decoded is List) {
        final restored = decoded
            .whereType<Map>()
            .map<Map<String, String>>(
              (m) => m.map(
                (k, v) => MapEntry(k.toString(), v.toString()),
              ),
            )
            .toList();

        if (!mounted) return;
        setState(() {
          _messages
            ..clear()
            ..addAll(restored);
        });
      }
    } catch (_) {
      // Ignore corrupted memory safely
    }
  }

  Future<void> _saveProMemoryIfEnabled() async {
    if (!ProAccess.isPro) return;

    final prefs = await SharedPreferences.getInstance();

    final trimmed = _messages.length <= _kMaxStoredMessages
        ? _messages
        : _messages.sublist(_messages.length - _kMaxStoredMessages);

    try {
      await prefs.setString(_kPrefChatMessages, jsonEncode(trimmed));
    } catch (_) {
      // Ignore write failures
    }
  }

  Future<void> _clearProMemory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefChatMessages);
  }

  // ===============================
  // Chat send logic
  // ===============================
  Future<void> _send() async {
    final msg = _text.text.trim();
    if (msg.isEmpty || _loading) return;

    setState(() {
      _loading = true;
      _messages.add({"role": "user", "text": msg});
      _text.clear();
    });

    // Await save so it finishes before app quits (important on desktop)
    await _saveProMemoryIfEnabled();

    try {
      final resp = await _agent.handleUserMessage(
        msg,
        history: _messages,
      );

      setState(() {
        final header =
            "${resp.agentLabel}${resp.isUrgent ? " (URGENT)" : ""}";
        _messages.add({
          "role": "assistant",
          "text": "$header\n\n${resp.text}",
        });
      });

      await _saveProMemoryIfEnabled();
    } catch (e) {
      setState(() {
        _messages.add({"role": "assistant", "text": "Error: $e"});
      });

      await _saveProMemoryIfEnabled();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WoofFit AI"),
        actions: [
          // Visible mode indicator
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                ProAccess.isPro ? "PRO" : "FREE",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Toggle Pro on/off (debug gate)
          IconButton(
            tooltip: ProAccess.isPro ? 'Pro ON' : 'Pro OFF',
            icon: Icon(
              ProAccess.isPro
                  ? Icons.workspace_premium
                  : Icons.lock_outline,
            ),
            onPressed: () async {
              setState(() {
                ProAccess.isPro = !ProAccess.isPro;
              });

              if (ProAccess.isPro) {
                await _loadProMemoryIfEnabled();
              }
            },
          ),

          // Force save (debug)
          IconButton(
            tooltip: 'Force save (debug)',
            icon: const Icon(Icons.save_outlined),
            onPressed: () async {
              await _saveProMemoryIfEnabled();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ProAccess.isPro
                        ? "Saved ${_messages.length} messages."
                        : "Pro is OFF — nothing saved.",
                  ),
                ),
              );
            },
          ),

          // Clear saved memory
          IconButton(
            tooltip: 'Clear saved memory',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await _clearProMemory();
              if (!mounted) return;
              setState(() {
                _messages.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Cleared saved memory.")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isUser = m["role"] == "user";
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(m["text"] ?? ""),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: "Ask about exercise, meals, or symptoms…",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _loading ? null : _send,
                  child: Text(_loading ? "..." : "Send"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
