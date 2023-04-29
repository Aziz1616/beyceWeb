import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:news/models/gezilecek.dart';
import 'package:news/services/firestoreSrvisi.dart';

class GezileceklerSayfasi extends StatefulWidget {
  const GezileceklerSayfasi({Key key}) : super(key: key);

  @override
  State<GezileceklerSayfasi> createState() => _GezileceklerSayfasiState();
}

class _GezileceklerSayfasiState extends State<GezileceklerSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(shrinkWrap: true, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreServisi().gezilecekGetir(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                }

                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      Gezilecek gezilecek = Gezilecek.dokumandanUret(
                        snapshot.data.docs[index],
                      );
                      return gezilecekSatiri(gezilecek, context);
                    });
              },
            ),
          ),
        ]),
      ]),
    );
  }

  Column gezilecekSatiri(Gezilecek gezilecek, BuildContext context) {
    return Column(
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ImageNetwork(
                image: gezilecek.resimUrl,
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.5),
          ),
        ),
        ListTile(
          title: Text(
            gezilecek.baslik,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 30,
                fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '         ' + gezilecek.aciklama,
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
        ),
        Container(
          
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ImageNetwork(
                image: gezilecek.resimUrl,
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '           ' + gezilecek.aciklama2,
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
      ],
    );
  }
}
