class UserData {
  UserData(
      {required this.uid,
      required this.exp,
      required this.streak,
      required this.posts,
      required this.flashCardSets,
      required this.username,
      required this.email,
      required this.profilePicture});

  final int uid;
  int exp;
  int streak;
  int posts;
  String username;
  String email;
  String profilePicture;
  List<FlashcardSet> flashCardSets;

  set setExp(int exp) => this.exp = exp;
  set setStreak(int streak) => this.streak = streak;
  set setPosts(int posts) => this.posts = posts;
  set setUsername(String username) => this.username = username;
  set setEmail(String email) => this.email = email;
  set setProfilePicture(String profilePicture) =>
      this.profilePicture = profilePicture;
  set setFlashCardSets(List<FlashcardSet> flashCardSets) =>
      this.flashCardSets = flashCardSets;
  set addFlashCardSet(FlashcardSet flashCardSet) =>
      flashCardSets.add(flashCardSet);
}

UserData? userData;

void setUserData(UserData data) => userData = data;
get getUserData => userData!;

class FlashcardSet {
  FlashcardSet(
      {required this.id,
      required this.title,
      required this.description,
      required this.flashcards});

  final int id;
  String title;
  String description;
  List<Flashcard> flashcards;
}

class Flashcard {
  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
  });

  final int id;
  String question;
  String answer;
}
