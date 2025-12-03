import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  final String planId;                // unique ID for this plan
  final String dogId;                 // reference to dog
  final String forDate;               // YYYY-MM-DD

  // Premium AI-generated content
  final int? stepsGoal;
  final int? caloriesGoal;
  final int? durationMinutes;         // total activity minutes per day

  final List<String>? recommendedActivities;     // e.g. ["15 min walk", "fetch for 10 min"]
  final String? difficulty;                      // "easy", "moderate", "active"
  final String? message;                         // AI motivational message

  // Structured schedule breakdown
  final String? morningPlan;
  final String? afternoonPlan;
  final String? eveningPlan;

  final DateTime createdAt;
  final DateTime updatedAt;

  PlanModel({
    required this.planId,
    required this.dogId,
    required this.forDate,
    this.stepsGoal,
    this.caloriesGoal,
    this.durationMinutes,
    this.recommendedActivities,
    this.difficulty,
    this.message,
    this.morningPlan,
    this.afternoonPlan,
    this.eveningPlan,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // -----------------------------------------------------------
  // TO MAP (STORE IN FIRESTORE)
  // -----------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'dogId': dogId,
      'forDate': forDate,
      'stepsGoal': stepsGoal,
      'caloriesGoal': caloriesGoal,
      'durationMinutes': durationMinutes,
      'recommendedActivities': recommendedActivities,
      'difficulty': difficulty,
      'message': message,
      'morningPlan': morningPlan,
      'afternoonPlan': afternoonPlan,
      'eveningPlan': eveningPlan,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // -----------------------------------------------------------
  // FROM MAP (LOAD FROM FIRESTORE)
  // -----------------------------------------------------------
  factory PlanModel.fromMap(Map<String, dynamic> map) {
    return PlanModel(
      planId: map['planId'] ?? '',
      dogId: map['dogId'] ?? '',
      forDate: map['forDate'] ?? '',
      stepsGoal: map['stepsGoal'],
      caloriesGoal: map['caloriesGoal'],
      durationMinutes: map['durationMinutes'],
      recommendedActivities: map['recommendedActivities'] != null
          ? List<String>.from(map['recommendedActivities'])
          : null,
      difficulty: map['difficulty'],
      message: map['message'],
      morningPlan: map['morningPlan'],
      afternoonPlan: map['afternoonPlan'],
      eveningPlan: map['eveningPlan'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  // -----------------------------------------------------------
  // COPYWITH — for modifying an existing plan
  // -----------------------------------------------------------
  PlanModel copyWith({
    String? planId,
    String? dogId,
    String? forDate,
    int? stepsGoal,
    int? caloriesGoal,
    int? durationMinutes,
    List<String>? recommendedActivities,
    String? difficulty,
    String? message,
    String? morningPlan,
    String? afternoonPlan,
    String? eveningPlan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlanModel(
      planId: planId ?? this.planId,
      dogId: dogId ?? this.dogId,
      forDate: forDate ?? this.forDate,
      stepsGoal: stepsGoal ?? this.stepsGoal,
      caloriesGoal: caloriesGoal ?? this.caloriesGoal,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      recommendedActivities:
          recommendedActivities ?? this.recommendedActivities,
      difficulty: difficulty ?? this.difficulty,
      message: message ?? this.message,
      morningPlan: morningPlan ?? this.morningPlan,
      afternoonPlan: afternoonPlan ?? this.afternoonPlan,
      eveningPlan: eveningPlan ?? this.eveningPlan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
