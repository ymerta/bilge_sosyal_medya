import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'discussion_screen.dart'; // DiscussionScreen sınıfının import edildiğinden emin olun

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _tagController = TextEditingController();
  List<QueryDocumentSnapshot> _searchResults = [];
  Stream<List<String>>? _previousTagsStream;
  bool _areElementsVisible = false;

  @override
  void initState() {
    super.initState();
    _previousTagsStream = getPreviousTagsStream();
    _loadPreviousTagsPosts(); // Önceki etiketlere sahip postları yükle
    _animateElements();
  }

  Stream<List<String>> getPreviousTagsStream() {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);

    return userRef.snapshots().map((snapshot) {
      final List<dynamic> previousTags = snapshot['previousTags'] ?? [];
      return previousTags.cast<String>();
    });
  }

  Future<void> _loadPreviousTagsPosts() async {
    final previousTags = await _previousTagsStream?.first;
    if (previousTags != null && previousTags.isNotEmpty) {
      await _searchByPreviousTags(previousTags);
    }
  }

  Future<void> _searchByTag(String tag) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('tags', arrayContains: tag)
          .get();
      setState(() {
        _searchResults = querySnapshot.docs;
      });
    } catch (error) {
      print('Veri alınamadı: $error');
    }
  }

  Future<void> _searchByPreviousTags(List<String> previousTags) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('tags', arrayContainsAny: previousTags)
          .get();
      setState(() {
        _searchResults = querySnapshot.docs;
      });
    } catch (error) {
      print('Veri alınamadı: $error');
    }
  }

  Future<String?> _getPostId(int index) async {
    if (_searchResults.isNotEmpty) {
      var questionData = _searchResults[index - 2].data() as Map<String, dynamic>;
      return questionData['postId'];
    }
    return null;
  }

  void _animateElements() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _areElementsVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            title: Center(
              child: Text(
                'Ara',
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AnimatedOpacity(
                      opacity: _areElementsVisible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0.0, 0.5),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: ModalRoute.of(context)!.animation!,
                          curve: Curves.easeInOut,
                        )),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tagController,
                                decoration: InputDecoration(labelText: 'Konu Ara'),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.search, size: 30),
                              onPressed: () async {
                                String tag = _tagController.text.trim();
                                if (tag.isNotEmpty) {
                                  await _searchByTag(tag);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (_searchResults.isNotEmpty) {
                  var questionData = _searchResults[index - 1].data() as Map<String, dynamic>;
                  var tags = List<String>.from(questionData['tags'] ?? []);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedOpacity(
                      opacity: _areElementsVisible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0.0, 0.5),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: ModalRoute.of(context)!.animation!,
                          curve: Curves.easeInOut,
                        )),
                        child: Card(
                          elevation: 4,
                          child: ListTile(
                            title: Text(questionData['caption']),
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
                              onPressed: () async {
                                String? postId = await _getPostId(index);
                                if (postId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DiscussionScreen(postId: postId),
                                    ),
                                  );
                                }
                              },
                              child: Text('Konuyu Görüntüle'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
              childCount: _searchResults.isNotEmpty ? _searchResults.length + 1 : 1,
            ),
          ),
        ],
      ),
    );
  }
}