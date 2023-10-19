import 'package:bilge_sosyal/responsive/screen_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'profile.dart'; // Profil sayfasının import edildiğinden emin olun

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<String> _uploadImageToFirebaseStorage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser!;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<void> _updateUserProfile() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    String newUsername = _usernameController.text;
    String newBio = _bioController.text;

    if (newUsername.isNotEmpty || _selectedImage != null) {
      var userData = {
        'username': newUsername,
        'bio': newBio,
      };

      if (_selectedImage != null) {
        String imageUrl = await _uploadImageToFirebaseStorage(_selectedImage!);
        userData['image_url'] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(userData);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Profil Güncellendi'),
            content: Text('Profil başarıyla güncellendi.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Profil sayfasına geri dön
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profili Düzenle',
          style: GoogleFonts.arvo(
            textStyle: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontSize: 40,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(93, 224, 230, 1),
                Color.fromRGBO(0, 74, 173, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: Colors.grey),
                ),
                child: _selectedImage != null
                    ? CircleAvatar(backgroundImage: FileImage(_selectedImage!))
                    : Icon(Icons.person, size: 50),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
            ),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: 'Kısa Biyografi'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: Text('Değişiklikleri Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}