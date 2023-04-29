import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:news/main.dart';
import 'package:news/screens/home/components/profilScreen.dart';

import 'package:news/screens/writeScreen.dart';
import 'package:news/services/yetkilendirmeServisi.dart';
import 'package:news/services/yonlendirme.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../responsive.dart';

class LoginnedSocal extends StatelessWidget {
  const LoginnedSocal({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PopupMenuItem _buildPopupMenuItem(String title) {
      String _aktifKullaniciId =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifKullaniciId;
      return PopupMenuItem(
        child: Column(children: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilScreen(
                              profilSahibiId: _aktifKullaniciId,
                            )));
              },
              child: Text('Profil')),
          TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WriteScreen()));
              },
              child: Text('BlogYaz')),
          TextButton(
              onPressed: () async {
                await Provider.of<YetkilendirmeServisi>(context, listen: false)
                    .cikisYap();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Yonlendirme()));
              },
              child: Text('Çıkış Yap'))
        ]),
      );
    }

    return Row(
      children: [
        // if (!Responsive.isMobile(context))
        //SvgPicture.asset("assets/icons/behance-alt.svg"),
        //if (!Responsive.isMobile(context))
        // Padding(
        // padding:
        //   const EdgeInsets.symmetric(horizontal: kDefaultPadding / 2),
        //child: SvgPicture.asset("assets/icons/feather_dribbble.svg"),
        // ),
        if (!Responsive.isMobile(context))
          SvgPicture.asset("assets/icons/feather_twitter.svg"),
        SizedBox(width: kDefaultPadding),
        PopupMenuButton(
            itemBuilder: (context) => [_buildPopupMenuItem('  ')],
            icon: Icon(
              Icons.person,
              color: Colors.blueAccent,
            ),
            offset: Offset(0.0, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ))
      ],
    );
  }
}
