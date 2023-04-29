import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:news/screens/home/components/yoreselSozluk.dart';
import 'package:news/services/firestoreSrvisi.dart';
import 'package:news/services/yetkilendirmeServisi.dart';
import 'package:provider/provider.dart';

class KelimeEkle extends StatefulWidget {
  const KelimeEkle({Key key}) : super(key: key);

  @override
  State<KelimeEkle> createState() => _KelimeEkleState();
}

class _KelimeEkleState extends State<KelimeEkle> {
  String kelime;
  String textKelime = '';
  bool yukleniyor = false;
  final formKey = GlobalKey<FormState>();
  QuillController _controller = QuillController.basic();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7
          
          ,
          child: ListView(children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Yöremize ait kelimeler ekleyerek yöresel sözlüğümüze destek olunuz',
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
                                labelText:
                                    'Eklemek İstediğiniz Kelimeyi Yazınız',
                                hintText: 'Kelime',
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.blue))),
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Kelime alanı boş bırakılamaz';
                              return null;
                            },
                            onSaved: (data) => kelime = data,
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
                            child: Text('Yayinlamaya Gönder'),
                            onPressed: () {
                              _saveFormData();

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => YoreselSozluk()));
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
        textKelime = kelime;
        yukleniyor = true;
      });

      FirestoreServisi().kelimeOlustur(
          kelime: textKelime,
          yayinlayaId: _aktifKullaniciId,
          aciklama: _controller.document.toPlainText());

      setState(() {
        yukleniyor = false;
      });
    }
  }
}
