import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:oneforall/data/user_data.dart';
import 'package:oneforall/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlashcardsFunctions {
  Future<void> exportFlashcardsToDownloads(FlashcardSet flashcardSet, BuildContext context) async {
    Archive archive = Archive();
    Object flashcardData = {
      "id": flashcardSet.id,
      "title": flashcardSet.title,
      "description": flashcardSet.description,
      "flashcards": [
        for (var flashcard in flashcardSet.flashcards)
          {
            "question": flashcard.question,
            "answer": flashcard.answer,
            "image": flashcard.image,
            "hints": flashcard.hints,
          }
      ],
    };
    String flashcardDataString = jsonEncode(flashcardData);
    archive.addFile(ArchiveFile('flashcard.json', flashcardDataString.length, utf8.encode(flashcardDataString)));
    //* Add images to the archive
    for (var element in flashcardSet.flashcards.where((element) => element.image != null && element.image!.isNotEmpty)) {
      archive.addFile(ArchiveFile("images/${element.image!.split("/").last}", File(element.image!).readAsBytesSync().length, File(element.image!).readAsBytesSync()));
    }

    //* Save the archive to the device's downloads folder
    Directory? downloadsDirectory = await getDownloadPath();
    if (downloadsDirectory == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Cannot find download folder"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    File file = await File('${downloadsDirectory.path}/flashcard.zip').create();
    file.writeAsBytesSync(ZipEncoder().encode(archive)!);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Saved to ${file.path}"),
      backgroundColor: Colors.green,
    ));
    archive.clear();
  }

  Future<void> importFlashcardFromZip(File zipFile, BuildContext context, AppState appState) async {
    //* Extract the archive
    Archive archive = ZipDecoder().decodeBytes(zipFile.readAsBytesSync());
    String flashcardDataString = utf8.decode(archive.findFile("flashcard.json")!.content as List<int>);
    dynamic flashcardData = jsonDecode(flashcardDataString);
    FlashcardSet flashcardSet = FlashcardSet(
      id: flashcardData["id"],
      title: flashcardData["title"],
      description: flashcardData["description"],
      flashcards: [
        for (var flashcard in flashcardData["flashcards"])
          Flashcard(
            id: 0,
            question: flashcard["question"],
            answer: flashcard["answer"],
            image: flashcard["image"],
            hints: flashcard["hints"],
          )
      ],
    );
    //* Images
    for (var flashcard in flashcardSet.flashcards) {
      if (flashcard.image != null && flashcard.image!.isNotEmpty) {
        ArchiveFile? imageFile = archive.findFile("images/${flashcard.image!.split("/").last}");
        if (imageFile != null) {
          if (!File("${(await getApplicationDocumentsDirectory()).path}/flashcardImages/${flashcard.image!.split("/").last}").existsSync()) {
            Directory appDirectory = await getApplicationDocumentsDirectory();
            File file = await File("${appDirectory.path}/flashcardImages/${flashcard.image!.split("/").last}").create(recursive: true);
            file.writeAsBytesSync(imageFile.content as List<int>);
            flashcard.image = file.path;
          }
        }
      }
    }
    //* Add the flashcard set to the user's flashcard sets
    appState.getCurrentUser.flashCardSets.add(flashcardSet);
    appState.thisNotifyListeners();
    //* Save to shared preferences
    await refreshFlashcardSetsFromAppState(appState);
    //* Show a snackbar
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Imported flashcard set from ${zipFile.path}"),
      backgroundColor: Colors.green,
    ));
  }

  Future<void> refreshFlashcardSetsFromAppState(AppState appState) async {
    var prefs = await SharedPreferences.getInstance();
    //Convert to Object
    Object objectifiedFlashcardSets = [
      for (var flashcardSet in appState.getCurrentUser.flashCardSets)
        {
          "id": flashcardSet.id,
          "title": flashcardSet.title,
          "description": flashcardSet.description,
          "flashcards": [
            for (var flashcard in flashcardSet.flashcards)
              {
                "question": flashcard.question,
                "answer": flashcard.answer,
                "image": flashcard.image,
                "hints": flashcard.hints,
              }
          ],
        }
    ];
    prefs.setString("flashcardSets", jsonEncode(objectifiedFlashcardSets));
  }

  Future<Directory?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) directory = await getExternalStorageDirectory();
      }
    } catch (err) {
      throw ("Cannot get download folder path");
    }
    return directory;
  }
}
