WoofFit AI — Evaluating Personalization vs. Rule-Based Recommendations
Research Question

Does lightweight AI-driven personalization measurably improve user engagement compared to static, rule-based recommendations in a consumer health application?

This study evaluates whether adaptive agent behavior—without model training or fine-tuning—can generate meaningful engagement gains over a traditional baseline approach.

Why This Matters (Product & Business Lens)

In consumer subscription products, engagement is a leading indicator of retention, habit formation, and lifetime value (LTV).

If personalization increases engagement:

Users are more likely to return regularly

Trust in the product increases

Conversion to paid features becomes more defensible

If it does not increase engagement, it signals that:

Personalization may be unnecessary at early stages, or

The implementation adds complexity without clear ROI

This evaluation is designed to inform product strategy, not just technical performance.

Experimental Design

We compare two recommendation strategies under controlled conditions.

1) Baseline Recommender (Rule-Based)

Uses static heuristics (e.g., breed category, general activity level)

Produces the same recommendation pattern for similar users

Does not adapt based on interaction history

Represents a low-cost, industry-standard starting point

2) Personalized Recommender (Adaptive Agent)

Maintains lightweight user preference weights

Updates recommendations based on observed click behavior

Does not train or fine-tune a model

Uses prompt-level adaptation and contextual memory

Designed to reflect a realistic early-stage AI product approach

Data

Fully synthetic users and interactions

Controlled environment to isolate the effect of personalization

Eliminates confounding variables such as UI bias, marketing effects, or user churn

Prioritizes directional insight over absolute performance

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
Personalization did not outperform the baseline in this controlled setting.

Interpretation

This result is both realistic and informative:

Personalization does not automatically guarantee higher engagement

Lightweight adaptive logic may require:

More interaction history

Better feature signals

Stronger alignment between recommendations and user goals

A strong baseline can be competitive early in a product’s lifecycle

From a product perspective, this suggests:

Personalization should be introduced selectively

Complexity must be justified by measurable gains

Baselines matter — and should not be dismissed

Product Implications

WoofFit AI adopts a hybrid approach:

Strong rule-based defaults

Optional personalization layered on top

Advanced features (persistent memory, profile-based adaptation) are gated behind Pro, aligning engineering cost with monetization

Future iterations can re-run this evaluation as richer data becomes available

How to Run the Evaluation
python3 evaluation/src/run_eval.py

Why This Evaluation Exists

This experiment is intentionally simple, transparent, and reproducible.
Its purpose is to demonstrate:

Analytical thinking

Willingness to test assumptions

Product decisions informed by data, not hype

This evaluation directly informs WoofFit AI’s feature roadmap and business strategy.