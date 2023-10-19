import 'package:bilge_sosyal/screens/discussion_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminMessagesScreen extends StatefulWidget {
  @override
  _AdminMessagesScreenState createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
                '         BILGE       ',
                style: GoogleFonts.arvo(
                  textStyle: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).animate().fade(delay: 500.ms).slideY(),
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('comments')
            .where('callAdmin', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> commentDocs = snapshot.data!.docs;
          
          return ListView.builder(
            itemCount: commentDocs.length,
            itemBuilder: (context, index) {
              var commentData = commentDocs[index].data() as Map<String, dynamic>;
              var commentId = commentDocs[index].id;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: ListTile(
                  title: Text(commentData['comment']),
                  subtitle: Text('Gönderen: ${commentData['username']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      String postId = commentData['postId'];
                      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscussionScreen(postId: postId),
      ),
    );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}