import 'dart:async';
import 'dart:io';

import 'package:bilge_sosyal/screens/changepassword.dart';
import 'package:bilge_sosyal/screens/editprofile.dart';
import 'package:bilge_sosyal/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';




class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkModeEnabled = false;
  late String _displayName = '';
  late String _displayBio = '';
  late String _displayImageUrl = '';
  File? _selectedImage;
  bool _areElementsVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      _displayName = userData['username'];
      _displayBio = userData['bio'];
      _displayImageUrl = userData['image_url'];
    });
  }



  Future<void> _refreshUserData() async {
    await _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        title: Text(
         
              'Profil',
              style: GoogleFonts.arvo(
                textStyle: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                ),
              ),
              textScaleFactor: 1.2,
            ).animate().fade(delay: 500.ms).slideY(),
         
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
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              CircleAvatar(
               
                
              
                 
                    radius: 50,
                    backgroundImage: NetworkImage(_displayImageUrl),
                  
                
              ),
              SizedBox(height: 10),
              Text(
               
                
                    _displayName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  
                
              ),
              SizedBox(height: 5),
              Padding(
              
                  
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _displayBio,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  
                
              ),
              SizedBox(height: 20),
              Row(
               
                 
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.comment),
                          Text('Yorumlar'),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('comments')
                                .where('username', isEqualTo: _displayName)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }

                              if (snapshot.hasError) {
                                return Text(
                                    'Veri alınamadı: ${snapshot.error}');
                              }

                              int commentCount = snapshot.data!.docs.length;

                              return Text(commentCount.toString());
                            },
                          ),
                        ],
                      ),
                      SizedBox(width: 40),
                      Column(
                        children: [
                          Icon(Icons.check),
                          Text('Doğru Cevaplar'),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('comments')
                                .where('username', isEqualTo: _displayName)
                                .where('isCorrect', isEqualTo: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }

                              if (snapshot.hasError) {
                                return Text(
                                    'Veri alınamadı: ${snapshot.error}');
                              }

                              int answerCount = snapshot.data!.docs.length;

                              return Text(answerCount.toString());
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                
             
              SizedBox(height: 10),
              SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[100],
                  ),
                  child: Text('Profili Düzenle'),
                ),
              ),
              SizedBox(height: 10),

              SizedBox(
                
                width: 200,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[100], 
                   
                  ),
                  child: Text('Şifre Değiştir'),
                ),
              ),
              SizedBox(height: 10),

              SizedBox(
                 width: 200,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[100],
                  ),
                  child: Text('Çıkış Yap'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}