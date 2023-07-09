class UserData {
  UserData(
      {required this.uid,
      required this.exp,
      required this.streak,
      required this.posts});

  final int uid;
  int exp;
  int streak;
  int posts;
}

get getUserData => UserData(uid: 0, exp: 0, streak: 0, posts: 0);
