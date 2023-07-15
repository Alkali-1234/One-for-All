class UserData {
  UserData(
      {required this.uid,
      required this.exp,
      required this.streak,
      required this.posts,
      required this.flashCardSets});

  final int uid;
  int exp;
  int streak;
  int posts;
  List<FlashcardSet> flashCardSets;
}

get getUserData =>
    UserData(uid: 0, exp: 0, streak: 0, posts: 0, flashCardSets: [
      FlashcardSet(
          id: 0,
          title: "Random Trivia 1",
          description: "Among Us is a great game forreal",
          flashcards: [
            Flashcard(
                id: 0,
                question: "What is the capital of France?",
                answer: "Paris"),
            Flashcard(
                id: 1,
                question: "Who painted the Mona Lisa?",
                answer: "Leonardo da Vinci"),
            Flashcard(
                id: 2,
                question: "What is the chemical symbol for gold?",
                answer: "Au"),
            Flashcard(
                id: 3,
                question: "Who wrote the play 'Romeo and Juliet'?",
                answer: "William Shakespeare"),
            Flashcard(
                id: 4,
                question: "What is the largest planet in our solar system?",
                answer: "Jupiter"),
            Flashcard(
                id: 5,
                question: "What is the tallest mountain in the world?",
                answer: "Mount Everest"),
            Flashcard(
                id: 6,
                question:
                    "Which country is known as the Land of the Rising Sun?",
                answer: "Japan"),
            Flashcard(
                id: 7,
                question: "Who is the author of the Harry Potter book series?",
                answer: "J.K. Rowling"),
            Flashcard(
                id: 8,
                question: "What is the formula for the area of a circle?",
                answer: "πr^2"),
            Flashcard(
                id: 9,
                question: "What is the chemical formula for water?",
                answer: "H2O")
          ])
    ]);

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
