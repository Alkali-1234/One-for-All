import 'package:flutter/material.dart';
import 'package:local_hero/local_hero.dart';

class FlashcardsAnimationWidget extends StatefulWidget {
  const FlashcardsAnimationWidget({required super.key, required this.theme});
  final ColorScheme theme;

  @override
  State<FlashcardsAnimationWidget> createState() => FlashcardsAnimationWidgetState();
}

class FlashcardsAnimationWidgetState extends State<FlashcardsAnimationWidget> {
  int box1Num = 2;
  int box2Num = 1;
  int box3Num = 0;

  @override
  void dispose() {
    entry.remove();
    super.dispose();
  }

  List<Widget> children = [];

  OverlayEntry entry = OverlayEntry(builder: (context) => const ExtraOverlay());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Overlay.of(context).insert(entry);
    });
    children = [
      LocalHero(
        key: UniqueKey(),
        tag: 'box$box1Num',
        child: Container(
            width: 150,
            height: 25,
            decoration: BoxDecoration(
              color: widget.theme.secondary,
              borderRadius: BorderRadius.circular(10),
            )),
      ),
      LocalHero(key: UniqueKey(), tag: "box$box2Num", child: Container(width: 200, height: 50, color: Colors.transparent)),
      LocalHero(
        key: UniqueKey(),
        tag: 'box$box3Num',
        child: Container(
            height: 25,
            width: 150,
            decoration: BoxDecoration(
              color: widget.theme.secondary,
              borderRadius: BorderRadius.circular(10),
            )),
      ),
    ];
  }

  void increment(ColorScheme theme) {
    //* Add numebers
    box1Num++;
    box2Num++;
    box3Num++;
    //* Remount widgets
    setState(() {
      children = [
        LocalHero(
          key: UniqueKey(),
          tag: 'box$box1Num',
          child: Transform.translate(
            offset: const Offset(0, -25),
            child: Container(
                width: 150,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.secondary,
                  borderRadius: BorderRadius.circular(10),
                )),
          ),
        ),
        LocalHero(key: UniqueKey(), tag: "box$box2Num", child: Container(width: 200, height: 50, color: Colors.transparent)),
        LocalHero(
          key: UniqueKey(),
          tag: 'box$box3Num',
          child: Transform.translate(
            offset: const Offset(0, 25),
            child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                  color: theme.secondary,
                  borderRadius: BorderRadius.circular(10),
                )),
          ),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: LocalHeroScope(
          duration: const Duration(milliseconds: 1000),
          onlyAnimateRemount: false,
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: children),
        ),
      ),
    );
  }
}

class ExtraOverlay extends StatelessWidget {
  const ExtraOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform.translate(offset: const Offset(0, -25), child: Container(width: 150, height: 50, decoration: BoxDecoration(border: Border.all(color: theme.onBackground), borderRadius: BorderRadius.circular(10)))),
          Transform.translate(offset: const Offset(0, 25), child: Container(width: 150, height: 50, decoration: BoxDecoration(border: Border.all(color: theme.onBackground), borderRadius: BorderRadius.circular(10)))),
        ],
      ),
    );
  }
}
