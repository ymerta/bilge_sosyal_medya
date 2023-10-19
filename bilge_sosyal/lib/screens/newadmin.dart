import 'package:bilge_sosyal/screens/display_admin_messages.dart';
import 'package:bilge_sosyal/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class NewAdminScreen extends StatefulWidget {
  @override
  _NewAdminScreenState createState() => _NewAdminScreenState();
}

class _NewAdminScreenState extends State<NewAdminScreen> {
  int _userCount = 0;
  int _messageCount = 0;
  List<String> _usernames = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userQuerySnapshot = await FirebaseFirestore.instance.collection('users').get();
    final messageQuerySnapshot = await FirebaseFirestore.instance.collection('comments').where('callAdmin', isEqualTo: true).get();
    
    List<String> usernames = [];
    userQuerySnapshot.docs.forEach((doc) {
      usernames.add(doc['username']);
    });

    setState(() {
      _userCount = userQuerySnapshot.size;
      _messageCount = messageQuerySnapshot.size;
      _usernames = usernames;
    });
  }

  Future<void> _deleteUser(String username) async {
    await FirebaseFirestore.instance.collection('users').where('username', isEqualTo: username).get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    _loadData();
  }

  Future<void> _addNewUser(String username, String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance.collection('users').add({
        'username': username,
        'email': email,
        'isAdmin': false,
      });
      _loadData();
    } catch (error) {
      print('Yeni kullanıcı eklenirken hata oluştu: $error');
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BILGE',
          style: GoogleFonts.arvo(
            textStyle: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontSize: 36,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddUserDialog(
                  onAddUser: _addNewUser,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(58, 167, 208, 1),
                Color.fromRGBO(0, 74, 173, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          children: [
            SizedBox(height: 20),
            Card(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Kullanıcılar: $_userCount',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_usernames.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _usernames.map((username) {
                          return Row(
                            children: [
                              Expanded(child: Text(username)),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  _deleteUser(username);
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Mesajlar: $_messageCount',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminMessagesScreen()),
                        );
                      },
                      child: Text('Mesajları Görüntüle'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  final Function(String, String, String) onAddUser;

  AddUserDialog({required this.onAddUser});

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Yeni Kullanıcı Ekle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
          ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'E-posta'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Şifre'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            String username = _usernameController.text;
            String email = _emailController.text;
            String password = _passwordController.text;
            widget.onAddUser(username, email, password);
            Navigator.pop(context);
          },
          child: Text('Ekle'),
        ),
      ],
    );
  }
}