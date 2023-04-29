import 'package:cloud_firestore/cloud_firestore.dart';

class Gezilecek {
  final String id;
  final String baslik;
  final String resimUrl;
  final String resimUrl2;
  final String resimUrl3;
  final String resimUrl4;
  final String aciklama;
  final String aciklama2;
  final String aciklama3;
  final String aciklama4;
  final String aciklama5;
  final String yayinlayanId;
  final Timestamp olusturulmaZamani;

  Gezilecek(
      {this.id,
      this.baslik,
      this.resimUrl,
      this.aciklama,
      this.yayinlayanId,
      this.olusturulmaZamani,
      this.resimUrl2,
      this.resimUrl3,
      this.resimUrl4,
      this.aciklama2,
      this.aciklama3,
      this.aciklama4,
      this.aciklama5});

  factory Gezilecek.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return Gezilecek(
        id: doc.id,
        baslik: doc['baslik'],
        resimUrl: doc['resimUrl'],
        aciklama: doc['aciklama'],
        aciklama2: doc['aciklama2'],
        aciklama3: doc['aciklama3'],
        aciklama4: doc['aciklama4'],
        aciklama5: doc['aciklama5'],
        yayinlayanId: doc['yayinlayanId'],
        resimUrl2: doc['resimUrl2'],
        resimUrl3: doc['resimUrl3'],
        resimUrl4: doc['resimUrl4'],
        olusturulmaZamani: doc['olusturulmaZamani']);
  }
}
