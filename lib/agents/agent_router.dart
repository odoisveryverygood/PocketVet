// lib/agents/agent_router.dart
enum AgentType { trainer, meal, vet }

class AgentRouter {
  static AgentType route(String userText) {
    final t = userText.toLowerCase();

    // medical / symptom keywords
    const vetWords = [
      'bleed', 'bleeding', 'vomit', 'vomiting', 'diarrhea', 'seizure', 'collapsed',
      'collapse', 'bloat', 'gagging', 'choking', 'can’t breathe', 'cant breathe',
      'trouble breathing', 'poison', 'toxin', 'ate chocolate', 'ate grapes',
      'pale gums', 'limping', 'swollen', 'swelling', 'eye discharge', 'infection',
      'blood', 'wound', 'injury', 'pain'
    ];

    // meal / nutrition keywords
    const mealWords = [
      'food', 'feed', 'feeding', 'portion', 'calories', 'kibble', 'treats',
      'weight', 'overweight', 'underweight', 'diet', 'protein', 'carbs', 'hydration',
      'water'
    ];

    if (vetWords.any(t.contains)) return AgentType.vet;
    if (mealWords.any(t.contains)) return AgentType.meal;
    return AgentType.trainer;
  }

  static bool isUrgent(String userText) {
    final t = userText.toLowerCase();
    const urgent = [
      'seizure', 'collapsed', 'collapse', 'can’t breathe', 'cant breathe',
      'trouble breathing', 'bloat', 'bloated', 'poison', 'toxin', 'choking',
      'unresponsive', 'heavy bleeding', 'bleeding a lot', 'pale gums'
    ];
    return urgent.any(t.contains);
  }
}
