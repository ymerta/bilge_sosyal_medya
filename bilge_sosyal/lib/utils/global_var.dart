import 'package:bilge_sosyal/screens/ask_question.dart';
import 'package:bilge_sosyal/screens/homepage2.dart';
import 'package:bilge_sosyal/screens/profile.dart';
import 'package:bilge_sosyal/screens/search_page.dart';
import 'package:flutter/material.dart';
import 'package:bilge_sosyal/screens/ask_question.dart';
import 'package:firebase_auth/firebase_auth.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
   FeedScreen(),
   SearchScreen(),
   AddPostScreen(),
  ProfileScreen()
  ,
];
