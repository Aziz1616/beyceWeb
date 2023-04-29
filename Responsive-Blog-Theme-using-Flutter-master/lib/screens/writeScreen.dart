import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

import 'package:news/services/firestoreSrvisi.dart';

import 'package:news/services/yetkilendirmeServisi.dart';
import 'package:news/services/yonlendirme.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class WriteScreen extends StatefulWidget {
  WriteScreen({Key key}) : super(key: key);

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  FilePickerResult result;

  String blogResmiUrl;
 
  File dosya;
  bool yukleniyor = false;
  QuillController _controller = QuillController.basic();
  TextEditingController _textcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(children: [
            yukleniyor
                ? LinearProgressIndicator()
                : SizedBox(
                    height: 0,
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 100,
                backgroundImage: NetworkImage(
                  'https://cdn.pixabay.com/photo/2023/03/04/15/53/duck-7829778_960_720.jpg',
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                      onPressed: _photoSec, child: Text('Blog Resmi Yükle')),
                ),
                result == null
                    ? Icon(Icons.folder_off_outlined)
                    : Icon(
                        Icons.check,
                        color: Colors.blue,
                      ),
              ],
            ),
            TextField(
              controller: _textcontroller,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Blog Başlığı yazınız'),
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
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
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
                child:
                    QuillEditor.basic(controller: _controller, readOnly: false),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _openPicker,
                child: Text('Yayinlamaya Gönder'),
              ),
            ),
          ]),
        ),
      ),
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
          .child('resimler/blogYazilari/blogResim_$resimId.jpg');
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

  

    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;
    
    FirestoreServisi().blogYaziOlustur(
      blogResmiUrl: blogResmiUrl,
      baslik: _textcontroller.text,
      aciklama: _controller.document.toPlainText(),
      yayinlayaId: aktifKullaniciId,
    );

    setState(() {
      yukleniyor = false;
      _controller.clear();
      _textcontroller.clear();
    
    });
    Navigator.push(
        context, MaterialPageRoute(builder: ((context) => Yonlendirme())));
  }


}
