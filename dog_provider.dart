import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/dog_model.dart';
import '../services/firestore_service.dart';
import '../providers/auth_provider.dart';

class DogProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final Uuid _uuid = const Uuid();

  // ACTIVE DOG (the one currently selected)
  DogModel? _activeDog;
  DogModel? get activeDog => _activeDog;

  // LIST OF ALL USER DOGS
  List<DogModel> _dogs = [];
  List<DogModel> get dogs => _dogs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ------------------------------------------------------
  // LOAD DOGS FOR CURRENT USER
  // ------------------------------------------------------
  Future<void> loadDogs(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dogs = await _firestore.getDogsForUser(ownerId);

      // Automatically pick first dog if no activeDog selected
      if (_dogs.isNotEmpty && _activeDog == null) {
        _activeDog = _dogs.first;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------------------------------------
  // CREATE A NEW DOG
  // ------------------------------------------------------
  Future<bool> createDog({
    required String ownerId,
    required String name,
    String? breed,
    int? age,
    double? weight,
    String? gender,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newDog = DogModel(
        dogId: _uuid.v4(),
        ownerId: ownerId,
        name: name,
        breed: breed,
        age: age,
        weight: weight,
        gender: gender,
        photoUrl: photoUrl,
      );

      await _firestore.addDog(newDog);

      _dogs.add(newDog);
      _activeDog = newDog;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to create dog: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ------------------------------------------------------
  // UPDATE EXISTING DOG
  // ------------------------------------------------------
  Future<bool> updateDog(DogModel updatedDog) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore.updateDog(updatedDog);

      // update dog in local list
      final index = _dogs.indexWhere((d) => d.dogId == updatedDog.dogId);
      if (index != -1) {
        _dogs[index] = updatedDog;
      }

      // update active
      if (_activeDog?.dogId == updatedDog.dogId) {
        _activeDog = updatedDog;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to update dog: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ------------------------------------------------------
  // DELETE A DOG
  // ------------------------------------------------------
  Future<bool> deleteDog(String dogId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore.deleteDog(dogId);

      _dogs.removeWhere((dog) => dog.dogId == dogId);

      // update active dog
      if (_activeDog?.dogId == dogId) {
        _activeDog = _dogs.isNotEmpty ? _dogs.first : null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to delete dog: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ------------------------------------------------------
  // SET ACTIVE DOG
  // ------------------------------------------------------
  void setActiveDog(DogModel dog) {
    _activeDog = dog;
    notifyListeners();
  }

  // ------------------------------------------------------
  // CLEAR ERRORS
  // ------------------------------------------------------
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
