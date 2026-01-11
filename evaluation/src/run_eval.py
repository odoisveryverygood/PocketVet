import random
from dataclasses import dataclass
from typing import List, Dict


# -----------------------------
# Data structures
# -----------------------------

@dataclass
class User:
    user_id: str
    dog_breed: str
    activity_level: str  # low / medium / high


@dataclass
class Item:
    item_id: str
    category: str       # walk / meal / training
    intensity: str      # low / medium / high


# -----------------------------
# Recommenders
# -----------------------------

def baseline_recommender(user: User, items: List[Item], k: int = 5) -> List[Item]:
    """
    Static, rule-based recommender.
    No learning, no adaptation.
    """
    preferred_intensity = "high" if (
        user.dog_breed in ["husky", "border collie"] or user.activity_level == "high"
    ) else "medium"

    scored = []
    for item in items:
        score = 0
        if item.intensity == preferred_intensity:
            score += 2
        if item.category == "walk":
            score += 1
        scored.append((score, random.random(), item))

    scored.sort(reverse=True)
    return [x[2] for x in scored[:k]]


class PersonalizedRecommender:
    """
    Simple adaptive recommender that updates preferences
    based on past clicks.
    """
    def __init__(self):
        self.preferences: Dict[str, Dict[str, float]] = {}

    def update(self, user_id: str, clicked_items: List[Item]):
        prefs = self.preferences.setdefault(user_id, {})
        for item in clicked_items:
            prefs[item.category] = prefs.get(item.category, 0) + 1.0
            prefs[item.intensity] = prefs.get(item.intensity, 0) + 0.5

    def recommend(self, user: User, items: List[Item], k: int = 5) -> List[Item]:
        prefs = self.preferences.get(user.user_id, {})
        scored = []
        for item in items:
            score = prefs.get(item.category, 0) + prefs.get(item.intensity, 0)
            scored.append((score, random.random(), item))
        scored.sort(reverse=True)
        return [x[2] for x in scored[:k]]


# -----------------------------
# Simulation helpers
# -----------------------------

def generate_users(n: int = 80) -> List[User]:
    breeds = ["husky", "corgi", "labrador", "border collie", "poodle"]
    levels = ["low", "medium", "high"]

    users = []
    for i in range(n):
        breed = random.choice(breeds)
        level = random.choice(levels)
        if breed in ["husky", "border collie"]:
            level = random.choice(["medium", "high"])
        users.append(User(f"user_{i}", breed, level))
    return users


def generate_items(n: int = 40) -> List[Item]:
    categories = ["walk", "meal", "training"]
    intensities = ["low", "medium", "high"]

    items = []
    for i in range(n):
        items.append(Item(
            item_id=f"item_{i}",
            category=random.choice(categories),
            intensity=random.choice(intensities),
        ))
    return items


def click_probability(user: User, item: Item) -> float:
    p = 0.05
    if item.category == "walk":
        p += 0.05
    if user.activity_level == item.intensity:
        p += 0.08
    if user.dog_breed == "husky" and item.intensity == "high":
        p += 0.07
    return min(p, 0.4)


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

    # Baseline
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

    print("\nWoofFit AI Evaluation (Metric: CTR)\n")
    print(f"Baseline CTR:      {ctr(b_clicks, b_impr):.4f}")
    print(f"Personalized CTR: {ctr(p_clicks, p_impr):.4f}")


if __name__ == "__main__":
    main()
