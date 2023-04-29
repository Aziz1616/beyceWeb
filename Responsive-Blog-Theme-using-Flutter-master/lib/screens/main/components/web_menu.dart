import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news/controllers/MenuController.dart';
import 'package:news/screens/home/components/anketler.dart';
import 'package:news/screens/home/components/gelisim.dart';
import 'package:news/screens/home/components/gezilecekSayfasi.dart';
import 'package:news/screens/home/components/yoreselSozluk.dart';

import '../../../constants.dart';

class WebMenu extends StatelessWidget {
  final CMenuController _controller = Get.put(CMenuController());

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
              onPressed: () {}, child: Text(_controller.menuItems[0])),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => YoreselSozluk()));
              },
              child: Text(_controller.menuItems[1])),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
              onPressed: () {
                
               Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Anketler()));
              
              }, child: Text(_controller.menuItems[2])),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
              onPressed: () {}, child: Text(_controller.menuItems[3])),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GezileceklerSayfasi()));
              },
              child: Text(_controller.menuItems[4])),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
              onPressed: () {
                
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Gelisim()));
              }, child: Text(_controller.menuItems[5])),
        ),
      ],
    );
  }
}

class WebMenuItem extends StatefulWidget {
  const WebMenuItem({
    Key key,
    this.isActive,
    this.text,
    this.press,
  }) : super(key: key);

  final bool isActive;
  final String text;
  final VoidCallback press;

  @override
  _WebMenuItemState createState() => _WebMenuItemState();
}

class _WebMenuItemState extends State<WebMenuItem> {
  bool _isHover = false;

  Color _borderColor() {
    if (widget.isActive) {
      return kPrimaryColor;
    } else if (!widget.isActive & _isHover) {
      return kPrimaryColor.withOpacity(0.4);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.press,
      onHover: (value) {
        setState(() {
          _isHover = value;
        });
      },
      child: AnimatedContainer(
        duration: kDefaultDuration,
        margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
        padding: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: _borderColor(), width: 3),
          ),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
