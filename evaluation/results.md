PocketVet – AI Recommendation Evaluation Results (CTR)

Metric: Click-through rate (CTR) = clicks / impressions
Goal: Compare a static rule-based baseline against an adaptive personalized recommender in a pet-health application.

Results

Baseline (rule-based) CTR: 0.1200

Personalized (adaptive) CTR: 0.1025

The personalized recommender underperformed the static baseline.

Interpretation (Business Meaning)

In this experiment, AI-driven personalization did not increase engagement relative to a well-designed rule-based system. This suggests that in early-stage pet-health applications like PocketVet, personalization can introduce noise when user interaction data is limited, reducing recommendation effectiveness.

From a business perspective, this highlights that personalization is not automatically value-adding. Strong baselines may outperform adaptive systems during the cold-start phase, and premature personalization can negatively impact user trust and engagement.

Notes

Synthetic data was used to isolate the causal impact of personalization versus static rules in a controlled environment. Results reflect early-stage system behavior and are intended to inform product strategy rather than model optimization.