import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:news/screens/home/components/loginnedBlogPost.dart';
import 'package:news/services/firestoreSrvisi.dart';
import '../../constants.dart';
import '../../models/blogYazi.dart';
import '../../responsive.dart';
import 'components/categories.dart';
import 'components/recent_posts.dart';

// ignore: camel_case_types
class loginned_homeScreen extends StatefulWidget {
  
  loginned_homeScreen({Key key, }) : super(key: key);

  @override
  State<loginned_homeScreen> createState() => _loginned_homeScreenState();
}

class _loginned_homeScreenState extends State<loginned_homeScreen> {
  @override
  Widget build(BuildContext context) {
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

                      return LoginnedBlogPostDart(
                        
                        blogYazi: blogYazi,
                      );
                    }));
              }),
            )),
        if (!Responsive.isMobile(context)) SizedBox(width: kDefaultPadding),
        // Sidebar
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
