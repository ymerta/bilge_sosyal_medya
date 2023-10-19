import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/animation.dart';

class DiscussionScreen extends StatefulWidget {
  final String postId;
  

  DiscussionScreen({required this.postId});

  @override
  _DiscussionScreenState createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  
  late Stream<DocumentSnapshot> _postStream;
  late Stream<QuerySnapshot> _commentsStream;
  TextEditingController _commentController = TextEditingController();
  bool _isAdmin = false; // Kullanıcının admin yetkisi durumu


  @override
  void initState() {
    super.initState();
    _checkAdminStatus(); // Kullanıcının admin yetkisi kontrol edilir
    _fetchPostAndComments();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _isAdmin = userData['is_admin'] ?? false;
      });
    }
  }

  Future<void> _fetchPostAndComments() async {
    _postStream =
        FirebaseFirestore.instance.collection('posts').doc(widget.postId).snapshots();
    _commentsStream = FirebaseFirestore.instance
        .collection('comments')
        .where('postId', isEqualTo: widget.postId)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> _toggleCommentLike(String commentId, bool newIsCorrect) async {
    try {
      // Yorumun beğenilme durumunu güncelle
      await FirebaseFirestore.instance.collection('comments').doc(commentId).update({
        'isCorrect': newIsCorrect,
      });

      // Diğer işlemler...
    } catch (error) {
      print('Beğeni güncellenirken hata oluştu: $error');
    }
  }

  Future<void> callAdmin() async {
  String commentText = _commentController.text.trim();
  if (commentText.isNotEmpty) {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      await FirebaseFirestore.instance.collection('comments').add({
        'comment': commentText,
        'postId': widget.postId,
        'username': userData['username'],
        'isCorrect': false,
        'isAdminComment': userData['is_admin'], // isAdminComment alanını buradan al
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
    } catch (error) {
      print('Yorum eklenirken hata oluştu: $error');
    }
  }
}

Future<void> _addComment() async {
  String commentText = _commentController.text.trim();
  if (commentText.isNotEmpty) {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      await FirebaseFirestore.instance.collection('comments').add({
        'comment': commentText,
        'postId': widget.postId,
        'username': userData['username'],
        'isCorrect': false,
        'isAdminComment': userData['is_admin'], // isAdminComment alanını buradan al
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
    } catch (error) {
      print('Yorum eklenirken hata oluştu: $error');
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Center(
              child: Text(
                'BILGE       ',
                style: GoogleFonts.arvo(
                  textStyle: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 36,
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
                  end: Alignment.topRight,
                ),
              ),
            ),
            floating: true,
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                StreamBuilder<DocumentSnapshot>(
                  stream: _postStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var postData = snapshot.data!.data() as Map<String, dynamic>;
                      var caption = postData['caption'];
                      var tags = List<String>.from(postData['tags']);
                      var desc = postData['description'];
                      var username = postData['username'];

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              caption,
                              style:
                                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Wrap(
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
                            SizedBox(height: 10),
                            Text(
                              'Soruyu Soran Kullanıcı: $username',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 10),
                            Card(
                              margin:
                                  EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                              child: Text(
                                desc,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: const Color.fromARGB(255, 5, 5, 5)),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Hata oluştu: ${snapshot.error}'));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                
                StreamBuilder<QuerySnapshot>(
  stream: _commentsStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      var comments = snapshot.data!.docs;

      return ListView.builder(
        shrinkWrap: true,
        itemCount: comments.length,
        itemBuilder: (context, index) {
          var commentData = comments[index].data() as Map<String, dynamic>;
          var comment = commentData['comment'];
          var userId = commentData['username'];
          var commentId = comments[index].id;
          var isCorrect = commentData['isCorrect'] ?? false;
          var isAdminComment = commentData['isAdminComment'] ?? false;

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(comment),
              subtitle: Text(userId),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAdminComment) // isAdminComment true ise, yani admin yorumu ise
                    Icon(Icons.admin_panel_settings, color: Colors.blue),
                  IconButton(
                    icon: Icon(
                      isCorrect
                          ? Icons.thumb_up_alt
                          : Icons.thumb_up_alt_outlined,
                      color: isCorrect
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    onPressed: () {
                      _toggleCommentLike(commentId, !isCorrect);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (snapshot.hasError) {
      return Center(child: Text('Hata oluştu: ${snapshot.error}'));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  },
),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yorum Ekle',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Yorumunuzu buraya yazın',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: 200,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _addComment,
                            child: Text('Gönder'),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          
                          width: 200, height: 40,
                          child: ElevatedButton(
                            onPressed: callAdmin,
                            child: Text('Admini Çağır'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}