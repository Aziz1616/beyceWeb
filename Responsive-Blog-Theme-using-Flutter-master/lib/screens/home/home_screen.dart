import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:news/constants.dart';
import 'package:news/models/blogYazi.dart';

import 'package:news/responsive.dart';
import 'package:news/services/firestoreSrvisi.dart';
import 'package:news/services/yetkilendirmeServisi.dart';
import 'package:provider/provider.dart';
import 'components/blog_post.dart';
import 'components/categories.dart';
import 'components/recent_posts.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    String _aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context).aktifKullaniciId;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 2,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreServisi().tumBlogYaziGetir(),
              builder: ((context, snapshot) {
                if (!snapshot.hasData) {
                  return LinearProgressIndicator();
                }
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: ((context, index) {
                      BlogYazi blogYazi =
                          BlogYazi.dokumandanUret(snapshot.data.docs[index]);
                      return BlogPostCard(
                        blogYazi: blogYazi,
                      );
                    }));
              }),
            )),
        if (!Responsive.isMobile(context)) SizedBox(width: kDefaultPadding),
        //sidebar
        if (!Responsive.isMobile(context))
          Expanded(
            child: Column(
              children: [
                SizedBox(height: kDefaultPadding),
                Categories(),
                SizedBox(height: kDefaultPadding),
                RecentPosts(),
              ],
            ),
          ),
      ],
    );
  }
}
