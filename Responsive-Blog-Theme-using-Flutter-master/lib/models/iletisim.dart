import 'package:cloud_firestore/cloud_firestore.dart';

//kazanımlar içinde bu yapıyı oluşturmam gerekli
class Iletisim {
  final String id;
  final String baslik;
  final String yayinlayanId;
  final Timestamp olusturulmaZamani;
  final String aciklama;

  Iletisim(
      {this.id,
      this.baslik,
      this.yayinlayanId,
      this.olusturulmaZamani,
      this.aciklama});
  factory Iletisim.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return Iletisim(
      id: doc.id,
      baslik: doc['baslik'],
      yayinlayanId: doc['yayinlayanId'],
      olusturulmaZamani: doc['olusturulmaZamani'],
      aciklama: doc['aciklama'],
    );
  }
}
