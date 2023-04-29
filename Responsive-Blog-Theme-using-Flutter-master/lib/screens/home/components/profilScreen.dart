import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_network/image_network.dart';
import 'package:news/models/blogYazi.dart';
import 'package:news/screens/home/components/singleBlogPost.dart';
import 'package:news/services/yetkilendirmeServisi.dart';
import 'package:news/services/yonlendirme.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';
import '../../../constants.dart';
import '../../../models/kullanici.dart';
import '../../../responsive.dart';
import '../../../services/firestoreSrvisi.dart';

class ProfilScreen extends StatefulWidget {
  final String profilSahibiId;
  const ProfilScreen({Key key, this.profilSahibiId}) : super(key: key);

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  TextEditingController _textcontroller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    timeago.setLocaleMessages('tr', timeago.TrMessages());
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    //_begeniSayisi = profilBloglari.begeniSayisi;
    // begeniVarmi();
  }

  begeniVarmi() async {
    bool begeniVarmi =
        await FirestoreServisi().begenivarmi(profilBloglari, _aktifKullaniciId);
    if (begeniVarmi) {
      if (mounted) {
        setState(() {
          _begendin = true;
        });
      }
    }
  }

  _profilicek() {
    return FutureBuilder(
      future: FirestoreServisi().kullaniciGetir(widget.profilSahibiId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }
        profilSahibi = snapshot.data;

        return _profilSatiri();
      },
    );
  }

  _profilSatiri() {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    return Column(
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ImageNetwork(
              onLoading: const CircularProgressIndicator(),
              borderRadius: BorderRadius.all(Radius.circular(20)),
              fitWeb: BoxFitWeb.cover,
              image: result != null ? blogResmiUrl : profilSahibi.fotoUrl,
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.4,
            ),
          ),
        ),
        profilSahibi.id == aktifKullaniciId ? _profilResimButton() : SizedBox(),
        profilSahibi.id == aktifKullaniciId
            ? _kullaniciAdiButton()
            : SizedBox(),
        profilSahibi.id == aktifKullaniciId
            ? _kaydetButton()
            : Text(profilSahibi.kullaniciAdi + '  Adlı kullanıcını Profili'),
        Divider(
          height: 5,
        )
      ],
    );
  }

  _kaydetButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
          onPressed: () {
            _openPicker();
          },
          child: Text('Kaydet')),
    );
  }

  _kullaniciAdiButton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      child: TextField(
        controller: _textcontroller,
        decoration: InputDecoration(
            border: OutlineInputBorder(), labelText: profilSahibi.kullaniciAdi),
      ),
    );
  }

  _profilResimButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: OutlinedButton(
              onPressed: _photoSec, child: Text('Profil Resmi Yükle')),
        ),
        result == null
            ? Icon(Icons.folder_off_outlined)
            : Icon(
                Icons.check,
                color: Colors.blue,
              ),
      ],
    );
  }

  _photoSec() async {
    String resimId;
    result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png']);
    if (result != null) {
      Uint8List uploudFile = result.files.single.bytes;
      resimId = Uuid().v4();

      Reference reference = FirebaseStorage.instance
          .ref()
          .child('resimler/profilResimleri/blogResim_$resimId.jpg');
      UploadTask uploadTask = reference.putData(uploudFile);

      uploadTask.whenComplete(() async {
        final String imageUrl = await uploadTask.snapshot.ref.getDownloadURL();

        setState(() {
          blogResmiUrl = imageUrl;
        });
      });
    }

    setState(() {
      result = result;
    });
  }

  void _openPicker() async {
    print(blogResmiUrl);
    if (!yukleniyor) {
      setState(() {
        yukleniyor = true;
      });
    }

    FirestoreServisi().kullaniciGuncelle(
        kullaniciAdi: _textcontroller.text,
        kullaniciId: profilSahibi.id,
        fotoUrl: blogResmiUrl);

    setState(() {
      yukleniyor = false;
      _textcontroller.clear();
    });
    Navigator.push(
        context, MaterialPageRoute(builder: ((context) => Yonlendirme())));
  }

  Kullanici profilSahibi;
  String blogResmiUrl;
  BlogYazi profilBloglari;
  String text = 'Devamı';
  int maxLines = 4;
  FilePickerResult result;
  bool yukleniyor = false;
  int _begeniSayisi = 0;
  bool _begendin = false;
  String _aktifKullaniciId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            child: _profilicek(),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FutureBuilder<List<BlogYazi>>(
                    future: FirestoreServisi()
                        .profilBloglari(widget.profilSahibiId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox();
                      }
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            if (!snapshot.hasData) {
                              return SizedBox();
                            }
                            profilBloglari = snapshot.data[index];
                            _begeniSayisi = profilBloglari.begeniSayisi;

                            return bloglarSatiri(context, profilBloglari);
                          });
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding bloglarSatiri(BuildContext context, BlogYazi profilBloglari) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Container(
        decoration: BoxDecoration(border: Border.all()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1.78,
              child: ImageNetwork(
                fitWeb: BoxFitWeb.cover,
                image: profilBloglari.blogResmiUrl,
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.5,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(profilSahibi.kullaniciAdi),
                      Text(
                        timeago.format(
                            profilBloglari.olusturulmaZamani.toDate(),
                            locale: 'tr'),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      _aktifKullaniciId == widget.profilSahibiId
                          ? IconButton(
                              onPressed: () async {
                                return showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        title: Text('Silinsin mi?'),
                                        children: [
                                          SimpleDialogOption(
                                            child: Text('Sil'),
                                            onPressed: () async {
                                              await FirestoreServisi()
                                                  .blogyaziSil(
                                                      profilBloglari.id);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfilScreen(
                                                            profilSahibiId: widget
                                                                .profilSahibiId,
                                                          )));
                                            },
                                          ),
                                          SimpleDialogOption(
                                            child: Text('İptal'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                              icon: Icon(Icons.delete))
                          : SizedBox()
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: kDefaultPadding),
                    child: Text(
                      profilBloglari.baslik,
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
                    profilBloglari.aciklama,
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
                              bottom:
                                  BorderSide(color: kPrimaryColor, width: 3),
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SingleBlogPost(
                                        blogYazi: profilBloglari,
                                        yayinlayan: profilSahibi,
                                      )));
                        },
                      ),
                      Text(
                        _begeniSayisi.toString(),
                        textAlign: TextAlign.justify,
                      ),
                      // Text(profilBloglari.id),
                      IconButton(
                        icon: SvgPicture.asset(
                            "assets/icons/feather_message-square.svg"),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SingleBlogPost(
                                        blogYazi: profilBloglari,
                                        yayinlayan: profilSahibi,
                                      )));
                        },
                      ),
                      IconButton(
                        icon: SvgPicture.asset(
                            "assets/icons/feather_share-2.svg"),
                        onPressed: () {
                          //ShowDialog();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _yukleniyor() {
    return yukleniyor == true ? LinearProgressIndicator() : null;
  }
}
