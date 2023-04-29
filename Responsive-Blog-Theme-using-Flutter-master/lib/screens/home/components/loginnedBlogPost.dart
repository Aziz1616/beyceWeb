import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_network/image_network.dart';
import 'package:news/constants.dart';
import 'package:news/models/blogYazi.dart';
import 'package:news/models/kullanici.dart';
import 'package:news/responsive.dart';
import 'package:news/screens/home/components/singleBlogPost.dart';
import 'package:news/services/firestoreSrvisi.dart';
import 'package:news/services/yetkilendirmeServisi.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' as timeago;

class LoginnedBlogPostDart extends StatefulWidget {
  final BlogYazi blogYazi;

  const LoginnedBlogPostDart({
    Key key,
    this.blogYazi,
  }) : super(key: key);

  @override
  State<LoginnedBlogPostDart> createState() => _LoginnedBlogPostDartState();
}

class _LoginnedBlogPostDartState extends State<LoginnedBlogPostDart> {
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
    return ListView(
      shrinkWrap: true,
      children: [
        FutureBuilder(
          future:
              FirestoreServisi().kullaniciGetir(widget.blogYazi.yayinlayanId),
          builder: (context, snapShot) {
            if (!snapShot.hasData) {
              return SizedBox();
            }
            Kullanici blogSahibi = snapShot.data;
            print(blogSahibi.kullaniciAdi + '   blog sahibi kullanıcı adı');
            return blogCard(context, blogSahibi);
          },
        ),
      ],
    );
  }

  Padding blogCard(BuildContext context, Kullanici blogSahibi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.78,
            // Image.network(src)

            child: ImageNetwork(
              fitWeb: BoxFitWeb.cover,
              image: widget.blogYazi.blogResmiUrl,
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.4,
            ),
          ),
          Container(
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
                  children: [
                    Text(
                      "Design".toUpperCase(),
                      style: TextStyle(
                        color: kDarkBlackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: kDefaultPadding),
                    Text(
                      timeago.format(widget.blogYazi.olusturulmaZamani.toDate(),
                          locale: 'tr'),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: kDefaultPadding),
                  child: Text(
                    widget.blogYazi.baslik,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Responsive.isDesktop(context) ? 32 : 24,
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
                        padding: EdgeInsets.only(bottom: kDefaultPadding / 4),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: kPrimaryColor, width: 3),
                          ),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(color: kDarkBlackColor),
                        ),
                      ),
                    ),
                    Spacer(),
                    TextButton(
                        onPressed: () {},
                        child: Text('Yayınlayan : ' + blogSahibi.kullaniciAdi)),
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SingleBlogPost(
                                      yayinlayan: blogSahibi,
                                      blogYazi: widget.blogYazi,
                                    )));
                      },
                    ),
                    IconButton(
                      icon:
                          SvgPicture.asset("assets/icons/feather_share-2.svg"),
                      onPressed: () {
                        Share.share(
                            'Bloğumu okurmusun at http://localhost:65107/#/');
                        _AlertshowDialog();
                      },
                    ),
                  ],
                ),
                yorumYaz != false ? _yorumYaz() : SizedBox(),
              ],
            ),
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
      // FirestoreServisi().blogBegeniKaldir(widget.blogYazi, _aktifKullaniciId);
      FirestoreServisi()
          .tumblogBegeniKaldir(widget.blogYazi, _aktifKullaniciId);
    } else {
      //kullanıcı begenmediyse beğenmesini sağlayacak kodları yazmalyız
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi + 1;
      });
      //FirestoreServisi().blogBegen(widget.blogYazi, _aktifKullaniciId);
      FirestoreServisi().tumblogBegen(widget.blogYazi, _aktifKullaniciId);
      print(_begeniSayisi);
    }
  }

  _yorumYaz() {
    return ListTile(
      title: TextFormField(
          validator: (_controller) {
            if (_controller.isEmpty) {
              return 'Yorum boş olamaz';
            } else {
              return null;
            }
          },
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
          _yorumGonder();
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
