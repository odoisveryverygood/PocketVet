// lib/agents/agent_router.dart

enum AgentType { trainer, meal, vet }

class AgentRouter {
  /// Decide which agent should handle the message
  static AgentType route(String text) {
    final t = text.toLowerCase();

    // =========================
    // 1) VET FIRST (safety)
    // =========================
    // Small mammals (guinea pigs first) hide illness. Appetite/poop changes are time-sensitive.
    const vetKeywords = [
      // Appetite / GI red flags (high-signal)
      "not eating", "won't eat", "wont eat", "refusing food", "stopped eating",
      "not drinking", "won't drink", "wont drink",
      "not pooping", "no poop", "no poops", "not pooing", "no droppings",
      "tiny poop", "tiny poops", "small poop", "small poops",
      "diarrhea", "runny poop", "watery poop", "soft stool",
      "constipation",
      "bloated", "bloat", "swollen belly", "distended",
      "gas", "gassy", "hard belly", "belly hard",
      "hunched", "hunched over",
      "teeth grinding", "tooth grinding",

      // Breathing / collapse / neuro (high-signal)
      "trouble breathing", "can't breathe", "cant breathe",
      "open mouth breathing", "open-mouth breathing",
      "gasping", "wheezing",
      "collapse", "collapsed", "faint", "fainted",
      "seizure", "seizing", "tremor", "tremors",
      "unresponsive",

      // Pain / injury
      "limp", "limping", "pain", "hurt", "injury",
      "won't move", "wont move", "dragging",
      "swelling", "fracture",

      // Dental / mouth issues (make it specific, not just "teeth")
      "drooling", "slobber", "wet chin",
      "overgrown incisors", "malocclusion",
      "dropping food", "can't chew", "cant chew",
      "choking", "gagging",

      // Skin / parasites / infections
      "mites", "lice", "bald spot", "hair loss",
      "itching", "scratching", "scabs", "crusty",
      "rash", "wound", "abscess",
      "eye discharge", "crusty eye", "red eye",
      "nose discharge", "snot", "sneezing",

      // Blood / urinary
      "blood", "bleeding", "bloody",
      "blood in urine", "bloody urine",
      "can't pee", "cant pee", "not peeing",
      "painful urination",

      // Toxins / dangerous exposures (remove noisy "ate")
      "poison", "toxin", "toxic", "ingested",
      "cleaner", "bleach", "essential oil",
      "insecticide", "pesticide",
      "human medicine", "ibuprofen", "acetaminophen", "tylenol",
      "chocolate", "xylitol",
    ];

    for (final k in vetKeywords) {
      if (t.contains(k)) return AgentType.vet;
    }

    // =========================
    // 2) MEAL / NUTRITION
    // =========================
    const mealKeywords = [
      "food", "feed", "feeding", "diet",
      "hay", "timothy", "orchard", "meadow hay", "alfalfa",
      "pellets", "pellet",
      "vitamin c", "ascorbic",
      "veggies", "vegetables", "greens",
      "lettuce", "cilantro", "parsley", "bell pepper",
      "fruit", "treat", "treats",
      "portion", "how much", "grams",
      "weight loss", "lose weight",
      "weight gain", "gain weight",
      "water", "bottle", "bowl",
    ];

    for (final k in mealKeywords) {
      if (t.contains(k)) return AgentType.meal;
    }

    // =========================
    // 3) TRAINER / CARE ROUTINE (default)
    // =========================
    // Enrichment, bonding, behavior, habitat routines
    return AgentType.trainer;
  }

  /// Secondary urgency signal for UI highlighting
  static bool isUrgent(String text) {
    final t = text.toLowerCase();

    // Emergency patterns that should "light up" the UI
    const urgentKeywords = [
      // GI / appetite emergencies
      "not eating", "won't eat", "wont eat", "stopped eating",
      "not pooping", "no poop", "no droppings",
      "bloated", "bloat", "distended", "swollen belly", "hard belly",
      "severe diarrhea", "watery poop",
      "unresponsive",

      // Breathing / collapse / neuro
      "trouble breathing", "can't breathe", "cant breathe",
      "open mouth breathing", "gasping",
      "collapse", "collapsed",
      "seizure", "seizing",

      // Blood / critical
      "uncontrolled bleeding",
      "blood in urine", "bloody urine",

      // Poison / toxins
      "poison", "toxin", "toxic",
      "bleach", "cleaner", "essential oil",
      "ibuprofen", "acetaminophen", "tylenol",
      "xylitol",
    ];

    for (final k in urgentKeywords) {
      if (t.contains(k)) return true;
    }

    // Extra high-signal combo: not eating + (not pooping OR hunched OR teeth grinding)
    final notEating = t.contains("not eating") || t.contains("won't eat") || t.contains("wont eat") || t.contains("stopped eating");
    final poopOrPain = t.contains("not pooping") || t.contains("no poop") || t.contains("no droppings") || t.contains("hunched") || t.contains("teeth grinding") || t.contains("tooth grinding");
    if (notEating && poopOrPain) return true;

    return false;
  }
}
