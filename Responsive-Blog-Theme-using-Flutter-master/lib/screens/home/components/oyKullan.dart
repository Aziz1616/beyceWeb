import 'package:flutter/material.dart';
import 'package:news/screens/home/components/anketler.dart';
import 'package:provider/provider.dart';

import '../../../models/anket.dart';
import '../../../services/firestoreSrvisi.dart';
import '../../../services/yetkilendirmeServisi.dart';

class OyKullan extends StatefulWidget {
  final Anket anket;
  const OyKullan({Key key, this.anket}) : super(key: key);

  @override
  State<OyKullan> createState() => _OyKullanState();
}

class _OyKullanState extends State<OyKullan> {
  @override
  void initState() {
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;

    oyVarmi();
  }

  oyVarmi() async {
    bool begeniVarmi =
        await FirestoreServisi().oyVarmi(widget.anket, _aktifKullaniciId);
    if (begeniVarmi) {
      if (mounted) {
        setState(() {
          _kullandin = true;
        });
      }
    }
  }

  bool _kullandin = false;

  String _aktifKullaniciId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2023 Cumhurbaşkanlığı Seçim Anketi'),
        leading: SizedBox(height: 0),
      ),
      body: ListView(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(children: [
                Text(
                  '2023 Cumhurbaşkanlığı seçiminde oyunuzu hangi adaya vermek istersiniz?',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30,
                ),
                TextButton(
                    onPressed: () {
                      if (_kullandin == false) {
                        v1Kullan();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Anketler()));
                      } else
                        return _ShowDialog();
                    },
                    child: Text(
                      'Recep Tayyip ERDOĞAN',
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  height: 30,
                ),
                TextButton(
                    onPressed: () {
                      if (_kullandin == false) {
                        v2Kullan();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Anketler()));
                      } else
                        return _ShowDialog();
                    },
                    child: Text(
                      'Kemal KILIÇTAROĞLU',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  height: 30,
                ),
                TextButton(
                    onPressed: () async {
                      if (_kullandin == false) {
                        v3Kullan();
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Anketler()));
                        RefreshIndicatorState();
                      } else
                        return _ShowDialog();
                    },
                    child: Text(
                      'Sinan OĞAN',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  height: 30,
                ),
                TextButton(
                    onPressed: () {
                      if (_kullandin == false) {
                        v4Kullan();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Anketler()));
                      } else
                        return _ShowDialog();
                    },
                    child: Text(
                      'Muharrem İNCE',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  height: 30,
                ),
                Text(
                    'Not: Anket tamamen eğlence amaçlı olup hiçbir kurum veya kuruluş ile paylaşılmayacaktır.')
              ]),
            )
          ],
        ),
      ]),
    );
  }

  v1Kullan() {
    setState(() {
      _kullandin = true;
    });
    FirestoreServisi().anketVote1SayiDegistir(widget.anket, _aktifKullaniciId);
  }

  v2Kullan() {
    setState(() {
      _kullandin = true;
    });
    FirestoreServisi().anketVote2SayiDegistir(widget.anket, _aktifKullaniciId);
  }

  v3Kullan() {
    setState(() {
      _kullandin = true;
    });
    FirestoreServisi().anketVote3SayiDegistir(widget.anket, _aktifKullaniciId);
  }

  v4Kullan() {
    setState(() {
      _kullandin = true;
    });
    FirestoreServisi().anketVote4SayiDegistir(widget.anket, _aktifKullaniciId);
  }

  _ShowDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Daha önce kullandınız'),
            children: [
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
