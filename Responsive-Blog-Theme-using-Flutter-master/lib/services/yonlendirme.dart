import 'package:flutter/material.dart';
import 'package:news/models/kullanici.dart';
import 'package:news/screens/main/loginnedMainScreen.dart';
import 'package:news/screens/main/main_screen.dart';
import 'package:news/services/yetkilendirmeServisi.dart';
import 'package:provider/provider.dart';

class Yonlendirme extends StatelessWidget {
  const Yonlendirme({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    return StreamBuilder(
      stream: _yetkilendirmeServisi.durumTakipcisi,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          

          Kullanici kullanici = snapshot.data;
        
          _yetkilendirmeServisi.aktifKullaniciId = kullanici.id;

          return loginnedMainScreen();
        } else {
          return MainScreen();
        }
      },
    );
  }
}
