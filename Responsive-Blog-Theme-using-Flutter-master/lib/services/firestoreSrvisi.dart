import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news/models/anket.dart';
import 'package:news/models/blogYazi.dart';

import '../models/kullanici.dart';

class FirestoreServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime zaman = DateTime.now();
  Future<void> kullaniciOlustur({
    id,
    email,
    kullaniciAdi,
    fotoUrl = '',
  }) async {
    await _firestore.collection('kullanicilar').doc(id).set({
      'kullaniciAdi': kullaniciAdi,
      'email': email,
      'fotoUrl': fotoUrl,
      'hakkinda': '',
      'olusturulmaZamani': zaman,
    });
  }

//eğer kullanıc daha önceden giriş yaptıysa aynı kullanıcıyı tekrardan
//kullanıcılar verisine kayıt yaptırmamak gerekir bunun için
//kullanıcıları getir öethodu çağırılır
  Future<Kullanici> kullaniciGetir(id) async {
    DocumentSnapshot doc =
        await _firestore.collection('kullanicilar').doc(id).get();
    if (doc.exists) {
      Kullanici kullanici = Kullanici.dokumandanUret(doc);
      return kullanici;
    }
    return null;
  }

  void kullaniciGuncelle({
    String kullaniciId,
    String kullaniciAdi,
    String fotoUrl = '',
    //String hakkinda,
  }) {
    _firestore.collection('kullanicilar').doc(kullaniciId).update({
      'kullaniciAdi': kullaniciAdi,
      //'hakkinda': hakkinda,
      'fotoUrl': fotoUrl,
    });
  }

  Future<List<Kullanici>> kullaniciAra(String kelime) async {
    QuerySnapshot snapshot = await _firestore
        .collection('kullanicilar')
        .where('kullaniciAdi', isGreaterThanOrEqualTo: kelime)
        .get();
    List<Kullanici> kullanicilar =
        snapshot.docs.map((doc) => Kullanici.dokumandanUret(doc)).toList();
    return kullanicilar;
  }

  Future<void> blogYaziOlustur(
      {blogResmiUrl, aciklama, yayinlayaId, baslik}) async {
    await _firestore.collection('blogYazilari').add({
      'blogResmiUrl': blogResmiUrl,
      'aciklama': aciklama,
      'yayinlayanId': yayinlayaId,
      'begeniSayisi': 0,
      'baslik': baslik,
      'olusturulmaZamani': zaman
    });
  }

  Future<List<BlogYazi>> profilBloglari(aktifKullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('blogYazilari')
        .where('yayinlayanId', isEqualTo: aktifKullaniciId)
        //.orderBy('olusturulmaZamani',descending: true)
        .get();
    List<BlogYazi> profilBloglari =
        snapshot.docs.map((doc) => BlogYazi.dokumandanUret(doc)).toList();
    return profilBloglari;
  }

  Stream<QuerySnapshot> tumBlogYaziGetir() {
    return _firestore
        .collection('blogYazilari')
        .orderBy('olusturulmaZamani', descending: true)
        .snapshots();
  }

  Future<void> blogyaziSil(blogId) {
    return _firestore.collection('blogYazilari').doc(blogId).delete();
  }

  Stream<QuerySnapshot> gezilecekGetir() {
    return _firestore
        .collection('gezilecek')
        .orderBy('olusturulmaZamani', descending: true)
        .snapshots();
  }

  void duyuruEkle(
      {String aktiviteYapanId,
      String profilSahibiId,
      String aktiviteTipi,
      String yorum,
      BlogYazi blogYazi}) {
    if (aktiviteYapanId == profilSahibiId) {
      return;
    }

    _firestore
        .collection('duyurular')
        .doc(profilSahibiId)
        .collection('kullanicininDuyurulari')
        .add({
      'aktiviteYapanId': aktiviteYapanId,
      'aktiviteTipi': aktiviteTipi,
      'gonderiId': blogYazi?.id,
      'gonderiFoto': blogYazi?.blogResmiUrl,
      'yorum': yorum,
      'olusturulmaZamani': zaman,
    });
  }

  tumblogBegen(BlogYazi blogYazi, String aktifKullaniciId) async {
    DocumentReference docRef =
        _firestore.collection('blogYazilari').doc(blogYazi.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      BlogYazi blogYazi = BlogYazi.dokumandanUret(doc);
      int yeniBegeniSayisi = blogYazi.begeniSayisi + 1;
      await docRef.update({'begeniSayisi': yeniBegeniSayisi});

      //Kulanıcı beğeni ilişkisini tutabilmek için
      //firestore da begeniler koleksiyonu oluşturdum
      _firestore
          .collection('begeniler')
          .doc(blogYazi.id)
          .collection('blogBegenileri')
          .doc(aktifKullaniciId)
          .set({});
      //Begeni haberini sahibine yollamalıyız
      duyuruEkle(
        aktiviteTipi: 'begeni',
        aktiviteYapanId: aktifKullaniciId,
        blogYazi: blogYazi,
        profilSahibiId: blogYazi.yayinlayanId,
      );
    }
  }

  Future<bool> begenivarmi(BlogYazi blogYazi, String aktifKullaniciId) async {
    DocumentSnapshot docBegeni = await _firestore
        .collection('begeniler')
        .doc(blogYazi.id)
        .collection('blogBegenileri')
        .doc(aktifKullaniciId)
        .get();
    if (docBegeni.exists) {
      return true;
    }
    return false;
  }

  tumblogBegeniKaldir(BlogYazi blogYazi, String aktifKullaniciId) async {
    DocumentReference docRef =
        _firestore.collection('blogYazilari').doc(blogYazi.id);
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      BlogYazi blogYazi = BlogYazi.dokumandanUret(doc);
      int yeniBegeniSayisi = blogYazi.begeniSayisi - 1;
      await docRef.update({'begeniSayisi': yeniBegeniSayisi});

      //beğeniyi sileceğimiz kodlar burada çalışacak
      DocumentSnapshot docBegeni = await _firestore
          .collection('begeniler')
          .doc(blogYazi.id)
          .collection('blogBegenileri')
          .doc(aktifKullaniciId)
          .get();
      if (docBegeni.exists) {
        docBegeni.reference.delete();
      }
    }
  }

  Future<int> begeniSayisi(blogId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("begeniler")
        .doc(blogId)
        .collection("blogBegenileri")
        .get();
    return snapshot.docs.length;
  }

  yorumEkle({String aktifKullaniciId, BlogYazi blogYazi, String icerik}) {
    _firestore
        .collection('yorumlar')
        .doc(blogYazi.id)
        .collection('blogYorumlari')
        .add({
      'icerik': icerik,
      'yayinlayanId': aktifKullaniciId,
      'olusturulmaZamani': zaman,
    });
    //yorum duyurusunu gonderi sahibine iletmeliyiz

    duyuruEkle(
        aktiviteTipi: 'yorum',
        aktiviteYapanId: aktifKullaniciId,
        blogYazi: blogYazi,
        profilSahibiId: blogYazi.yayinlayanId,
        yorum: icerik);
  }

  Stream<QuerySnapshot> yorumlariGetir(String blogId) {
    return _firestore
        .collection('yorumlar')
        .doc(blogId)
        .collection('blogYorumlari')
        .orderBy('olusturulmaZamani', descending: true)
        .snapshots();
  }

  Future<BlogYazi> tekliBlogGetir(
      String blogyaziId, String blogSahibiId) async {
    DocumentSnapshot doc = await _firestore
        .collection('blogYazilari')
        .doc(blogyaziId)
        .collection('kullanicilarinBlogYazilari')
        .doc(blogSahibiId)
        .get();
    BlogYazi blogYazi = BlogYazi.dokumandanUret(doc);
    return blogYazi;
  }

  Future<void> kelimeOlustur({
    aciklama,
    kelime,
    yayinlayaId,
  }) async {
    await _firestore.collection('kelimeler').add({
      'yayinlayanId': yayinlayaId,
      'kelime': kelime,
      'olusturulmaZamani': zaman,
      'aciklama': aciklama,
    });
  }

  Stream<QuerySnapshot> kelimeGetir() {
    return _firestore
        .collection('kelimeler')
        .orderBy('olusturulmaZamani', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> anketGetir() {
    return _firestore
        .collection('anketler')
        .orderBy('olusturulmaZamani', descending: true)
        .snapshots();
  }

  anketVote1SayiDegistir(Anket anket, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore.collection('anketler').doc(anket.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Anket anket = Anket.dokumandanUret(doc);
      int yeniVote1 = anket.vote1 + 1;

      await docRef.update({
        'vote1': yeniVote1,
      });

      //Kulanıcı beğeni ilişkisini tutabilmek için
      //firestore da begeniler koleksiyonu oluşturdum
      _firestore
          .collection('sonuclar')
          .doc(anket.id)
          .collection('anketSonuclari')
          .doc(aktifKullaniciId)
          .set({});
    }
  }
   anketVote2SayiDegistir(Anket anket, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore.collection('anketler').doc(anket.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Anket anket = Anket.dokumandanUret(doc);
      int yeniVote2 = anket.vote2 + 1;

      await docRef.update({
        'vote2': yeniVote2,
      });

      //Kulanıcı beğeni ilişkisini tutabilmek için
      //firestore da begeniler koleksiyonu oluşturdum
      _firestore
          .collection('sonuclar')
          .doc(anket.id)
          .collection('anketSonuclari')
          .doc(aktifKullaniciId)
          .set({});
    }
  }
   anketVote3SayiDegistir(Anket anket, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore.collection('anketler').doc(anket.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Anket anket = Anket.dokumandanUret(doc);
      int yeniVote3 = anket.vote3 + 1;

      await docRef.update({
        'vote3': yeniVote3,
      });

      //Kulanıcı beğeni ilişkisini tutabilmek için
      //firestore da begeniler koleksiyonu oluşturdum
      _firestore
          .collection('sonuclar')
          .doc(anket.id)
          .collection('anketSonuclari')
          .doc(aktifKullaniciId)
          .set({});
    }
  }
   anketVote4SayiDegistir(Anket anket, String aktifKullaniciId) async {
    DocumentReference docRef = _firestore.collection('anketler').doc(anket.id);

    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Anket anket = Anket.dokumandanUret(doc);
      int yeniVote4 = anket.vote4 + 1;

      await docRef.update({
        'vote1': yeniVote4,
      });

      //Kulanıcı beğeni ilişkisini tutabilmek için
      //firestore da begeniler koleksiyonu oluşturdum
      _firestore
          .collection('sonuclar')
          .doc(anket.id)
          .collection('anketSonuclari')
          .doc(aktifKullaniciId)
          .set({});
    }
  }

  Future<bool> oyVarmi(Anket anket, String aktifKullaniciId) async {
    DocumentSnapshot docVote1 = await _firestore
        .collection('sonuclar')
        .doc(anket.id)
        .collection('anketSonuclari')
        .doc(aktifKullaniciId)
        .get();
    if (docVote1.exists) {
      return true;
    }
    return false;
  }

  Future<int> oySayisi(anketId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("sonuclar")
        .doc(anketId)
        .collection("anketSonuclari")
        .get();
    return snapshot.docs.length;
  }

    Future<void> iletisim({
    aciklama,
    baslik,
    yayinlayaId,
  }) async {
    await _firestore.collection('iletisim').add({
      'yayinlayanId': yayinlayaId,
      'baslik': baslik,
      'olusturulmaZamani': zaman,
      'aciklama': aciklama,
    });
  }
}
