// lib/agents/agent_router.dart

enum AgentType { trainer, meal, vet }

class AgentRouter {
  /// Decide which agent should handle the message
  static AgentType route(String text) {
    final t = text.toLowerCase();

    // =========================
    // 1) VET FIRST (safety)
    // =========================
    const vetKeywords = [
      // Bloat / GI emergencies
      "retch", "retching", "dry heave", "dry-heave",
      "trying to vomit", "nothing comes out",
      "bloated", "bloat", "gdv",
      "swollen belly", "belly looks bigger", "distended",
      "abdomen", "stomach looks bigger",

      // Breathing / collapse / neurological
      "trouble breathing", "can’t breathe", "can't breathe",
      "panting heavily", "gasping",
      "collapse", "collapsed", "faint", "fainted",
      "seizure", "seizing",

      // Pain / injury
      "limp", "limping", "yelping", "pain", "hurt", "injury",
      "swelling", "fracture",

      // Illness
      "vomit", "vomiting", "diarrhea", "bloody", "blood in",
      "not eating", "refusing food",
      "lethargic", "weak", "fever",
      "infection", "ear infection",
      "rash", "itching", "hot spot",

      // Toxic ingestion
      "poison", "toxin", "chocolate", "xylitol",
      "grapes", "raisins", "rat poison",
    ];

    for (final k in vetKeywords) {
      if (t.contains(k)) return AgentType.vet;
    }

    // =========================
    // 2) MEAL
    // =========================
    const mealKeywords = [
      "food", "feed", "feeding", "diet",
      "kibble", "wet food", "raw",
      "calorie", "calories",
      "treat", "treats",
      "portion", "protein", "fat",
      "weight loss", "lose weight",
      "weight gain", "gain weight",
    ];

    for (final k in mealKeywords) {
      if (t.contains(k)) return AgentType.meal;
    }

    // =========================
    // 3) TRAINER (default)
    // =========================
    return AgentType.trainer;
  }

  /// Secondary urgency signal for UI highlighting
  static bool isUrgent(String text) {
    final t = text.toLowerCase();

    const urgentKeywords = [
      // Immediate emergencies
      "retch", "retching", "dry heave",
      "trying to vomit", "nothing comes out",
      "bloated", "bloat", "gdv",
      "swollen belly", "distended",
      "trouble breathing", "can’t breathe", "can't breathe",
      "collapse", "collapsed",
      "seizure", "seizing",

      // Poisoning
      "poison", "toxin", "chocolate",
      "xylitol", "grapes", "raisins",

      // Severe signs
      "uncontrolled bleeding",
      "blue gums", "pale gums",
      "sudden weakness",
    ];

    for (final k in urgentKeywords) {
      if (t.contains(k)) return true;
    }
    return false;
  }
}
