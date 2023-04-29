import 'package:cloud_firestore/cloud_firestore.dart';

class Anket {
  final String id;
  final String baslik;
  final String aciklama;
  final int vote1;
  final int vote2;
  final int vote3;
  final int vote4;
  final int vote5;
  final int vote6;
  final int vote7;
  final int vote8;
  final int vote9;
  final int vote10;
  final Timestamp olusturulmaZamani;
  //final String kullananId;

  Anket(
      {this.id,
      this.baslik,
      this.vote1,
      this.vote2,
      this.vote3,
      this.vote4,
      this.vote5,
      this.vote6,
      this.vote7,
      this.vote8,
      this.vote9,
      this.vote10,
      this.aciklama,
      //this.kullananId,
      this.olusturulmaZamani});

  factory Anket.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return Anket(
        id: doc.id,
        baslik: doc['baslik'],
        aciklama: doc['aciklama'],
       // kullananId: doc['kullananId'],
        vote1: doc['vote1'],
        vote2: doc['vote2'],
        vote3: doc['vote3'],
        vote4: doc['vote4'],
        vote5: doc['vote5'],
        vote6: doc['vote6'],
        vote7: doc['vote7'],
        vote8: doc['vote8'],
        vote9: doc['vote9'],
        vote10: doc['vote10'],
        olusturulmaZamani: doc['olusturulmaZamani']);
  }
}
