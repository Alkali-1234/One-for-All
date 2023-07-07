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
        type: 2)
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
