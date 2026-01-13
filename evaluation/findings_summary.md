PocketVet – AI Recommendation Evaluation (Findings Summary)
Research Question

Does AI-driven personalization increase user engagement compared to static, rule-based recommendations in a consumer pet-health application?

Method

I compared a static rule-based recommendation system to an adaptive personalized agent within PocketVet, a pet-health support platform.
The evaluation was conducted in a controlled simulation using synthetic pet-owner profiles. Engagement was measured using click-through rate (CTR).

Results

Baseline (rule-based) CTR: 0.1200

Personalized (adaptive) CTR: 0.1025

The personalized agent underperformed the static baseline.

Interpretation

The results indicate that early-stage personalization can negatively impact engagement when user data is sparse. Although adaptive systems respond to user behavior, limited interaction history can introduce noise and reduce recommendation quality compared to a well-designed rule-based approach.

Business Implications

This experiment highlights an important product insight for early-stage digital health tools like PocketVet:
personalization is not automatically value-adding. Strong baselines are essential, and AI-driven personalization should be introduced gradually or hybridized to avoid harming user trust and engagement during the cold-start phase.

Next Steps

Future iterations could explore hybrid recommendation strategies, explicit cold-start handling, or delayed personalization thresholds to improve performance as user data accumulates.