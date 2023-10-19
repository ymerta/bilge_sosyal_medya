import 'package:flutter/material.dart';

class IntroPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(58, 167, 208, 1),
                Color.fromRGBO(0, 74, 173, 1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.fromLTRB(20, 55, 20, 0)),
                Image.asset('img/intro3.png'),
                Text(
                  'Doğru Yanıtları Belirtip Senden Sonraki Kişilere Yardımcı Olabileceksin',
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  textScaleFactor: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}