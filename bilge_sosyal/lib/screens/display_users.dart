
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  UserListScreen({required this.users});



  @override
  Widget build(BuildContext context) {
    void _addNewUser() async {
  String newUsername = ''; // Yeni kullanıcının adını saklamak için boş bir string
  TextEditingController usernameController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Yeni Kullanıcı Ekle'),
        content: TextField(
          controller: usernameController,
          decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              newUsername = usernameController.text.trim();
              Navigator.pop(context); // Diyalog kapatılır
            },
            child: Text('Ekle'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Diyalog kapatılır
            },
            child: Text('İptal'),
          ),
        ],
      );
    },
  );

  // Eğer yeni kullanıcı adı boş değilse, Firestore'a eklenir
  if (newUsername.isNotEmpty) {
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'username': newUsername,
      });
      print('Yeni kullanıcı eklendi: $newUsername');
    } catch (error) {
      print('Kullanıcı eklenirken hata oluştu: $error');
    }
  }
}
   
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcılar'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          String username = users[index]['username'];
          return ListTile(
            title: Text(username),
            trailing: ElevatedButton(
              onPressed: () {
                // Kullanıcıyı silme işlemleri
                _deleteUser(users[index]['userId']); // userId'yi kullanarak silme işlemi yapılabilir
              },
              child: Text('Sil'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni kullanıcı ekleme işlemleri
          _addNewUser();
        },
        child: Icon(Icons.add),
      ),
    );
  }
 
  void _deleteUser(String userId) {
    // Kullanıcı silme işlemleri burada gerçekleştirilebilir
    FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }


}