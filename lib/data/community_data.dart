class MabData {
  MabData({
    required this.uid,
  });
  final int uid;

  List<MabPost> posts = [
    MabPost(
        uid: 0,
        title: "Hello World",
        description: "description",
        date: DateTime(2010, 1, 14),
        authorUID: 0,
        image: "https://picsum.photos/200/300",
        fileAttatchments: [
          "https://picsum.photos/200/300",
          "https://picsum.photos/200/300"
        ],
        dueDate: DateTime(2023, 1, 14),
        type: 1),
    MabPost(
        uid: 0,
        title: "Did you know this hit game called Among Us?",
        description:
            "In my world, everyone is a pony, and they all eat rainbows, and poop butterflies.",
        date: DateTime(2001, 9, 11),
        authorUID: 0,
        image: "https://picsum.photos/200/300",
        fileAttatchments: ["https://picsum.photos/200/300"],
        dueDate: DateTime(2023, 8, 14),
        type: 2),
    MabPost(
        uid: 0,
        title: "Did you know this hit game called Among Us?",
        description:
            "In my world, everyone is a pony, and they all eat rainbows, and poop butterflies.",
        date: DateTime(2001, 9, 11),
        authorUID: 0,
        image: "https://picsum.photos/200/300",
        fileAttatchments: ["https://picsum.photos/200/300"],
        dueDate: DateTime(2023, 8, 14),
        type: 2),
    MabPost(
        uid: 0,
        title: "Did you know this hit game called Among Us?",
        description:
            "In my world, everyone is a pony, and they all eat rainbows, and poop butterflies.",
        date: DateTime(2001, 9, 11),
        authorUID: 0,
        image: "https://picsum.photos/200/300",
        fileAttatchments: ["https://picsum.photos/200/300"],
        dueDate: DateTime(2023, 8, 14),
        type: 2),
  ];
}

//get uid from user's community id
get getMabData => MabData(uid: 0);

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
  });
  final int uid;
  String title;
  String description;
  String image;
  List<String> fileAttatchments;
  DateTime dueDate;
  int type;
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
        dueDate: DateTime(2023, 8, 14),
        type: 2),
    LACPost(
        uid: 0,
        title: "Derevee?",
        description:
            "In my world, everyone is a pony, and they all eat rainbows, and poop butterflies.",
        date: DateTime(2001, 9, 11),
        authorUID: 0,
        image: "https://picsum.photos/200/300",
        fileAttatchments: ["https://picsum.photos/200/300"],
        dueDate: DateTime(2023, 8, 14),
        type: 2),
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
      required this.authorUID});
  final int uid;
  String title;
  String description;
  String image;
  List<String> fileAttatchments;
  DateTime dueDate;
  int type;
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
