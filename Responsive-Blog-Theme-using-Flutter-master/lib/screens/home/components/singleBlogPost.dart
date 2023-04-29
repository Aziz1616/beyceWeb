import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_network/image_network.dart';
import 'package:news/models/blogYazi.dart';
import 'package:news/models/kullanici.dart';
import 'package:news/models/yorum.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:news/services/firestoreSrvisi.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../responsive.dart';
import '../../../services/yetkilendirmeServisi.dart';

import 'package:universal_html/html.dart' as html;

class SingleBlogPost extends StatefulWidget {
  const SingleBlogPost({
    Key key,
    this.blogYazi,
    this.yayinlayan,
  }) : super(key: key);
  final BlogYazi blogYazi;
  final Kullanici yayinlayan;

  @override
  State<SingleBlogPost> createState() => _SingleBlogPostState();
}

class _SingleBlogPostState extends State<SingleBlogPost> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    _begeniSayisi = widget.blogYazi.begeniSayisi;
    begeniVarmi();
  }

  _yorumlaricek() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreServisi().yorumlariGetir(widget.blogYazi.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox();
          }
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                Yorum yorum = Yorum.dokumandanUret(snapshot.data.docs[index]);

                return FutureBuilder(
                    future:
                        FirestoreServisi().kullaniciGetir(yorum.yayinlayanId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox();
                      }
                      Kullanici yorumSahibi = snapshot.data;

                      return _yorumSatiri(yorum, yorumSahibi);
                    });
              });
        });
  }

  _yorumSatiri(Yorum yorum, Kullanici yorumSahibi) {
    return ListView(shrinkWrap: true, children: [
      Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                  backgroundImage: NetworkImage(yorumSahibi.fotoUrl)),
              title: Text(yorum.icerik),
              subtitle: Text(yorumSahibi.kullaniciAdi),
              trailing: Text(
                timeago.format(yorum.olusturulmaZamani.toDate(), locale: 'tr'),
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  begeniVarmi() async {
    bool begeniVarmi = await FirestoreServisi()
        .begenivarmi(widget.blogYazi, _aktifKullaniciId);
    if (begeniVarmi) {
      if (mounted) {
        setState(() {
          _begendin = true;
        });
      }
    }
  }

  int _begeniSayisi = 0;
  bool _begendin = false;
  String _aktifKullaniciId;
  int maxLines = 4;
  String text = 'Devamı';
  bool yorumYaz = false;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tekli Gnderi'),
      ),
      body: FutureBuilder(
          future: FirestoreServisi()
              .tekliBlogGetir(widget.blogYazi.id, widget.blogYazi.yayinlayanId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              //return SizedBox();
            }
            return ListView(
              children: [_blogCard(), _yorumlaricek()],
            );
          }),
    );
  }

  _blogCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Column(),
          Expanded(
            flex: 2,
            child: ListView(shrinkWrap: true, children: [
              Padding(
                padding: const EdgeInsets.only(bottom: kDefaultPadding),
                child: Column(
                  children: [
                    ImageNetwork(
                      fitWeb: BoxFitWeb.cover,
                      image: widget.blogYazi.blogResmiUrl,
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Container(
                      //height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width * 0.5,
                      padding: EdgeInsets.all(kDefaultPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "Design".toUpperCase(),
                                style: TextStyle(
                                  color: kDarkBlackColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                             // Text(
                               // widget.yayinlayan.kullaniciAdi,
                               // style: TextStyle(
                                //    color: Colors.black,
                                //    fontWeight: FontWeight.bold,
                                 //   fontSize: 12),
                             // ),
                              Text(
                                timeago.format(
                                    widget.blogYazi.olusturulmaZamani.toDate(),
                                    locale: 'tr'),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: kDefaultPadding),
                            child: Text(
                              widget.blogYazi.baslik,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize:
                                    Responsive.isDesktop(context) ? 32 : 24,
                                fontFamily: "Raleway",
                                color: kDarkBlackColor,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            widget.blogYazi.aciklama,
                            maxLines: maxLines,
                            style: TextStyle(height: 1.5),
                          ),
                          SizedBox(height: kDefaultPadding),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    if (text == 'Devamı') {
                                      maxLines = 1000;
                                      text = 'Küçült';
                                    } else {
                                      maxLines = 4;
                                      text = 'Devamı';
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      bottom: kDefaultPadding / 4),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: kPrimaryColor, width: 3),
                                    ),
                                  ),
                                  child: Text(
                                    text,
                                    style: TextStyle(color: kDarkBlackColor),
                                  ),
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                icon: SvgPicture.asset(
                                  "assets/icons/feather_thumbs-up.svg",
                                  color: !_begendin ? Colors.grey : Colors.red,
                                ),
                                onPressed: () {
                                  _begenidegistir();
                                },
                              ),
                              Text(
                                _begeniSayisi.toString(),
                                textAlign: TextAlign.justify,
                              ),
                              IconButton(
                                icon: SvgPicture.asset(
                                    "assets/icons/feather_message-square.svg"),
                                onPressed: () {
                                  setState(() {
                                    if (yorumYaz) {
                                      yorumYaz = false;
                                    } else {
                                      yorumYaz = true;
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: SvgPicture.asset(
                                    "assets/icons/feather_share-2.svg"),
                                onPressed: () {
                                  Share.share(
                                      'Bloğumu okurmusun at http://localhost:65107/#/');
                                  _AlertshowDialog();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: yorumYaz != false ? _yorumYaz() : SizedBox(),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _begenidegistir() {
    if (_begendin) {
      // Kullanıcı gonderiyi begendiyse begeniyi kaldıracak kodlar yazılmalı,
      setState(() {
        _begendin = false;
        _begeniSayisi = _begeniSayisi - 1;
      });
      //FirestoreServisi().blogBegeniKaldir(widget.blogYazi, _aktifKullaniciId);
      FirestoreServisi()
          .tumblogBegeniKaldir(widget.blogYazi, _aktifKullaniciId);
    } else {
      //kullanıcı begenmediyse beğenmesini sağlayacak kodları yazmalyız
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi + 1;
      });
      FirestoreServisi().tumblogBegen(widget.blogYazi, _aktifKullaniciId);
      // FirestoreServisi().blogBegen(widget.blogYazi, _aktifKullaniciId);
      print(_begeniSayisi);
    }
  }

  _yorumYaz() {
    return ListTile(
      title: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Yorum Yazınız',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          )),
      trailing: IconButton(
        icon: Icon(Icons.send),
        onPressed: () {
          _controller.value.text.isEmpty
              ? Text('Yorum boş Olamaz')
              : _yorumGonder();
        },
      ),
    );
  }

  void _yorumGonder() {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;

    FirestoreServisi().yorumEkle(
        aktifKullaniciId: aktifKullaniciId,
        blogYazi: widget.blogYazi,
        icerik: _controller.text);
    _controller.clear();
  }

  // ignore: non_constant_identifier_names
  void _AlertshowDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Bağlantınız kopyalandı"),
          //content: new Text("Alert Dialog body"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: new Text("Tamam"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

 
}
