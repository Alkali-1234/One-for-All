var communityData;
void setCommunityData(data) => communityData = data;
get getCommunityData => communityData;

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

void setMabData(MabData data) => mabData = data;
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
  });
  final int uid;

  List<LACPost> posts = [
    LACPost(
        uid: 0,
        title: "Super long sentence like wow forreal guys??? Like a!",
        description: "i really like ducks.",
        date: DateTime(2001, 9, 11),
        authorUID: 0,
        image: "https://picsum.photos/200/300",
        fileAttatchments: ["https://picsum.photos/200/300"],
        dueDate: DateTime(2023, 7, 21),
        type: 2,
        subject: 1),
    LACPost(
        uid: 0,
        title: "Derevee?",
        description:
            "In my world, everyone is a pony, and they all eat rainbows, and poop butterflies.",
        date: DateTime(2001, 9, 11),
        authorUID: 0,
        image: "https://picsum.photos/200/300",
        fileAttatchments: ["https://picsum.photos/200/300"],
        dueDate: DateTime(2023, 7, 15),
        type: 1,
        subject: 0),
  ];
}

class LACPost {
  LACPost(
      {required this.uid,
      required this.title,
      required this.description,
      required this.image,
      required this.fileAttatchments,
      required this.dueDate,
      required this.type,
      required this.date,
      required this.authorUID,
      required this.subject});
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

get getLACData => LACData(uid: 0);

class RecentActivities {
  RecentActivities({
    required this.uid,
  });
  final int uid;
  List<RecentActivity> activities = [
    RecentActivity(
        uid: 0,
        date: DateTime(2023, 7, 9, 10, 30),
        authorUID: 0,
        type: 0,
        other: "IPS",
        authorName: "John Doe",
        authorProfilePircture: "https://picsum.photos/200/300"),
    RecentActivity(
        uid: 0,
        date: DateTime(2023, 7, 9, 10, 00),
        authorUID: 0,
        type: 1,
        other: "IPA",
        authorName: "John Doe",
        authorProfilePircture: "https://picsum.photos/200/300"),
    RecentActivity(
        uid: 0,
        date: DateTime(2023, 7, 9, 10, 00),
        authorUID: 0,
        type: 2,
        other: "IPA",
        authorName: "John Doe",
        authorProfilePircture: "https://picsum.photos/200/300"),
  ];
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
  final int type;
  final String other;
  final DateTime date;
  final int authorUID;
  final String authorName;
  final String authorProfilePircture;

  //Types:
  //0: Quiz
  //1: Flashcards
  //2: Notes
}

get getRecentActivities => RecentActivities(uid: 0);
