import 'package:flutter/material.dart';

class DottedPaginator extends StatefulWidget {
  const DottedPaginator({super.key, required this.startingPage, required this.totalPages, this.clickToPage = false});
  final int startingPage;
  final int totalPages;
  final bool clickToPage;

  @override
  State<DottedPaginator> createState() => DottedPaginatorState();
}

class DottedPaginatorState extends State<DottedPaginator> {
  late int currentPage = widget.startingPage;

  void updatePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < widget.totalPages; i++)
          _Dot(
            key: ValueKey(i),
            onPressed: (value) {
              if (widget.clickToPage) updatePage(i);
            },
            page: i,
            currentPage: currentPage,
          )
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({super.key, required this.onPressed, required this.page, required this.currentPage});
  final Function onPressed;
  final int page;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: () => onPressed(page),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 15,
          width: currentPage == page ? 40 : 15,
          decoration: BoxDecoration(color: currentPage != page ? theme.onBackground.withOpacity(0.25) : theme.onBackground, borderRadius: BorderRadius.circular(15 / 2)),
        ),
      ),
    );
  }
}
