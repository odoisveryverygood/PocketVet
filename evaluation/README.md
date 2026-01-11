# WoofFit AI — Baseline vs Personalized Recommender Evaluation

## Research Question
Does AI-driven personalization increase user engagement compared to static, rule-based recommendations in a consumer health application?

## Why This Matters (Business)
Engagement is a leading indicator for retention and subscription conversion in consumer apps. If personalization improves engagement, it suggests clear business value (higher LTV).

## Experiment Setup
We compare two recommendation approaches:

### 1) Baseline (Rule-Based)
A static recommender using simple rules based on breed/activity level. No learning over time.

### 2) Personalized (Adaptive Agent)
A lightweight adaptive recommender that updates user preference weights based on click history.

## Data
Synthetic users and interactions (controlled environment) to isolate the impact of personalization.

## Metric (One)
CTR (click-through rate) = clicks / impressions

## How To Run
```bash
python3 evaluation/src/run_eval.py
