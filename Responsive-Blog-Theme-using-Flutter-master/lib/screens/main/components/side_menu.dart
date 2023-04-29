import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:news/screens/home/components/anketler.dart';
import 'package:news/screens/home/components/gelisim.dart';
import 'package:news/screens/home/components/gezilecekSayfasi.dart';
import 'package:news/screens/home/components/yoreselSozluk.dart';
import '../../../constants.dart';
import '../../../controllers/MenuController.dart';

class SideMenu extends StatelessWidget {
  final CMenuController _controller = Get.put(CMenuController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: kDarkBlackColor,
        child: ListView(
          children: [
            DrawerHeader(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: kDefaultPadding * 3.5),
                child: SvgPicture.asset("assets/icons/logo.svg"),
              ),
            ),
            ListTile(
              title: Text(_controller.menuItems[0]),
              onTap: () {},
            ),
            ListTile(
              title: Text(_controller.menuItems[1]),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => YoreselSozluk()));
              },
            ),
            ListTile(
              title: Text(_controller.menuItems[2]),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Anketler()));
              },
            ),
            ListTile(
              title: Text(_controller.menuItems[3]),
            ),
            ListTile(
              title: Text(_controller.menuItems[4]),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GezileceklerSayfasi()));
              },
            ),
            ListTile(
              title: Text(_controller.menuItems[5]),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Gelisim()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback press;

  const DrawerItem({
    Key key,
    this.title,
    this.isActive,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
        selected: isActive,
        selectedTileColor: kPrimaryColor,
        onTap: press,
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
/*
   ...List.generate(
                _controller.menuItems.length,
                (index) => DrawerItem(
                  isActive: index == _controller.selectedIndex,
                  title: _controller.menuItems[index],
                  press: () {
                    _controller.setMenuIndex(index);
                  },
                ),
              ),
              */