// lib/agents/agent_controller.dart
import 'dart:convert';

import 'agent_router.dart';
import 'coach_memory.dart';
import 'meal_agent.dart';
import 'vet_agent.dart';
import 'openai_client.dart';
import 'prompts.dart';

class AgentResponse {
  final String agentLabel; // TRAINER / MEAL / VET
  final bool isUrgent;
  final String text; // displayable text
  final Map<String, dynamic>? json; // meal/vet structured output

  AgentResponse({
    required this.agentLabel,
    required this.isUrgent,
    required this.text,
    this.json,
  });
}

class AgentController {
  final OpenAIClient openAIClient;

  AgentController({required this.openAIClient});

  Future<AgentResponse> handleUserMessage(
    String userText, {
    required List<Map<String, String>> history,
    Map<String, dynamic>? petProfile,
    CoachMemory? coachMemory,
  }) async {
    final agentType = AgentRouter.route(userText);
    final urgentKeyword = AgentRouter.isUrgent(userText);

    // Build shared context once
    final profileBlock = _formatPetProfile(petProfile);
    final historyText = _buildHistoryText(history);

    // =========================
    // TRAINER (human readable)
    // =========================
    if (agentType == AgentType.trainer) {
      var systemPrompt = AgentPrompts.trainerSystem;
      if (profileBlock.isNotEmpty) {
        systemPrompt = "$systemPrompt\n\n$profileBlock";
      }

      final coachBlock =
          (coachMemory != null && coachMemory.hasSignal)
              ? "COACH MEMORY (use to adapt future plans):\n${coachMemory.summarize()}\n"
              : "";

      final prefix = [
        if (profileBlock.isNotEmpty) profileBlock,
        if (coachBlock.isNotEmpty) coachBlock,
      ].join("\n");

      final userPrompt = historyText.isEmpty
          ? "${prefix}New message:\n$userText"
          : "${prefix}Conversation so far:\n$historyText\n\nNew message:\n$userText";

      final raw = await openAIClient.generateText(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        maxOutputTokens: 800,
        temperature: 0.6,
      );

      return AgentResponse(
        agentLabel: "TRAINER",
        isUrgent: urgentKeyword,
        text: raw,
        json: null,
      );
    }

    // =========================
    // MEAL (STRICT JSON)
    // =========================
    if (agentType == AgentType.meal) {
      final petName = (petProfile?["name"] ?? "").toString().trim();
      final nameForPrompt = petName.isEmpty ? "your guinea pig" : petName;

      final systemPrompt = MealAgent.systemPrompt(petName: nameForPrompt);
      final userPrompt = MealAgent.userPrompt(
        userMessage: _wrapWithContext(userText, historyText, profileBlock),
        petProfile: petProfile,
      );

      final raw = await openAIClient.generateText(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        maxOutputTokens: 700,
        temperature: 0.2,
      );

      final parsed = _safeParseJson(raw);
      if (parsed == null) {
        return AgentResponse(
          agentLabel: "MEAL",
          isUrgent: urgentKeyword,
          text: raw,
          json: null,
        );
      }

      final display = _renderMealJson(parsed);
      final needsVet = parsed["needs_vet_triage"] == true;

      return AgentResponse(
        agentLabel: "MEAL",
        isUrgent: needsVet || urgentKeyword,
        text: display,
        json: parsed,
      );
    }

    // =========================
    // VET (STRICT JSON)
    // =========================
    final petName = (petProfile?["name"] ?? "").toString().trim();
    final nameForPrompt = petName.isEmpty ? "your guinea pig" : petName;

    final systemPrompt = VetAgent.systemPrompt(petName: nameForPrompt);
    final userPrompt = VetAgent.userPrompt(
      userMessage: _wrapWithContext(userText, historyText, profileBlock),
      petProfile: petProfile,
    );

    final raw = await openAIClient.generateText(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxOutputTokens: 750,
      temperature: 0.2,
    );

    final parsed = _safeParseJson(raw);
    if (parsed == null) {
      return AgentResponse(
        agentLabel: "VET",
        isUrgent: true,
        text: raw,
        json: null,
      );
    }

    final triage = (parsed["triage_level"] ?? "VET_SOON").toString().toUpperCase();
    final jsonUrgent = parsed["is_urgent"] == true;
    final isUrgent =
        jsonUrgent || triage == "EMERGENCY" || triage == "VET_SOON" || urgentKeyword;

    final display = _renderVetJson(parsed);

    return AgentResponse(
      agentLabel: "VET",
      isUrgent: isUrgent,
      text: display,
      json: parsed,
    );
  }

  // -------------------------
  // Helpers
  // -------------------------
  String _wrapWithContext(String userText, String historyText, String profileBlock) {
    final pieces = <String>[];
    if (profileBlock.isNotEmpty) pieces.add(profileBlock.trim());
    if (historyText.isNotEmpty) pieces.add("Conversation so far:\n$historyText");
    pieces.add("New message:\n$userText");
    return pieces.join("\n\n");
  }

  String _formatPetProfile(Map<String, dynamic>? petProfile) {
    if (petProfile == null || petProfile.isEmpty) return "";

    final species = (petProfile["species"] ?? "Guinea pig").toString();
    final name = (petProfile["name"] ?? "").toString();
    final age = (petProfile["age_months"] ?? "?").toString();
    final weight = (petProfile["weight_grams"] ?? "?").toString();
    final goal = (petProfile["goal"] ?? "general health").toString();
    final diet = (petProfile["diet"] ?? "").toString();
    final housing = (petProfile["housing"] ?? "").toString();

    return """
PET PROFILE (small mammal — use strictly):
Species: $species
Name: $name
Age (months): $age
Weight (grams): $weight
Goal: $goal
Diet: $diet
Housing: $housing
""";
  }

  String _buildHistoryText(List<Map<String, String>>? history, {int maxItems = 10}) {
    if (history == null || history.isEmpty) return "";
    final recent =
        history.length <= maxItems ? history : history.sublist(history.length - maxItems);

    final lines = <String>[];
    for (final m in recent) {
      final role = (m["role"] ?? "").toLowerCase() == "user" ? "User" : "Assistant";
      var text = (m["text"] ?? "").trim();
      if (text.isEmpty) continue;

      // Strip header lines like "TRAINER (URGENT)"
      if (role == "Assistant") {
        final parts = text.split("\n");
        if (parts.isNotEmpty) {
          final first = parts.first.toUpperCase();
          final looksLikeHeader =
              first.contains("TRAINER") || first.contains("MEAL") || first.contains("VET");
          if (looksLikeHeader) {
            text = parts.skip(1).join("\n").trim();
          }
        }
      }

      lines.add("$role: $text");
    }
    return lines.join("\n");
  }

  Map<String, dynamic>? _safeParseJson(String s) {
    try {
      var cleaned = s.trim();

      cleaned = cleaned
          .replaceAll(RegExp(r'^```json', multiLine: true), '')
          .replaceAll(RegExp(r'^```', multiLine: true), '')
          .replaceAll(RegExp(r'```$', multiLine: true), '')
          .trim();

      final firstBrace = cleaned.indexOf('{');
      final lastBrace = cleaned.lastIndexOf('}');
      if (firstBrace >= 0 && lastBrace > firstBrace) {
        cleaned = cleaned.substring(firstBrace, lastBrace + 1);
      }

      final obj = jsonDecode(cleaned);
      if (obj is Map<String, dynamic>) return obj;
      if (obj is Map) return obj.cast<String, dynamic>();
      return null;
    } catch (_) {
      return null;
    }
  }

  String _renderMealJson(Map<String, dynamic> j) {
    String list(String key) {
      final v = j[key];
      if (v is List) return v.map((e) => "- ${e.toString()}").join("\n");
      return "- (none)";
    }

    String portion(String k) {
      final v = (j["suggested_portion_ranges"] is Map)
          ? (j["suggested_portion_ranges"] as Map)[k]
          : null;
      if (v == null) return "—";
      return v.toString();
    }

    return [
      "Meal: ${j["meal_name"] ?? "Unknown"}",
      if (j["needs_vet_triage"] == true)
        "\n⚠️ This may need vet triage (possible GI stasis risk).",
      "\nDiet quality notes:\n${list("diet_quality_notes")}",
      "\nSafe core structure:\n${list("safe_core_structure")}",
      "\nSuggested portions (conservative):",
      "- Hay: ${portion("hay")}",
      "- Pellets: ${portion("pellets")}",
      "- Veggies: ${portion("veggies")}",
      "- Fruit treats: ${portion("fruit_treats")}",
      "\nVitamin C strategy:\n${list("vitamin_c_strategy")}",
      "\nUnsafe items detected:\n${list("unsafe_items_detected")}",
      "\nSafer alternatives:\n${list("safer_alternatives")}",
      "\nUrgent actions:\n${list("urgent_actions")}",
      "\nQuestions:\n${list("questions")}",
    ].join("\n");
  }

  String _renderVetJson(Map<String, dynamic> j) {
    String list(String key) {
      final v = j[key];
      if (v is List) return v.map((e) => "- ${e.toString()}").join("\n");
      return "- (none)";
    }

    return [
      "Triage: ${j["triage_level"] ?? "VET_SOON"}",
      "\nRed flags:\n${list("red_flags_detected")}",
      "\nLikely categories:\n${list("likely_categories")}",
      "\nNext steps:\n${list("next_steps")}",
      "\nQuestions to ask:\n${list("questions_to_ask")}",
      "\n${(j["disclaimer"] ?? "").toString()}",
    ].join("\n");
  }
}
