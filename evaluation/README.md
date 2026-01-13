PocketVet — Evaluating Personalization vs. Rule-Based Care Recommendations
Research Question

Does lightweight, agent-level personalization meaningfully improve user engagement compared to static, rule-based recommendations in a consumer animal-health application?

This evaluation tests whether adaptive agent behavior—without model training or fine-tuning— can deliver measurable engagement gains over a strong rule-based baseline.

Why This Matters (Product & Business Perspective)

In consumer subscription products—especially health-adjacent tools—engagement is a leading indicator of:

Retention and habit formation

User trust and perceived reliability

Conversion to paid features and long-term LTV

Personalization is often assumed to be valuable by default. This experiment challenges that assumption.

If personalization improves engagement:

It justifies added system complexity

It supports premium feature gating

It strengthens defensibility of AI-driven features

If it does not:

A strong baseline may be sufficient early on

AI complexity may introduce cost without ROI

Product focus should shift toward clarity, safety, and reliability

This evaluation is designed to inform product strategy, not just technical performance.

Experimental Design

Two recommendation strategies were compared under controlled conditions.

1) Baseline Recommender (Rule-Based)

Uses static heuristics derived from domain knowledge
(e.g., species, general care needs, environment)

Produces consistent recommendations for similar profiles

Does not adapt based on interaction history

Represents a low-cost, industry-standard starting point

2) Personalized Recommender (Adaptive Agent)

Maintains lightweight preference weights

Adjusts recommendations based on observed click behavior

Does not train or fine-tune a model

Uses prompt-level adaptation and contextual memory

Reflects a realistic early-stage AI product implementation

Data

Fully synthetic users and interactions

Controlled environment to isolate the effect of personalization

Removes confounders such as UI bias, marketing effects, or churn

The goal is directional insight, not absolute performance claims.

Evaluation Metric
Click-Through Rate (CTR)
𝐶
𝑇
𝑅
=
clicks
impressions
CTR=
impressions
clicks
	​


CTR is used as a proxy for:

User interest

Recommendation relevance

Early engagement signal

Only one metric is intentionally used to keep interpretation clean and decision-focused.

Results (Example Run)
Baseline CTR:       0.1200
Personalized CTR:   0.1025


Key observation:
The personalized agent did not outperform the rule-based baseline in this setting.

Interpretation

This outcome is both realistic and informative:

Personalization does not automatically increase engagement

Lightweight adaptation may require:

More interaction history

Better behavioral signals

Tighter alignment between recommendations and user intent

A strong baseline can be competitive early in a product’s lifecycle

From a product standpoint:

Personalization should be introduced selectively

Complexity must earn its keep through measurable gains

Baselines matter—and should not be dismissed

Product Implications

PocketVet adopts a hybrid strategy:

Strong, safety-first rule-based defaults

Optional personalization layered on top

Advanced features (persistent memory, profile-based adaptation) gated behind Pro, aligning engineering cost with monetization

This evaluation can be re-run as richer, real-world data becomes available.

How to Run the Evaluation
python3 evaluation/src/run_eval.py

Why This Evaluation Exists

This experiment is intentionally simple, transparent, and reproducible.

Its purpose is to demonstrate:

Analytical rigor

Willingness to test assumptions

Product decisions driven by evidence—not AI hype

This evaluation directly informs PocketVet’s roadmap, feature gating strategy, and long-term product positioning.