import 'package:cloud_firestore/cloud_firestore.dart';

class BlogYazi {
  final String id;
  final String baslik;
  final String blogResmiUrl;
  final String aciklama;
  final String yayinlayanId;
  final int begeniSayisi;
  final Timestamp olusturulmaZamani;

  BlogYazi(
      {this.id,
      this.baslik,
      this.blogResmiUrl,
      this.aciklama,
      this.yayinlayanId,
      this.begeniSayisi,
      this.olusturulmaZamani});

  factory BlogYazi.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return BlogYazi(
        id: doc.id,
        baslik: doc['baslik'],
        blogResmiUrl: doc['blogResmiUrl'],
        aciklama: doc['aciklama'],
        yayinlayanId: doc['yayinlayanId'],
        begeniSayisi: doc['begeniSayisi'],
        olusturulmaZamani: doc['olusturulmaZamani']);
  }
}
