import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:news/services/yonlendirme.dart';
import 'package:provider/provider.dart';

import '../../../services/firestoreSrvisi.dart';
import '../../../services/yetkilendirmeServisi.dart';
import '../../loginScreen.dart';
import '../../register.dart';

class Gelisim extends StatefulWidget {
  const Gelisim({Key key}) : super(key: key);

  @override
  State<Gelisim> createState() => _GelisimState();
}

class _GelisimState extends State<Gelisim> {
  String konu;
  String textKelime = '';
  bool yukleniyor = false;
  final formKey = GlobalKey<FormState>();
  QuillController _controller = QuillController.basic();
  String _aktifKullaniciId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          child: ListView(children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Bizlerle ilteşime geçerek gelişimimize yardımcı olabilirsniz',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ListView(shrinkWrap: true, children: [
              Form(
                  key: formKey,
                  child: Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.text_decrease),
                                labelText: 'Konu yazınız',
                                hintText: 'Konu',
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.blue))),
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Konu alanı boş bırakılamaz';
                              return null;
                            },
                            onSaved: (data) => konu = data,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: QuillToolbar.basic(
                            locale: Locale('tr'),
                            controller: _controller,
                            fontSizeValues: const {
                              'Small': '7',
                              'Medium': '20.5',
                              'Large': '40'
                            },
                            showAlignmentButtons: false,
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width * 0.5,
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Colors.lightBlueAccent,
                                offset: Offset(5.0, 5.0),
                                blurRadius: 10,
                                spreadRadius: 2),
                            BoxShadow(
                                color: Colors.white,
                                offset: Offset(
                                  0.0,
                                  0.0,
                                ),
                                blurRadius: 0,
                                spreadRadius: 0)
                          ]),
                          child: QuillEditor.basic(
                              controller: _controller, readOnly: false),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            child: Text(' Gönder'),
                            onPressed: () {
                              if (_aktifKullaniciId == null) {
                                _ShowDialog();
                              } else {
                                _saveFormData();
                                _ShowDialog2();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
            ]),
          ]),
        ),
      ),
    );
  }

  void _saveFormData() {
    String _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    if (formKey.currentState.validate()) {
      formKey.currentState.save();

      setState(() {
        textKelime = konu;
        yukleniyor = true;
      });

      FirestoreServisi().iletisim(
          baslik: textKelime,
          yayinlayaId: _aktifKullaniciId,
          aciklama: _controller.document.toPlainText());

      setState(() {
        yukleniyor = false;
      });
    }
  }

  _ShowDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Lütfen Önce Giriş Yapınız'),
            children: [
              SimpleDialogOption(
                child: Text('Giriş yap'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
              SimpleDialogOption(
                child: Text('Üye Ol'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Register()));
                },
              ),
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

  _ShowDialog2() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Bizimle iletişime geçtiğiniz için teşekkürler'),
            children: [
              SimpleDialogOption(
                child: Text('Kapat'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Yonlendirme()));
                },
              ),
            ],
          );
        });
  }
}
