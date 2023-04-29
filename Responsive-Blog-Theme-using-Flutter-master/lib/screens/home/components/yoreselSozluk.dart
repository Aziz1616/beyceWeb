import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:news/models/kelime.dart';
import 'package:news/models/kullanici.dart';
import 'package:news/screens/home/components/kelimeEkle.dart';
import 'package:news/screens/loginScreen.dart';
import 'package:news/screens/register.dart';
import 'package:news/services/firestoreSrvisi.dart';
import 'package:provider/provider.dart';

import '../../../services/yetkilendirmeServisi.dart';

class YoreselSozluk extends StatefulWidget {
  const YoreselSozluk({Key key}) : super(key: key);

  @override
  State<YoreselSozluk> createState() => _YoreselSozlukState();
}

class _YoreselSozlukState extends State<YoreselSozluk> {
  @override
  Widget build(BuildContext context) {
    String _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    return Scaffold(
      appBar:
          AppBar(leading: SizedBox(height: 0), title: Text('Yöresel sözlük')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_aktifKullaniciId == null) {
            _ShowDialog();
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => KelimeEkle()));
          }
        },
        child: Icon(
          Icons.add,
        ),
      ),
      body: ListView(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.7
              ,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                        stream: FirestoreServisi().kelimeGetir(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox();
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              Kelime kelime = Kelime.dokumandanUret(
                                  snapshot.data.docs[index]);
                              return FutureBuilder(
                                  future: FirestoreServisi()
                                      .kullaniciGetir(kelime.yayinlayanId),
                                  builder: (context, snapShot) {
                                    if (!snapShot.hasData) {
                                      return SizedBox();
                                    }
                                    Kullanici kelimeSahibi = snapShot.data;
                                    return Card(
                                      child: ListTile(
                                        leading: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Yayınlayan :' +
                                              kelimeSahibi.kullaniciAdi),
                                        ),
                                        title: Text(
                                          kelime.kelime,
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold),
                                          textScaleFactor: 1.1,
                                        ),
                                        subtitle: Text(kelime.aciklama),
                                        onTap: () {},
                                      ),
                                    );
                                  });
                            },
                          );
                        })
                  ]),
            ),
          ],
        )
      ]),
    );
  }

  // ignore: non_constant_identifier_names
  _ShowDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Lütfen Önce Giriş Yapınız'),
            children: [
              SimpleDialogOption(
                child: Text('Giriş Yap'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
              SimpleDialogOption(
                child: Text('Üye Ol'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Register()));
                },
              ),
              SimpleDialogOption(
                child: Text('Kapat'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
