import "package:flutter/material.dart";

class InfinityModeDialog extends StatefulWidget {
  const InfinityModeDialog({super.key, required this.putResult});
  final Function putResult;

  @override
  State<InfinityModeDialog> createState() => _InfinityModeDialogState();
}

class _InfinityModeDialogState extends State<InfinityModeDialog> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Finished all questions! Go to infinity mode?", style: textTheme.displaySmall),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.secondary,
                foregroundColor: theme.onBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => widget.putResult(true),
              label: const Text("Start"),
              icon: const Icon(Icons.check),
            ),
            const SizedBox(width: 20),
            TextButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.secondary,
                foregroundColor: theme.onBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => widget.putResult(false),
              label: const Text("Finish"),
              icon: const Icon(Icons.close),
            ),
          ],
        )
      ],
    ));
  }
}
