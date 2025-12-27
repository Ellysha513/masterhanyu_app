import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../theme/app_background.dart';

class ProfileInfoScreen extends StatefulWidget {
  final UserProfile user;

  const ProfileInfoScreen({super.key, required this.user});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late String gender;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.user.name);
    ageController = TextEditingController(
      text: widget.user.age > 0 ? widget.user.age.toString() : '',
    );

    final g = widget.user.gender.trim();

    if (g == 'Male' || g == 'Female') {
      gender = g;
    } else {
      gender = 'Female'; // safe default
    }
  }

  // ------------------------------------------------------------
  // PICK & UPLOAD AVATAR
  // ------------------------------------------------------------
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final userId = widget.user.id;
    final filePath = '$userId/avatar.jpg';

    await Supabase.instance.client.storage
        .from('avatars')
        .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

    final publicUrl = Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(filePath);

    final imageUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

    await Supabase.instance.client
        .from('profiles')
        .update({'avatar_url': imageUrl})
        .eq('id', userId);

    setState(() {
      widget.user.imagePath = imageUrl;
    });
  }

  // ------------------------------------------------------------
  // SAVE PROFILE
  // ------------------------------------------------------------
  Future<void> _saveProfile() async {
    await Supabase.instance.client
        .from('profiles')
        .update({
          'name': nameController.text,
          'age': int.tryParse(ageController.text) ?? 0,
          'gender': gender,
        })
        .eq('id', widget.user.id);

    widget.user.name = nameController.text;
    widget.user.age = int.tryParse(ageController.text) ?? 0;
    widget.user.gender = gender;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      // ✅ APP BAR (FIXED)
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ), 
      // ------------------------------------------------------------
      // BODY
      // ------------------------------------------------------------
      body: Container(
        decoration: masterHanyuBackground(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // PROFILE IMAGE
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 38,
                      backgroundImage:
                          widget.user.imagePath != null
                              ? NetworkImage(widget.user.imagePath!)
                              : null,
                      backgroundColor: Colors.grey.shade300,
                      child:
                          widget.user.imagePath == null
                              ? const Icon(
                                Icons.camera_alt,
                                color: Colors.deepPurple,
                              )
                              : null,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                _infoCard(
                  label: "Name",
                  trailing: SizedBox(
                    width: 160,
                    child: TextField(
                      controller: nameController,
                      textAlign: TextAlign.end,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                _infoCard(
                  label: "Age",
                  trailing: SizedBox(
                    width: 60,
                    child: TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.end,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                _infoCard(
                  label: "Gender",
                  trailing: SizedBox(
                    width: 100,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: gender,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: const [
                          DropdownMenuItem(
                            value: "Female",
                            child: Text("Female"),
                          ),
                          DropdownMenuItem(value: "Male", child: Text("Male")),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => gender = value);
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 92, 86, 214),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "SAVE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard({required String label, required Widget trailing}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          trailing,
        ],
      ),
    );
  }
}
