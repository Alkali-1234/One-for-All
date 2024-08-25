import 'dart:async';
import 'dart:io';
// import 'dart:html';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';

import 'package:animations/animations.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/components/main_container.dart';
import 'package:oneforall/components/quizzes_components/infinitymode_dialog.dart';
import 'package:oneforall/components/quizzes_components/three_two_one_go_modal.dart';
import 'package:oneforall/constants.dart';
import 'package:oneforall/functions/quizzes_functions.dart';
import 'package:oneforall/main.dart';
import 'package:oneforall/models/quiz_question.dart';
import 'package:oneforall/screens/interstitial_screen.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../../components/quizzes_components/combo_counter.dart';
import '../../components/quizzes_components/combo_flash_modal.dart';
import 'package:just_audio/just_audio.dart';

import 'quizzes_play_screen_components/dropdown.dart';
import 'quizzes_play_screen_components/end_screen.dart';
import 'quizzes_play_screen_components/multiple_choice.dart';
import 'quizzes_play_screen_components/play_screen_confirmation.dart';
import 'quizzes_play_screen_components/reorder.dart';

//* State
import 'quizzes_play_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizzesPlayScreen extends StatefulWidget {
  const QuizzesPlayScreen({super.key, required this.quizSet});
  final QuizSet quizSet;

  @override
  State<QuizzesPlayScreen> createState() => _QuizzesPlayScreenState();
}

class _QuizzesPlayScreenState extends State<QuizzesPlayScreen> {
  bool reversed = false;
  int currentScreen = 0;

  final playScreenKey = GlobalKey<PlayScreenState>();

  void changeScreen(int screen) {
    setState(() {
      if (screen > currentScreen) {
        reversed = false;
      } else {
        reversed = true;
      }
      currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: currentScreen == 0 ? true : false,
      child: Scaffold(
        // bottomNavigationBar: const BannerAdWidget(),
        body: MainContainer(
            onClose: () {
              if (currentScreen == 0) {
                Navigator.of(context).pop();
              }
              if (currentScreen == 1) {
                showDialog(
                    context: context,
                    builder: (context) => OnCloseDialog(onCloseFunction: () {
                          QuizzesFunctions().refreshQuizzesFromLocal(context.read<AppState>(), true);
                          playScreenKey.currentState!.audioPlayer.stop();
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }));
              }
            },
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PageTransitionSwitcher(
                  reverse: reversed,
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation, secondaryAnimation) => SharedAxisTransition(
                    fillColor: Colors.transparent,
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  ),
                  child: currentScreen == 0
                      ? Center(child: PlayScreenConfirmation(changeScreenFunction: changeScreen))
                      : currentScreen == 1
                          ? PlayScreen(key: playScreenKey, quizSet: widget.quizSet)
                          : const Placeholder(),
                ))),
      ),
    );
  }
}

//* Play screen
class PlayScreen extends ConsumerStatefulWidget {
  const PlayScreen({super.key, required this.quizSet});
  final QuizSet quizSet;

  @override
  ConsumerState<PlayScreen> createState() => PlayScreenState();
}

class PlayScreenState extends ConsumerState<PlayScreen> {
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        elapsedTime++;
      });
    });
    audioPlayer.setAsset("assets/audio/quizAudio.mp3");
    audioPlayer.setLoopMode(LoopMode.one);
    audioPlayer.play();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(context: context, builder: (context) => const ThreeTwoOneGoModal(), barrierDismissible: false);
      initializeVariables();
    });
  }

  int score = 0;
  int correctAnswers = 0;
  int correctStreak = 0;
  int highestStreak = 0;
  int questionsDone = 0;
  int redemptionAmount = 0;
  DateTime startTime = DateTime.now();
  int elapsedTime = 0;
  late Timer timer;

  List<Color> gradientColors = [
    Colors.transparent,
    Colors.transparent,
    Colors.transparent,
    Colors.transparent,
    Colors.transparent,
    Colors.green
  ];

  bool showingAnswers = false;

  //* Audio
  final AudioPlayer audioPlayer = AudioPlayer();

  //* Animation
  Tween<double> scoreStatTween = Tween<double>(begin: 0, end: 0);
  Tween<double> scoreStatAddTween = Tween<double>(begin: 1, end: 1);
  int scoreBeingAdded = 0;
  int updaterNumber = 0;

  //* Redemption
  QuizSet redemptionSet = QuizSet(title: "Redemption", description: "Redemption", questions: [], settings: {});

  //* Functions
  void initializeVariables() {
    final quizSet = ref.read(quizPlayingProvider.notifier);
    final currentQuestion = ref.read(currentQuestionProvider.notifier);
    quizSet.updateQuiz(widget.quizSet);
    currentQuestion.updateQuestion(widget.quizSet.questions[0]);
    redemptionSet = QuizSet(title: "Redemption", description: "Redemption", questions: [], settings: widget.quizSet.settings);
  }

  void initializeRedemption() {
    final quizSet = ref.read(quizPlayingProvider.notifier);
    final currentQuestion = ref.read(currentQuestionProvider.notifier);
    quizSet.updateQuiz(redemptionSet);
    currentQuestion.updateQuestion(redemptionSet.questions[0]);
    redemptionSet = QuizSet(title: "Redemption", description: "Redemption", questions: [], settings: redemptionSet.settings);
    redemptionAmount++;
    setState(() {});
  }

  String formatSeconds(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds - (minutes * 60);
    String formattedMinutes = minutes.toString().padLeft(2, "0");
    String formattedSeconds = remainingSeconds.toString().padLeft(2, "0");
    return "$formattedMinutes:$formattedSeconds";
  }

  void doNextQuestionAnimations(int scoreBeingAdded) async {
    if (!mounted) return;
    setState(() {
      this.scoreBeingAdded = scoreBeingAdded * (comboCounterKey.currentState!.counter / 10 + 1).round();
    });
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() {
      scoreStatAddTween = Tween<double>(begin: 1, end: 0);
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      scoreStatTween = Tween<double>(begin: score.toDouble(), end: score.toDouble() + scoreBeingAdded);
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      scoreStatAddTween = Tween<double>(begin: 0, end: 1);
    });
  }

  //* Keys
  final comboCounterKey = GlobalKey<ComboCounterState>();
  final shakeKey = GlobalKey<ShakeWidgetState>();

  void nextQuestion(bool correct, int score, QuizQuestion question) async {
    final quizSet = ref.read(quizPlayingProvider);
    final currentQuestion = ref.read(currentQuestionProvider);
    final currentQuestionNotifier = ref.read(currentQuestionProvider.notifier);

    if (!mounted) return;
    //* Pauses timer and adds combo count if correct, resets if wrong
    if (correct) comboCounterKey.currentState!.pauseTimer();
    if (correct) comboCounterKey.currentState!.addComboCount();
    if (!correct) comboCounterKey.currentState!.resetComboCount();

    //* shake if right
    if (correct && comboCounterKey.currentState!.counter >= 5) shakeKey.currentState!.shake();

    //* If counter is not 0, and is a multiple of 10 or it is 5, flash combo
    if (comboCounterKey.currentState!.counter != 0 && (comboCounterKey.currentState!.counter % 10 == 0 || comboCounterKey.currentState!.counter == 5)) await showDialog(context: context, builder: (context) => FlashComboModal(number: comboCounterKey.currentState!.counter), barrierDismissible: false);

    await Future.delayed(Duration(milliseconds: correct ? (1500 - (comboCounterKey.currentState!.counter * 100).round()) : 3000));
    updaterNumber++;
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 150));
    //* Check if quiz is finished
    if (quizSet.questions.indexOf(currentQuestion) + 1 > quizSet.questions.length - 1) {
      questionsDone++;
      if (correct) {
        correctAnswers++;
        correctStreak++;
        if (correctStreak > highestStreak) {
          highestStreak = correctStreak;
        }
        this.score += score * (comboCounterKey.currentState!.counter / 10 + 1).round();
      } else {
        correctStreak = 0;
        redemptionSet.questions.add(question);
      }
      if (infinityMode == null && redemptionSet.questions.isNotEmpty && redemptionAmount < (int.parse(quizSet.settings["redemptionAmounts"] ?? "0"))) {
        redemptionSequence();
        initializeRedemption();
        return;
      }
      endSequence(false);
      return;
    }
    questionsDone++;
    comboCounterKey.currentState!.startTimer();
    if (correct) {
      correctAnswers++;
      correctStreak++;
      this.score += scoreBeingAdded;
    } else {
      correctStreak = 0;
      this.score += scoreBeingAdded;
      redemptionSet.questions.add(question);
    }
    currentQuestionNotifier.updateQuestion(quizSet.questions[quizSet.questions.indexOf(currentQuestion) + 1]);
    setState(() {});
  }

  Future<void> redemptionSequence() async {
    showDialog(
        context: context,
        builder: (c) => Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              child: Center(child: Text("Previous Mistake #$redemptionAmount", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24), textAlign: TextAlign.center)),
            ),
        barrierDismissible: false);
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    Navigator.of(context).pop();
    return;
  }

  bool? infinityMode;
  bool showInfinityModeDialog = false;

  Future<void> endSequence(bool endInfiniteMode) async {
    if (infinityMode == null) comboCounterKey.currentState!.pauseTimer();
    if (endInfiniteMode == false && infinityMode == null) {
      setState(() {
        showInfinityModeDialog = true;
      });
      await Future.delayed(const Duration(milliseconds: 150));
    }
    //* Wait until infinity mode is set (i think there is a more proper way to do this but i dont know it)
    while (infinityMode == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (infinityMode == true) {
      redemptionSet.questions = [];
      final quiz = ref.read(quizPlayingProvider.notifier).shuffleQuestions();
      //literally copied from quizzes_screen.dart so ignore the ifs
      QuizSet modifiedQuiz = QuizSet(title: quiz.title, description: quiz.description, questions: [], settings: {
        "shuffleQuestions": false,
        "shuffleAnswers": false,
        "redemptionAmounts": 0,
      });
      if (quiz.questions.isEmpty) return;
      if (true) {
        modifiedQuiz.questions = quiz.questions.toList()..shuffle();
      }
      if (true) {
        for (var question in modifiedQuiz.questions.where((element) => element.type == QuizTypes.multipleChoice || element.type == QuizTypes.reorder)) {
          List<String> tempAns = question.answers.toList();
          question.answers.shuffle();
          question.correctAnswer = question.correctAnswer.map((e) => question.answers.indexOf(tempAns[e])).toList();
        }
        for (var question in modifiedQuiz.questions.where((element) => element.type == QuizTypes.dropdown)) {
          List<String> tempAns = question.answers.toList();
          question.answers.shuffle();
          question.correctAnswer = question.correctAnswer.map((e) => question.answers.indexOf(tempAns[e])).toList();
          //* Change the correct answer in sentence
          List<String> sentence = question.question.split("<seperator />");
          int dropdownIndex = 0;
          for (var i = 0; i < sentence.length; i++) {
            if (sentence[i].contains("<dropdown ")) {
              sentence[i] = "<dropdown answer=${question.correctAnswer[dropdownIndex]} />";
              dropdownIndex++;
            }
          }
        }
      }
      setState(() {
        if (showInfinityModeDialog == true) showInfinityModeDialog = false;
      });
      ref.read(quizPlayingProvider.notifier).updateQuiz(modifiedQuiz);
      ref.read(currentQuestionProvider.notifier).updateQuestion(modifiedQuiz.questions[0]);

      await Future.delayed(const Duration(milliseconds: 150));
      comboCounterKey.currentState!.startTimer();
      return;
    }
    timer.cancel();
    audioPlayer.stop();
    if (!mounted) return;
    showDialog(context: context, builder: (c) => const FinishedRibbon(), barrierDismissible: false);
    QuizzesFunctions().refreshQuizzesFromLocal(context.read<AppState>(), false);
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => InterstitialScreen(
              onClosed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => EndScreen(score: score, correctAnswers: correctAnswers, totalQuestions: questionsDone, redemptionAmount: redemptionAmount, timeSpent: DateTime.now().difference(startTime), highestStreak: highestStreak))),
              onFailed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => EndScreen(score: score, correctAnswers: correctAnswers, totalQuestions: questionsDone, redemptionAmount: redemptionAmount, timeSpent: DateTime.now().difference(startTime), highestStreak: highestStreak))),
            )));
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = ref.watch(currentQuestionProvider);
    // var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return ShakeMe(
      key: shakeKey,
      shakeOffset: 10,
      shakeCount: 3,
      shakeDuration: const Duration(milliseconds: 200),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 12,
                child: Column(
                  children: [
                    //* Statistics
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //* Score
                        Expanded(
                          flex: 1,
                          child: TweenAnimationBuilder(
                              tween: scoreStatTween,
                              duration: const Duration(milliseconds: 250),
                              builder: (context, double value, child) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.yellow),
                                    const SizedBox(width: 5),
                                    Text(value.toInt().toString(), style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 2.5),
                                    //* + <score add amount> Score animation. Shows when the score increases, goes from being faded from above, to being faded out to the bottom
                                    TweenAnimationBuilder(
                                      tween: scoreStatAddTween,
                                      duration: const Duration(milliseconds: 250),
                                      builder: (context, value, child) {
                                        return Opacity(opacity: 1 - value, child: Transform.translate(offset: Offset(0, -value), child: child));
                                      },
                                      child: Text("+${scoreBeingAdded.toString()}", style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
                                    )
                                  ],
                                );
                              }),
                        ),
                        //* Time Elapsed
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer_rounded, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(formatSeconds(elapsedTime), style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        //* Combo counter
                        Flexible(
                            flex: 1,
                            child: ComboCounter(
                              key: comboCounterKey,
                              theme: Theme.of(context).colorScheme,
                              incrementScore: () {
                                setState(() {
                                  scoreStatTween = Tween<double>(begin: score.toDouble(), end: score.toDouble() + 1);
                                  score++;
                                });
                                AudioPlayer audioPlayer = AudioPlayer();
                                audioPlayer.setAsset("assets/audio/boopSound.mp3");
                                audioPlayer.play();
                              },
                            )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      //* Animation
                      child: Column(
                        children: [
                          //* Question image
                          currentQuestion.imagePath != null && currentQuestion.imagePath!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: InkWell(
                                    highlightColor: Colors.transparent,
                                    splashColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.125),
                                    onTap: () {
                                      showDialog(context: context, builder: (context) => ViewImageDialog(currentQuestion: currentQuestion, textTheme: textTheme));
                                    },
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            height: 200,
                                            //width: Image.file(File(currentQuestion.imagePath!)). .width!.toDouble() / Image.file(File(currentQuestion.imagePath!)).height!.toDouble() * 200,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.25)),
                                              image: DecorationImage(image: FileImage(File(currentQuestion.imagePath!)), fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(flex: 1, child: Center(child: Text("Tap to view image", textAlign: TextAlign.center, style: textTheme.displaySmall))),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          Expanded(
                            child: PageTransitionSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                                return SharedAxisTransition(
                                  fillColor: Colors.transparent,
                                  animation: primaryAnimation,
                                  secondaryAnimation: secondaryAnimation,
                                  transitionType: SharedAxisTransitionType.horizontal,
                                  child: child,
                                );
                              },
                              child: Container(
                                key: ValueKey(currentQuestion),
                                child: showInfinityModeDialog
                                    ? InfinityModeDialog(putResult: (value) => setState(() => infinityMode = value))
                                    : currentQuestion.type == QuizTypes.multipleChoice || currentQuestion.type == null
                                        ? MultipleChoice(
                                            currentCombo: comboCounterKey.currentState?.counter ?? 0,
                                            question: currentQuestion,
                                            nextQuestionFunction: nextQuestion,
                                            doAnimationFunction: doNextQuestionAnimations,
                                            toggleShowingAnswers: () => setState(
                                                  () => showingAnswers = !showingAnswers,
                                                ))
                                        : currentQuestion.type == QuizTypes.dropdown
                                            ? DropdownQuestion(
                                                question: currentQuestion,
                                                nextQuestionFunction: nextQuestion,
                                                doAnimationFunction: doNextQuestionAnimations,
                                                toggleShowingAnswers: () => setState(
                                                      () => showingAnswers = !showingAnswers,
                                                    ))
                                            : currentQuestion.type == QuizTypes.reorder
                                                ? ReorderQuestion(
                                                    currentCombo: comboCounterKey.currentState?.counter ?? 0,
                                                    question: currentQuestion,
                                                    nextQuestionFunction: nextQuestion,
                                                    doAnimationFunction: doNextQuestionAnimations,
                                                    toggleShowingAnswers: () => setState(
                                                          () => showingAnswers = !showingAnswers,
                                                        ))
                                                : const Placeholder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              infinityMode == true
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0, foregroundColor: Colors.white),
                          onPressed: () => {
                                setState(() => infinityMode = false),
                                endSequence(true)
                              },
                          child: const Text("Finish")),
                    )
                  : const Expanded(flex: 0, child: SizedBox.shrink())
            ],
          ),
        ],
      ),
    );
  }
}

//* Other widgets

class ViewImageDialog extends StatefulWidget {
  const ViewImageDialog({
    super.key,
    required this.currentQuestion,
    required this.textTheme,
  });

  final QuizQuestion currentQuestion;
  final TextTheme textTheme;

  @override
  State<ViewImageDialog> createState() => _ViewImageDialogState();
}

class _ViewImageDialogState extends State<ViewImageDialog> {
  bool showHintText = true;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        showHintText = !showHintText;
        timer.cancel();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 300,
            child: PhotoView(
              backgroundDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              imageProvider: FileImage(File(widget.currentQuestion.imagePath!)),
              maxScale: PhotoViewComputedScale.covered * 2.0,
              minScale: PhotoViewComputedScale.contained * 0.8,
            ),
          ),
          const SizedBox(height: 10),
          showHintText
              ? Row(
                  children: [
                    Text("Use two fingers to zoom in and out", style: widget.textTheme.displaySmall),
                    const SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.pinch, size: 14, color: Theme.of(context).colorScheme.onBackground)
                  ],
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class FinishedRibbon extends StatelessWidget {
  const FinishedRibbon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Center(child: Text("Finished", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, fontStyle: FontStyle.italic))),
    );
  }
}

class NumberAddingAnimation extends StatefulWidget {
  const NumberAddingAnimation({super.key, required this.value, required this.context, required this.index});
  final int value;
  final BuildContext context;
  final int index;

  @override
  State<NumberAddingAnimation> createState() => _NumberAddingAnimationState();
}

class _NumberAddingAnimationState extends State<NumberAddingAnimation> {
  Tween<double> tween = Tween<double>(begin: 0, end: 0);

  void startAnimation() async {
    await Future.delayed(Duration(milliseconds: 1200 * widget.index));
    animationSound();
    setState(() {
      tween = Tween<double>(begin: 0, end: widget.value.toDouble());
    });
  }

  void animationSound() async {
    if (widget.value == 0) return;
    bool stop = false;
    Timer(const Duration(milliseconds: 1000), () => stop = true);
    Duration durationBetweenSounds = Duration(milliseconds: (1000 / widget.value).round());
    if (durationBetweenSounds.inMilliseconds < 17) {
      durationBetweenSounds = const Duration(milliseconds: 17);
    }

    while (!stop) {
      await Future.delayed(durationBetweenSounds);
      AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.setAsset("assets/audio/boopSound.mp3");
      audioPlayer.play();
    }
  }

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: tween,
      duration: const Duration(milliseconds: 1000),
      builder: (context, double value, child) {
        return Text(value.toInt().toString(), style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold));
      },
    );
  }
}

class OnCloseDialog extends StatefulWidget {
  const OnCloseDialog({super.key, required this.onCloseFunction});
  final Function onCloseFunction;

  @override
  State<OnCloseDialog> createState() => _OnCloseDialogState();
}

class _OnCloseDialogState extends State<OnCloseDialog> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var ttheme = Theme.of(context).textTheme;
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.background,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Are you sure you want to quit?", style: ttheme.displayMedium),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    onPressed: () => widget.onCloseFunction(),
                    child: const Text("Yes, quit")),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.primaryContainer,
                      foregroundColor: theme.onBackground,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
