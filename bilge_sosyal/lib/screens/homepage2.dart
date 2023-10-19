import 'package:bilge_sosyal/screens/discussion_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';




class FeedScreen extends StatefulWidget {
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
    bool _areCardsVisible = false;

   void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();
    final token = await fcm.getToken();
    print(token);


    fcm.subscribeToTopic('posts');
  }
  
  List<Map<String, dynamic>> _posts = [];
  @override
  void initState() {
    super.initState();
    _fetchPosts();
    setupPushNotifications();
    Future.delayed(Duration(milliseconds: 1000), ()
     {
      setState(() {
        _areCardsVisible = true;
      });
    });
  }
Future<void> _addTagsToUser(String postId, List<String> tags) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      List<String> previousTags = List<String>.from(userDoc.get('previousTags') ?? []);
      
    
      for (String tag in tags) {
        if (!previousTags.contains(tag)) {
          previousTags.add(tag);
        }
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'previousTags': previousTags,
      });

      print('Taglar kullanıcının previousTags alanına eklendi.');
    }
  } catch (error) {
    print('Tagları kullanıcının previousTags alanına eklerken hata oluştu: $error');
  }
}
  Future<void> _fetchPosts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).get();
      List<Map<String, dynamic>> posts = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      setState(() {
        _posts = posts;
      });
    } catch (error) {
      print('Post verileri getirilirken hata oluştu: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50), 
                bottomRight: Radius.circular(50),
              ),
            ),
            title: Center(
              child: Text(
                'En Yeni Sorular',
                style: GoogleFonts.arvo(
                  textStyle: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).animate().fade(delay: 500.ms).slideY(),
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
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            floating: true,
            snap: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                Map<String, dynamic> postData = _posts[index];
                String postId = postData['postId'];
                List<String> tags = List<String>.from(postData['tags'] ?? []);

                return AnimatedOpacity(opacity: _areCardsVisible ? 1.0 : 0.0, duration: Duration(milliseconds: 500),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0.0, 0.5), // Aşağıdan yukarıya kaydırma için
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: ModalRoute.of(context)!.animation!,
                      curve: Curves.easeInOut,
                    )),
                child: Card(
                  color: Color.fromRGBO(93, 191, 230, 1),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListTile(
                    title: Text(
                      postData['caption'],
                      textScaleFactor: 1.5,
                      style: GoogleFonts.arvo(
                        textStyle: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    subtitle: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.blue,
                          labelStyle: TextStyle(color: Colors.white),
                        );
                      }).toList(),
                    ),
                    trailing: ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscussionScreen(postId: postId),
      ),
    );

    // _addTagsToUser fonksiyonunu burada çağırın
    _addTagsToUser(postId, tags);
  },
  child: Text('Tartısmaya Git'),
),
                  ),
                ),
                ),
                );
              },
              childCount: _posts.length,
            ),
          ),
        ],
      ),
    );
  }
}
