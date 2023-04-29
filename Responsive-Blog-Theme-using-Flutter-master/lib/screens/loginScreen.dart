import 'package:flutter/material.dart';
import 'package:news/screens/register.dart';
import 'package:news/services/yonlendirme.dart';
import 'package:provider/provider.dart';

import '../models/kullanici.dart';
import '../services/firestoreSrvisi.dart';
import '../services/yetkilendirmeServisi.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  bool yukleniyor = false;
  String email = '';
  String sifre = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldAnahtari,
      backgroundColor: Colors.black,
      body: Stack(children: [
        Form(
          key: _formAnahtari,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * .5,
              //height: MediaQuery.of(context).size.width * .5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //image

                  Text(
                    'Fann Desing',
                    style: TextStyle(color: Colors.red, fontSize: 55),
                  ),
                  Text('Geleceğin Mimarları'),
                  SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    onChanged: (girilenDeger) {
                      email = girilenDeger;
                    },
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.pinkAccent, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.pinkAccent, width: 2)),
                        hintText: 'Email ',
                        hintStyle: TextStyle(color: Colors.white),
                        icon: Icon(Icons.email)),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  //şifre

                  TextFormField(
                    onChanged: (girilenDeger) {
                      sifre = girilenDeger;
                    },
                    validator: (girilenDeger) {
                      if (girilenDeger.isEmpty) {
                        return 'Şifre boş bırakılamaz';
                      }
                      return null;
                    },
                    obscureText: true,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.pinkAccent, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.pinkAccent, width: 2)),
                        hintText: 'Şifre ',
                        hintStyle: TextStyle(color: Colors.white),
                        icon: Icon(Icons.key)),
                  ),

                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: _girisYap,
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                            horizontal: 100, vertical: 20)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.pinkAccent)),
                    child: Text(
                      'Giriş Yap',
                      style: TextStyle(
                          color: Colors.white, letterSpacing: 2, fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: ((context) {
                        return Register();
                      })));
                    },
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                            horizontal: 100, vertical: 20)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.pinkAccent)),
                    child: Text(
                      'Hesap Oluştur',
                      style: TextStyle(
                          color: Colors.white, letterSpacing: 2, fontSize: 10),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _googleIleGiris();
                    },
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                            horizontal: 100, vertical: 20)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.pinkAccent)),
                    child: Text(
                      'veya GOOGLE ile Devam Et',
                      style: TextStyle(
                          color: Colors.white, letterSpacing: 2, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void _girisYap() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    if (_formAnahtari.currentState.validate()) {
      _formAnahtari.currentState?.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        await _yetkilendirmeServisi.mailIleGiris(email, sifre);
        Navigator.push(
            context, MaterialPageRoute(builder: ((context) => Yonlendirme())));
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: hata.hashCode);
      }
    }
  }

  void _googleIleGiris() async {
    var _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    setState(() {
      yukleniyor = true;
    });
    try {
      Kullanici kullanici = await _yetkilendirmeServisi.googleIleGiris();
      if (kullanici != null) {
        Kullanici firestoreKullanici =
            await FirestoreServisi().kullaniciGetir(kullanici.id);
        if (firestoreKullanici == null) {
          FirestoreServisi().kullaniciOlustur(
            id: kullanici.id,
            email: kullanici.email,
            kullaniciAdi: kullanici.kullaniciAdi,
            fotoUrl: kullanici.fotoUrl,
          );
        }
      }
    } catch (hata) {
      setState(() {
        yukleniyor = false;
      });
      uyariGoster(hataKodu: hata.hashCode);
    }
  }
  //uyarı göster methodunda hata var

  uyariGoster({hataKodu}) {
    String hataMesaji;

    if (hataKodu == "user-not-found") {
      hataMesaji = "Böyle bir kullanıcı bulunmuyor";
    } else if (hataKodu == "invalid-email") {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir";
    } else if (hataKodu == "ERROR_WRONG_PASSWORD") {
      hataMesaji = "Girilen şifre hatalı";
    } else if (hataKodu == "user-disabled") {
      hataMesaji = "Kullanıcı engellenmiş";
    } else {
      hataMesaji = "Tanımlanamayan bir hata oluştu $hataKodu";
    }
    var snackBar = SnackBar(content: Text(hataMesaji));
//yeni kullanım
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
