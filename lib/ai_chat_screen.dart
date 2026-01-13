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

  // ===== Premium dog profile (local-only) =====
  static const String _kPrefDogProfile = 'wf_pro_dog_profile_v1';

  // Default profile (used if nothing saved yet)
  Map<String, dynamic> dogProfile = {
    "name": "",
    "breed": "Husky",
    "age_years": 3,
    "weight_lbs": 45,
    "goal": "general health",
  };

  @override
  void initState() {
    super.initState();
    _agent = AgentController(
      openAIClient: OpenAIClient(apiKey: openAIApiKey),
    );

    _loadProMemoryIfEnabled();
    _loadDogProfileIfEnabled();
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
              (m) => m.map((k, v) => MapEntry(k.toString(), v.toString())),
            )
            .toList();

        if (!mounted) return;
        setState(() {
          _messages
            ..clear()
            ..addAll(restored);
        });
      }
    } catch (_) {}
  }

  Future<void> _saveProMemoryIfEnabled() async {
    if (!ProAccess.isPro) return;

    final prefs = await SharedPreferences.getInstance();
    final trimmed = _messages.length <= _kMaxStoredMessages
        ? _messages
        : _messages.sublist(_messages.length - _kMaxStoredMessages);

    try {
      await prefs.setString(_kPrefChatMessages, jsonEncode(trimmed));
    } catch (_) {}
  }

  Future<void> _clearProMemory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefChatMessages);
  }

  // ===============================
  // Premium dog profile helpers
  // ===============================
  Future<void> _loadDogProfileIfEnabled() async {
    if (!ProAccess.isPro) return;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kPrefDogProfile);
    if (stored == null || stored.isEmpty) return;

    try {
      final decoded = jsonDecode(stored);
      if (decoded is Map) {
        if (!mounted) return;
        setState(() {
          dogProfile = decoded.cast<String, dynamic>();
        });
      }
    } catch (_) {}
  }

  Future<void> _saveDogProfileIfEnabled() async {
    if (!ProAccess.isPro) return;

    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString(_kPrefDogProfile, jsonEncode(dogProfile));
    } catch (_) {}
  }

  Future<void> _clearDogProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefDogProfile);
  }

  // ===============================
  // Dog profile UI (simple dialog)
  // ===============================
  Future<void> _editDogProfileDialog() async {
    if (!ProAccess.isPro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dog Profile is a Pro feature (for now).")),
      );
      return;
    }

    final nameCtrl = TextEditingController(text: (dogProfile["name"] ?? "").toString());
    final breedCtrl = TextEditingController(text: (dogProfile["breed"] ?? "").toString());
    final ageCtrl = TextEditingController(text: (dogProfile["age_years"] ?? "").toString());
    final weightCtrl = TextEditingController(text: (dogProfile["weight_lbs"] ?? "").toString());
    final goalCtrl = TextEditingController(text: (dogProfile["goal"] ?? "").toString());

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Edit Dog Profile (Pro)"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name (optional)"),
                ),
                TextField(
                  controller: breedCtrl,
                  decoration: const InputDecoration(labelText: "Breed"),
                ),
                TextField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Age (years)"),
                ),
                TextField(
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Weight (lbs)"),
                ),
                TextField(
                  controller: goalCtrl,
                  decoration: const InputDecoration(labelText: "Goal (e.g., leaner, endurance)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      // Parse numbers safely
      final age = int.tryParse(ageCtrl.text.trim());
      final weight = int.tryParse(weightCtrl.text.trim());

      setState(() {
        dogProfile = {
          "name": nameCtrl.text.trim(),
          "breed": breedCtrl.text.trim().isEmpty ? "Unknown" : breedCtrl.text.trim(),
          "age_years": age ?? dogProfile["age_years"] ?? 0,
          "weight_lbs": weight ?? dogProfile["weight_lbs"] ?? 0,
          "goal": goalCtrl.text.trim().isEmpty ? "general health" : goalCtrl.text.trim(),
        };
      });

      await _saveDogProfileIfEnabled();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved dog profile (Pro).")),
      );
    }
  }

  String _profileSummary() {
    final name = (dogProfile["name"] ?? "").toString().trim();
    final breed = (dogProfile["breed"] ?? "Unknown").toString();
    final age = (dogProfile["age_years"] ?? "?").toString();
    final w = (dogProfile["weight_lbs"] ?? "?").toString();
    final goal = (dogProfile["goal"] ?? "general health").toString();
    final n = name.isEmpty ? "" : "$name • ";
    return "${n}${breed}, ${age}y, ${w}lb • Goal: $goal";
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

    await _saveProMemoryIfEnabled();

    try {
      // If your AgentController supports dogProfile, use it.
      // If it does NOT, the fallback still works and we can wire it next.
      final resp = await _agent.handleUserMessage(
        msg,
        history: _messages,
        dogProfile: dogProfile, // <-- If this errors, tell me; we'll adapt.
      );

      setState(() {
        final header = "${resp.agentLabel}${resp.isUrgent ? " (URGENT)" : ""}";
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
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                ProAccess.isPro ? "PRO" : "FREE",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            tooltip: "Edit Dog Profile",
            icon: const Icon(Icons.pets_outlined),
            onPressed: _editDogProfileDialog,
          ),
          IconButton(
            tooltip: ProAccess.isPro ? 'Pro ON' : 'Pro OFF',
            icon: Icon(
              ProAccess.isPro ? Icons.workspace_premium : Icons.lock_outline,
            ),
            onPressed: () async {
              setState(() {
                ProAccess.isPro = !ProAccess.isPro;
              });

              if (ProAccess.isPro) {
                await _loadProMemoryIfEnabled();
                await _loadDogProfileIfEnabled();
              }
            },
          ),
          IconButton(
            tooltip: 'Force save (debug)',
            icon: const Icon(Icons.save_outlined),
            onPressed: () async {
              await _saveProMemoryIfEnabled();
              await _saveDogProfileIfEnabled();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ProAccess.isPro
                        ? "Saved ${_messages.length} msgs + profile."
                        : "Pro is OFF — nothing saved.",
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Clear saved memory',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await _clearProMemory();
              await _clearDogProfile();
              if (!mounted) return;
              setState(() {
                _messages.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Cleared saved memory + profile.")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Small profile banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Text(
              ProAccess.isPro
                  ? "Dog Profile (Pro): ${_profileSummary()}"
                  : "Dog Profile: (Pro feature — toggle PRO to persist profile)",
              style: const TextStyle(fontSize: 13),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isUser = m["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
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

