// lib/agents/agent_controller.dart
import 'dart:convert';

import 'agent_router.dart';
import 'openai_client.dart';
import 'prompts.dart';

class AgentResponse {
  final String agentLabel; // "TRAINER" / "MEAL" / "VET"
  final bool isUrgent;
  final String text; // displayable text
  final Map<String, dynamic>? vetJson; // only for vet

  AgentResponse({
    required this.agentLabel,
    required this.isUrgent,
    required this.text,
    this.vetJson,
  });
}

class AgentController {
  final OpenAIClient openAIClient;

  AgentController({required this.openAIClient});

  /// Pass `history` from your UI (_messages) so the model can remember context.
  /// history format expected: [{"role":"user|assistant","text":"..."}]
  Future<AgentResponse> handleUserMessage(
    String userText, {
    List<Map<String, String>>? history,
  }) async {
    final agentType = AgentRouter.route(userText);
    final urgentKeyword = AgentRouter.isUrgent(userText);

    late final String systemPrompt;
    late final String label;

    switch (agentType) {
      case AgentType.vet:
        systemPrompt = AgentPrompts.vetSystem;
        label = "VET";
        break;
      case AgentType.meal:
        systemPrompt = AgentPrompts.mealSystem;
        label = "MEAL";
        break;
      case AgentType.trainer:
      default:
        systemPrompt = AgentPrompts.trainerSystem;
        label = "TRAINER";
        break;
    }

    final historyText = _buildHistoryText(history);
    final augmentedUserPrompt = historyText.isEmpty
        ? userText
        : "Conversation so far:\n$historyText\n\nNew message:\n$userText";

    final raw = await openAIClient.generateText(
      systemPrompt: systemPrompt,
      userPrompt: augmentedUserPrompt,
      maxOutputTokens: agentType == AgentType.vet ? 900 : 700,
      temperature: agentType == AgentType.vet ? 0.2 : 0.6,
    );

    if (agentType == AgentType.vet) {
      final parsed = _safeParseJson(raw);
      if (parsed != null) {
        final display = _renderVet(parsed);
        final urgency = (parsed["urgency"] ?? "").toString().toUpperCase();
        final isUrgent = urgency == "HIGH" || urgentKeyword;

        return AgentResponse(
          agentLabel: label,
          isUrgent: isUrgent,
          text: display,
          vetJson: parsed,
        );
      } else {
        // fallback if model returns non-JSON
        return AgentResponse(
          agentLabel: label,
          isUrgent: urgentKeyword,
          text: raw,
          vetJson: null,
        );
      }
    }

    return AgentResponse(
      agentLabel: label,
      isUrgent: urgentKeyword,
      text: raw,
      vetJson: null,
    );
  }

  /// Keep it cheap: only send a short rolling window of chat.
  /// We also strip any "header" lines like "TRAINER (URGENT)\n\n..." that you may prepend in UI.
  String _buildHistoryText(List<Map<String, String>>? history, {int maxItems = 10}) {
    if (history == null || history.isEmpty) return "";

    final recent = history.length <= maxItems ? history : history.sublist(history.length - maxItems);
    final lines = <String>[];

    for (final m in recent) {
      final roleRaw = (m["role"] ?? "").toLowerCase();
      final role = roleRaw == "user" ? "User" : "Assistant";
      var text = (m["text"] ?? "").trim();
      if (text.isEmpty) continue;

      // If your UI prefixes assistant messages with "TRAINER (URGENT)\n\n...",
      // remove the first line so it doesn't confuse the model.
      if (role == "Assistant") {
        final parts = text.split("\n");
        if (parts.isNotEmpty && parts.first.toUpperCase().contains("TRAINER") ||
            parts.first.toUpperCase().contains("MEAL") ||
            parts.first.toUpperCase().contains("VET")) {
          text = parts.skip(1).join("\n").trim();
          if (text.startsWith("\n")) text = text.trim();
        }
      }

      // Keep each line compact
      lines.add("$role: $text");
    }

    return lines.join("\n");
  }

  Map<String, dynamic>? _safeParseJson(String s) {
    try {
      final cleaned = s
          .trim()
          .replaceAll(RegExp(r'^```json'), '')
          .replaceAll(RegExp(r'^```'), '')
          .replaceAll(RegExp(r'```$'), '')
          .trim();
      final obj = jsonDecode(cleaned);
      if (obj is Map<String, dynamic>) return obj;
      return null;
    } catch (_) {
      return null;
    }
  }

  String _renderVet(Map<String, dynamic> j) {
    String list(String key) {
      final v = j[key];
      if (v is List) {
        return v.map((e) => "- ${e.toString()}").join("\n");
      }
      return "- (none)";
    }

    return [
      "## Urgency: ${j["urgency"] ?? "UNKNOWN"}",
      "",
      "## Summary",
      (j["summary"] ?? "").toString(),
      "",
      "## What this could be",
      list("what_this_could_be"),
      "",
      "## Do now",
      list("do_now"),
      "",
      "## Go to ER if",
      list("go_to_er_if"),
      "",
      "## Questions",
      list("questions"),
      "",
      "## What not to do",
      list("what_not_to_do"),
      "",
      "_${(j["disclaimer"] ?? "").toString()}_",
    ].join("\n");
  }
}
