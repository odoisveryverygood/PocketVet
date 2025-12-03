import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dog_model.dart';
import '../providers/dog_provider.dart';

class EditDogProfileScreen extends StatefulWidget {
  final DogModel dog;

  const EditDogProfileScreen({super.key, required this.dog});

  @override
  State<EditDogProfileScreen> createState() => _EditDogProfileScreenState();
}

class _EditDogProfileScreenState extends State<EditDogProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  String? _gender;
  String? _photoUrl; // will be connected to Firebase Storage later

  @override
  void initState() {
    super.initState();

    // Prefill values
    _nameController = TextEditingController(text: widget.dog.name);
    _breedController = TextEditingController(text: widget.dog.breed ?? "");
    _ageController = TextEditingController(
        text: widget.dog.age != null ? widget.dog.age.toString() : "");
    _weightController = TextEditingController(
        text: widget.dog.weight != null ? widget.dog.weight.toString() : "");
    _gender = widget.dog.gender;
    _photoUrl = widget.dog.photoUrl;
  }

  @override
  Widget build(BuildContext context) {
    final dogProvider = Provider.of<DogProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Dog Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),

        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              // --------------------------------------------------------
              // DOG PHOTO (placeholder until storage service enabled)
              // --------------------------------------------------------
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Photo editing coming soon!"),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.orange.shade200,
                  backgroundImage: (_photoUrl != null)
                      ? NetworkImage(_photoUrl!)
                      : null,
                  child: (_photoUrl == null)
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                      : null,
                ),
              ),

              const SizedBox(height: 22),


              // --------------------------------------------------------
              // NAME
              // --------------------------------------------------------
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Dog's Name",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your dog's name.";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),


              // --------------------------------------------------------
              // BREED
              // --------------------------------------------------------
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  hintText: "Breed (optional)",
                ),
              ),

              const SizedBox(height: 16),


              // --------------------------------------------------------
              // AGE
              // --------------------------------------------------------
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  hintText: "Age (years)",
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (int.tryParse(value) == null) {
                      return "Age must be a number.";
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),


              // --------------------------------------------------------
              // WEIGHT
              // --------------------------------------------------------
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  hintText: "Weight (kg)",
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return "Weight must be a number.";
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),


              // --------------------------------------------------------
              // GENDER
              // --------------------------------------------------------
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  hintText: "Gender (optional)",
                ),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                ],
                onChanged: (value) {
                  setState(() => _gender = value);
                },
              ),

              const SizedBox(height: 25),


              // --------------------------------------------------------
              // ERROR MESSAGE
              // --------------------------------------------------------
              if (dogProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    dogProvider.errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),


              // --------------------------------------------------------
              // SAVE CHANGES BUTTON
              // --------------------------------------------------------
              ElevatedButton(
                onPressed: dogProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final updatedDog = widget.dog.copyWith(
                            name: _nameController.text.trim(),
                            breed: _breedController.text.trim().isEmpty
                                ? null
                                : _breedController.text.trim(),
                            age: _ageController.text.trim().isEmpty
                                ? null
                                : int.parse(_ageController.text.trim()),
                            weight: _weightController.text.trim().isEmpty
                                ? null
                                : double.parse(_weightController.text.trim()),
                            gender: _gender,
                            photoUrl: _photoUrl,
                          );

                          final success = await dogProvider.updateDog(updatedDog);

                          if (success && mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                child: dogProvider.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Save Changes"),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

