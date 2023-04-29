import 'package:flutter/material.dart';
import 'package:news/services/firestoreSrvisi.dart';
import 'package:provider/provider.dart';

import '../models/kullanici.dart';
import '../services/yetkilendirmeServisi.dart';

class Register extends StatefulWidget {
  const Register({Key key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  bool yukleniyor = false;
  String email = '';
  String sifre = '';
  String kullaniciAdi = '';
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
                  Text('Geleceğin mimarları'),
                  SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    onChanged: (girilenDeger) {
                      kullaniciAdi = girilenDeger;
                    },
                    validator: (girilenDeger) {
                      if (girilenDeger.isEmpty) {
                        return 'Kullanıcı Adı boş bırakılamaz';
                      }
                      return null;
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
                        hintText: 'Kullanıcı Adı ',
                        hintStyle: TextStyle(color: Colors.white),
                        icon: Icon(Icons.person)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
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
                      } else if (girilenDeger.trim().length < 6) {
                        return 'Şİfre en az 6 karekater olmalı';
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
                    onPressed: () => _kullaniciOlustur(),
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                            horizontal: 100, vertical: 20)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.pinkAccent)),
                    child: Text(
                      'Hesap Oluştur',
                      style: TextStyle(
                          color: Colors.white, letterSpacing: 2, fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                            horizontal: 100, vertical: 20)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.pinkAccent)),
                    child: Text(
                      'veya GOOGLE ile Devam Et',
                      style: TextStyle(
                          color: Colors.white, letterSpacing: 2, fontSize: 16),
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

  void _kullaniciOlustur() async {
    final _yetkilendirmeServisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    var _formState = _formAnahtari.currentState;
    if (_formState.validate()) {
      _formState.save();

      setState(() {
        yukleniyor = true;
      });

      try {
        Kullanici kullanici =
            await _yetkilendirmeServisi.mailIleKayit(email, sifre);
        if (kullanici != null) {
          FirestoreServisi().kullaniciOlustur(
              id: kullanici.id, email: email, kullaniciAdi: kullaniciAdi);
        }
        Navigator.pop(context);
      } catch (hata) {
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: hata.hashCode);
      }
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;

    if (hataKodu == "invalid-email") {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir";
    } else if (hataKodu == "ERROR_EMAIL_ALREADY_IN_USE") {
      hataMesaji = "Girdiğiniz mail kayıtlıdır";
    } else if (hataKodu == "ERROR_WEAK_PASSWORD") {
      hataMesaji = "Daha zor bir şifre tercih edin";
    } else {
      hataMesaji = "Tanımlanamayan bir hata oluştu $hataKodu";
    }
    var snackBar = SnackBar(content: Text(hataMesaji));
//yeni kullanım
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
