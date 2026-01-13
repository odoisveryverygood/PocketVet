import random
from dataclasses import dataclass
from typing import List, Dict


# -----------------------------
# Data structures
# -----------------------------

@dataclass
class User:
    user_id: str
    pet_type: str          # dog / cat
    concern: str           # digestion / skin / anxiety / mobility / general
    urgency: str           # low / medium / high


@dataclass
class Item:
    item_id: str
    topic: str             # symptom_check / home_care / diet / vet_guidance
    urgency: str           # low / medium / high


# -----------------------------
# Recommenders
# -----------------------------

def baseline_recommender(user: User, items: List[Item], k: int = 5) -> List[Item]:
    """
    Static, rule-based recommender (PocketVet baseline).
    No learning, no adaptation.
    """
    # Simple heuristic: match urgency, and prioritize "vet_guidance" for high urgency
    preferred_urgency = user.urgency

    scored = []
    for item in items:
        score = 0

        # urgency match
        if item.urgency == preferred_urgency:
            score += 2

        # safe baseline behavior: for high urgency, prioritize vet guidance
        if user.urgency == "high" and item.topic == "vet_guidance":
            score += 2

        # generally useful topic across concerns
        if item.topic == "symptom_check":
            score += 1

        scored.append((score, random.random(), item))

    scored.sort(reverse=True)
    return [x[2] for x in scored[:k]]


class PersonalizedRecommender:
    """
    Simple adaptive recommender that updates preferences
    based on past clicks (topic + urgency weights).
    """
    def __init__(self):
        self.preferences: Dict[str, Dict[str, float]] = {}

    def update(self, user_id: str, clicked_items: List[Item]):
        prefs = self.preferences.setdefault(user_id, {})
        for item in clicked_items:
            prefs[item.topic] = prefs.get(item.topic, 0) + 1.0
            prefs[item.urgency] = prefs.get(item.urgency, 0) + 0.5

    def recommend(self, user: User, items: List[Item], k: int = 5) -> List[Item]:
        prefs = self.preferences.get(user.user_id, {})

        scored = []
        for item in items:
            score = prefs.get(item.topic, 0) + prefs.get(item.urgency, 0)

            # mild safety bias: if user is high urgency, don't drift too far from vet guidance
            if user.urgency == "high" and item.topic == "vet_guidance":
                score += 0.5

            scored.append((score, random.random(), item))

        scored.sort(reverse=True)
        return [x[2] for x in scored[:k]]


# -----------------------------
# Simulation helpers
# -----------------------------

def generate_users(n: int = 80) -> List[User]:
    pet_types = ["dog", "cat"]
    concerns = ["digestion", "skin", "anxiety", "mobility", "general"]
    urgencies = ["low", "medium", "high"]

    users = []
    for i in range(n):
        pet_type = random.choice(pet_types)
        concern = random.choice(concerns)
        urgency = random.choice(urgencies)

        # Slightly bias certain combinations to feel realistic:
        # mobility issues more often medium/high, anxiety often medium
        if concern == "mobility":
            urgency = random.choice(["medium", "high"])
        if concern == "anxiety":
            urgency = random.choice(["low", "medium", "medium"])

        users.append(User(f"user_{i}", pet_type, concern, urgency))
    return users


def generate_items(n: int = 40) -> List[Item]:
    topics = ["symptom_check", "home_care", "diet", "vet_guidance"]
    urgencies = ["low", "medium", "high"]

    items = []
    for i in range(n):
        items.append(Item(
            item_id=f"item_{i}",
            topic=random.choice(topics),
            urgency=random.choice(urgencies),
        ))
    return items


def click_probability(user: User, item: Item) -> float:
    """
    Synthetic behavior model:
    - Users click more when urgency matches their situation
    - Topic relevance matters (e.g., digestion -> diet/home_care)
    - High urgency users more likely to click vet guidance
    """
    p = 0.05

    # urgency alignment matters
    if user.urgency == item.urgency:
        p += 0.10

    # topic relevance by concern
    if user.concern == "digestion" and item.topic in ["diet", "home_care", "symptom_check"]:
        p += 0.07
    if user.concern == "skin" and item.topic in ["home_care", "diet", "symptom_check"]:
        p += 0.06
    if user.concern == "anxiety" and item.topic in ["home_care", "symptom_check"]:
        p += 0.06
    if user.concern == "mobility" and item.topic in ["home_care", "vet_guidance", "symptom_check"]:
        p += 0.07

    # high urgency: stronger pull toward vet guidance
    if user.urgency == "high" and item.topic == "vet_guidance":
        p += 0.08

    # keep probabilities reasonable
    return min(p, 0.45)


def run_round(users, items, recommend_fn):
    impressions = 0
    clicks = 0
    clicked_by_user: Dict[str, List[Item]] = {u.user_id: [] for u in users}

    for user in users:
        recs = recommend_fn(user, items)
        impressions += len(recs)

        for item in recs:
            if random.random() < click_probability(user, item):
                clicks += 1
                clicked_by_user[user.user_id].append(item)

    return impressions, clicks, clicked_by_user


# -----------------------------
# Main evaluation
# -----------------------------

def ctr(clicks, impressions):
    return clicks / impressions if impressions else 0.0


def main():
    users = generate_users()
    items = generate_items()

    # Baseline (PocketVet)
    b_impr, b_clicks, _ = run_round(users, items, baseline_recommender)

    # Personalized (multiple rounds to allow learning)
    pr = PersonalizedRecommender()
    p_impr = 0
    p_clicks = 0

    for _ in range(5):
        impr, clicks, clicked = run_round(users, items, pr.recommend)
        p_impr += impr
        p_clicks += clicks
        for uid, items_clicked in clicked.items():
            pr.update(uid, items_clicked)

    print("\nPocketVet Evaluation (Metric: CTR)\n")
    print(f"Baseline CTR:      {ctr(b_clicks, b_impr):.4f}")
    print(f"Personalized CTR:  {ctr(p_clicks, p_impr):.4f}")


if __name__ == "__main__":
    main()
