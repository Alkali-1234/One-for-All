import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oneforall/main.dart';

DocumentSnapshot? communityData;
void setCommunityData(DocumentSnapshot data) => communityData = data;
get getSavedCommunityData => communityData;

@Deprecated("Do not use class.")
//ignore: deprecated_member_use_from_same_package
///Newer version of community data. Use this instead of deprecated [getMabData], [getLACData], [getRecentActivities]
class CommunityData {
  Stream<MabData> mabDataStream(AppState appState) {
    //!!! Hardcoded community ID
    return FirebaseFirestore.instance.collection("communities").doc("P3xcmRih8YYxkOqsuV7u").snapshots().distinct().map((event) {
      late MabData mabData;
      // event.data()!.forEach((key, value) {
      //   print(key.toString());
      //   if (key == "MAB") {
      //     mabData = MabData(uid: int.parse(key), posts: [
      //       for (var post in value)
      //         MabPost(
      //             uid: int.parse(key),
      //             title: post["title"],
      //             description: post["description"],
      //             date: DateTime.parse(post["date"].toDate().toString()),
      //             authorUID: post["authorUID"],
      //             image: post["image"],
      //             fileAttatchments: post["files"],
      //             dueDate: DateTime.parse(post["dueDate"].toDate().toString()),
      //             type: post["type"],
      //             subject: post["subject"]),
      //     ]);
      //   }
      // });
      // print("Data result:${event.data()!}");
      // print("MAB data: ${event.data()!["MAB"]}");
      // print("idk what this is: ${event.data()!["MAB"][0]}");

      final mabList = event.data()!["MAB"];
      mabData = MabData(uid: 0, posts: [
        for (var post in mabList)
          MabPost(
              uid: 0,
              title: post["title"],
              description: post["description"],
              date: DateTime.parse(post["date"].toDate().toString()),
              authorUID: 0,
              image: post["image"] ?? "",
              fileAttatchments: [
                for (String file in post["files"]) file
              ],
              dueDate: DateTime.parse(post["date"].toDate().toString()),
              type: post["type"],
              subject: post["subject"]),
      ]);
      // appState.setMabData(mabData);

      return mabData;
    });
  }

  //! Function above doesn't work (it spams requests to the server)
  //testing a new way

  Stream<LACData> lacDataStream(AppState appState) {
    //!!! Hardcoded community ID
    return FirebaseFirestore.instance.collection("communities").doc("P3xcmRih8YYxkOqsuV7u").snapshots().map((event) {
      late LACData lacData;
      event.data()!.forEach((key, value) {
        if (key == "LAC") {
          lacData = LACData(uid: int.parse(key), posts: []);
          value.forEach((key, value) {
            lacData.posts.add(LACPost(uid: int.parse(key), title: value["title"], description: value["description"], date: DateTime.parse(value["date"]), authorUID: value["authorUID"], image: value["image"], fileAttatchments: value["fileAttatchments"], dueDate: DateTime.parse(value["dueDate"]), type: value["type"], subject: value["subject"]));
          });
        }
      });
      // appState.setLacData(lacData);
      return lacData;
    });
  }
}

class MabData {
  MabData({
    required this.uid,
    required this.posts,
  });
  final int uid;

  List<MabPost> posts = [];

  set addPost(MabPost post) => posts.add(post);
}

MabData? mabData;

//! Removed deprecated code
// @Deprecated("Use [CommunityData] instead")

// ///Deprecated. Use [CommunityData] instead
// void setMabData(MabData data) => mabData = data;
@Deprecated("Use stream builder and provider instead")

///Deprecated. Use [CommunityData] instead
get getMabData => mabData;

class MabPost {
  MabPost({
    required this.uid,
    required this.title,
    required this.description,
    required this.date,
    required this.authorUID,
    required this.image,
    required this.fileAttatchments,
    required this.dueDate,
    required this.type,
    required this.subject,
  });
  final int uid;
  String title;
  String description;
  String image;
  List<String> fileAttatchments;
  DateTime dueDate;
  int type;
  int subject;
  final DateTime date;
  final int authorUID;
}

class LACData {
  LACData({
    required this.uid,
    required this.posts,
  });
  final int uid;
  List<LACPost> posts = [];
}

class LACPost {
  LACPost({required this.uid, required this.title, required this.description, required this.image, required this.fileAttatchments, required this.dueDate, required this.type, required this.date, required this.authorUID, required this.subject});
  final int uid;
  String title;
  String description;
  String image;
  List<String> fileAttatchments;
  DateTime dueDate;
  int type;
  int subject;
  final DateTime date;
  final int authorUID;
}

@Deprecated("Use stream builder and provider instead")
get getLACData => LACData(uid: 0, posts: []);

class RecentActivities {
  RecentActivities({
    required this.uid,
    required this.activities,
  });
  final int uid;
  final List<RecentActivity> activities;
}

class RecentActivity {
  RecentActivity({
    required this.uid,
    required this.date,
    required this.authorUID,
    required this.type,
    required this.other,
    required this.authorName,
    required this.authorProfilePircture,
  });
  final int uid;

  ///Types:
  ///0: Quiz
  ///1: Flashcards
  ///2: Notes
  final int type;
  final String other;
  final DateTime date;
  final int authorUID;
  final String authorName;
  final String authorProfilePircture;
}

@Deprecated("Use stream builder and provider instead")
get getRecentActivities => RecentActivities(uid: 0, activities: []);
