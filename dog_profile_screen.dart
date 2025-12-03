import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/dog_provider.dart';

class DogProfileScreen extends StatefulWidget {
  const DogProfileScreen({super.key});

  @override
  State<DogProfileScreen> createState() => _DogProfileScreenState();
}

class _DogProfileScreenState extends State<DogProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _gender;

  String? _photoUrl; // placeholder until StorageService is added

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dogProvider = Provider.of<DogProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Dog Profile",
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

              // ----------------------------------------------------
              // DOG PHOTO (PLACEHOLDER UNTIL STORAGE SERVICE)
              // ----------------------------------------------------
              GestureDetector(
                onTap: () {
                  // We will replace this with real photo picker later
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Photo upload coming soon!"),
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


              // ----------------------------------------------------
              // NAME
              // ----------------------------------------------------
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


              // ----------------------------------------------------
              // BREED
              // ----------------------------------------------------
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  hintText: "Breed (optional)",
                ),
              ),

              const SizedBox(height: 16),


              // ----------------------------------------------------
              // AGE
              // ----------------------------------------------------
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


              // ----------------------------------------------------
              // WEIGHT
              // ----------------------------------------------------
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


              // ----------------------------------------------------
              // GENDER DROPDOWN
              // ----------------------------------------------------
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


              // ----------------------------------------------------
              // ERROR MESSAGE
              // ----------------------------------------------------
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


              // ----------------------------------------------------
              // SAVE BUTTON
              // ----------------------------------------------------
              ElevatedButton(
                onPressed: dogProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await dogProvider.createDog(
                            ownerId: authProvider.user!.uid,
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
                    : const Text("Save Dog"),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
