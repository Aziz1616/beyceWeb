import 'package:cloud_firestore/cloud_firestore.dart';

//kazanımlar içinde bu yapıyı oluşturmam gerekli
class Kelime {
  final String id;
  final String kelime;
  final String yayinlayanId;
  final Timestamp olusturulmaZamani;
  final String aciklama;

  Kelime({this.id, this.kelime, this.yayinlayanId, this.olusturulmaZamani,this.aciklama});
  factory Kelime.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return Kelime(
      id: doc.id,
      kelime: doc['kelime'],
      yayinlayanId: doc['yayinlayanId'],
      olusturulmaZamani: doc['olusturulmaZamani'],
      aciklama:doc['aciklama'],
    );
  }
}
