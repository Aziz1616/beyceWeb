import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:news/models/anket.dart';
import 'package:news/screens/home/components/oyKullan.dart';
import 'package:news/services/firestoreSrvisi.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import '../../../services/yetkilendirmeServisi.dart';
import '../../loginScreen.dart';
import '../../register.dart';

class Anketler extends StatefulWidget {
  const Anketler({Key key}) : super(key: key);

  @override
  State<Anketler> createState() => _AnketlerState();
}

double vote1;
double vote2;
double vote3;
double vote4;
double voteToplam = vote1 + vote2 + vote3 + vote4;
double v1y = 100 * vote1 / voteToplam;
double v2y = 100 * vote2 / voteToplam;
double v3y = 100 * vote3 / voteToplam;
double v4y = 100 * vote4 / voteToplam;

Map<String, double> dataMap = {
  'Recep Tayyip Erdoğan': vote1,
  'Kemal Kılıçtaroğlu': vote2,
  'Sinan Oğan': vote3,
  'Muharrem İnce': vote4,
};
String _aktifKullaniciId;

List<Color> colorList = [
  Colors.amber,
  Colors.blue,
  Colors.red,
  Colors.black,
];

class _AnketlerState extends State<Anketler> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: SizedBox(height: 0),
          title: Text('2023 Cumhurbaşkanlığı Seçim Anketi')),
      body: ListView(shrinkWrap: true, children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreServisi().anketGetir(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                }
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      Anket anket =
                          Anket.dokumandanUret(snapshot.data.docs[index]);
                      vote1 = anket.vote1.toDouble();
                      vote2 = anket.vote2.toDouble();
                      vote3 = anket.vote3.toDouble();
                      vote4 = anket.vote4.toDouble();
                      print(v1y.toString());

                      return ListView(
                        shrinkWrap: true,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                anket.aciklama + '!',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                          Center(
                            child: PieChart(
                              //totalValue: voteToplam,
                              dataMap: dataMap,
                              colorList: colorList,
                              chartRadius:
                                  MediaQuery.of(context).size.width * 0.3,
                              centerText: 'Sonuçlar',
                            ),
                          ),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  '2023 Cumhur başkanlığı seçiminde oyunuzu kime atacaksınız?',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      'Recep Tayyip ERDOĞAN',
                                      style: TextStyle(
                                          color: Colors.amber,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Kemal KILIÇTAROĞLU',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Sinan OĞAN',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Muharrem İNCE',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      '% ' + v1y.toStringAsFixed(2),
                                      style: TextStyle(color: Colors.amber),
                                    ),
                                    Text(
                                      '% ' + v2y.toStringAsFixed(2),
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    Text(
                                      '% ' + v3y.toStringAsFixed(2),
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    Text(
                                      '% ' + v4y.toStringAsFixed(2),
                                      style: TextStyle(color: Colors.black),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 50,
                                ),
                                TextButton(
                                    onPressed: () {
                                      if (_aktifKullaniciId == null) {
                                        _ShowDialog();
                                      } else
                                        return Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => OyKullan(
                                                      anket: anket,
                                                    )));
                                    },
                                    child: Text(
                                      'Ankete Katıl',
                                      style: TextStyle(fontSize: 25),
                                    ))
                              ],
                            ),
                          ),
                        ],
                      );
                    });
              }),
        )
      ]),
    );
  }

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
