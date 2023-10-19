import 'package:bilge_sosyal/responsive/screen_layout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'homepage2.dart'; // Homepage2 sınıfının import edildiğinden emin olun

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _captionController = TextEditingController();
  final _contentController = TextEditingController();
  bool _areElementsVisible = false;
  List<String> _selectedTags = [];

  Future<List<String>> getTags() async {
    List<String> tags = [];

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('tags').get();
      snapshot.docs.forEach((doc) {
        tags.add(doc['name']);
      });
    } catch (error) {
      print('Tags fetching error: $error');
    }

    return tags;
  }

  Future<void> addPost(
      String caption, List<String> tags, String description) async {
    try {
      var newPostRef = FirebaseFirestore.instance.collection('posts').doc();
      var postId = newPostRef.id;
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      await FirebaseFirestore.instance.collection('posts').add({
        'postId': postId,
        'username': userData.data()!['username'],
        'caption': caption,
        'tags': tags,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Gönderi başarıyla eklendi.');
      Navigator.pop(context);
    } catch (error) {
      print('Gönderi eklenirken hata oluştu: $error');
    }
  }


  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
           
                'Soru Ekle',
                style: GoogleFonts.arvo(
                  textStyle: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).animate().fade(delay: 500.ms).slideY(),
           
          
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
                Color.fromRGBO(0, 74, 173, 1)
              ],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView( // SingleChildScrollView ekleyin
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                style: GoogleFonts.arvo(),
                
                    controller: _captionController,
                    decoration: InputDecoration(labelText: 'Başlık',labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                   
                  ),
                SizedBox(height: 15),
                Text('Etiketler', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
                  ),
              
             
              
              Card(
                
                child: FutureBuilder<List<String>>(
                  future: getTags(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
              
                    if (snapshot.hasError) {
                      return Text('Hata oluştu: ${snapshot.error}');
                    }
              
                    List<String> tags = snapshot.data ?? [];
              
                    return Column(
                      children: tags.map((tag) {
                        return CheckboxListTile(
                          title: Text(tag),
                          value: _selectedTags.contains(tag),
                          onChanged: (newValue) {
                            setState(() {
                              if (newValue != null && newValue) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              TextField(
                style: GoogleFonts.arvo(),
                
                    controller: _contentController,
                    decoration: InputDecoration(labelText: 'İçerik',labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                    maxLines: 4,
                  ),
                
              
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  String caption = _captionController.text;
                  String description = _contentController.text;
                  addPost(caption, _selectedTags, description);
                  _captionController.clear();
                  _contentController.clear();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                             const MobileScreenLayout())); // Sayfa değiştiğinde yenisini yükle
                },
                style: ElevatedButton.styleFrom(
                  
                  primary: Colors.grey[100], // Mavi gradyan rengi
                ),
                 
                 
                  child: Text('Soru Ekle'),
                
              ),
            ],
          ),
        ),
      ),
    );
  }
}