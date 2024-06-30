import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";
import "package:oneforall/components/animations/fade_in_transition.dart";
import "package:oneforall/components/base_shimmer.dart";
import "package:oneforall/logger.dart";
import "package:oneforall/models/note_models/note_content.dart";
import "package:oneforall/models/note_models/note_contents.dart";
import "package:oneforall/models/note_models/note_model.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../components/main_container.dart";

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final selectNoteDropdownController = OverlayPortalController();
  final selectNoteDropdownLayerLink = LayerLink();

  int noteIndex = -1;
  int? currentlyEditingIndex;
  bool editingTitle = false;

  late TextEditingController titleEditingController = TextEditingController(text: ref.read(editingNotesListProvider).title);

  final GlobalKey textContentEditingKey = GlobalKey<TextContentEditState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(notesListProvider.notifier).loadFromDisk();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    final editingNotesList = ref.watch(editingNotesListProvider);
    final notesList = ref.watch(notesListProvider);
    // Listen to changes in notesList
    ref.listen<Note>(editingNotesListProvider, (previous, value) {
      ref.read(notesListProvider.notifier).updateNote(value, noteIndex);
      ref.read(notesListProvider.notifier).saveToDisk();
    });

    return Scaffold(
      body: MainContainer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(builder: (context, mainBodyConstraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.notes, color: theme.onBackground, size: 32),
                    const SizedBox(width: 16),
                    Text(
                      "Notes",
                      style: textTheme.displayLarge,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                //* Select Note
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //* Left
                    IconButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: theme.onBackground,
                          disabledForegroundColor: theme.onBackground.withOpacity(0.5),
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: noteIndex == -1
                            ? null
                            : () {
                                setState(() {
                                  editingTitle = false;
                                  noteIndex--;
                                  ref.read(editingNotesListProvider.notifier).overrideNote(notesList[noteIndex]);
                                });
                              },
                        icon: const Icon(
                          Icons.arrow_left_rounded,
                          size: 48,
                        )),
                    //* Middle
                    Expanded(
                      child: LayoutBuilder(builder: (context, constraints) {
                        return CompositedTransformTarget(
                          link: selectNoteDropdownLayerLink,
                          child: OverlayPortal(
                            controller: selectNoteDropdownController,
                            overlayChildBuilder: (context) => CompositedTransformFollower(
                              link: selectNoteDropdownLayerLink,
                              targetAnchor: Alignment.bottomLeft,
                              child: Align(alignment: Alignment.topLeft, child: ConstrainedBox(constraints: BoxConstraints(maxHeight: mainBodyConstraints.maxHeight * 0.5, maxWidth: constraints.maxWidth), child: TapRegion(onTapOutside: (event) => selectNoteDropdownController.hide(), child: SelectNoteDropdown(constraints: constraints, noteIndex: noteIndex, updateNoteIndex: (index) => setState(() => noteIndex = index), closeDropdown: () => selectNoteDropdownController.hide())))),
                            ),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primary,
                                  surfaceTintColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  selectNoteDropdownController.toggle();
                                  titleEditingController.text = editingNotesList.title;
                                  setState(() {
                                    editingTitle = true;
                                  });
                                },
                                child: !editingTitle
                                    ? Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        editingNotesList.title.isEmpty ? "Select Note" : editingNotesList.title,
                                        style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                                      )
                                    : TapRegion(
                                        onTapOutside: (event) => setState(() => editingTitle = false),
                                        child: TextField(
                                          controller: titleEditingController,
                                          onSubmitted: (value) {
                                            ref.read(editingNotesListProvider.notifier).changeNoteTitle(value);
                                            setState(() => editingTitle = false);
                                          },
                                          style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                                          cursorColor: theme.onBackground,
                                          decoration: const InputDecoration(
                                            filled: false,
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      )),
                          ),
                        );
                      }),
                    ),
                    //* Right
                    noteIndex == notesList.length - 1
                        ? IconButton(
                            onPressed: () {
                              ref.read(notesListProvider.notifier).addNote();
                              setState(() {
                                editingTitle = false;
                                noteIndex = notesList.length - 1;
                                ref.read(editingNotesListProvider.notifier).overrideNote(notesList[noteIndex]);
                              });
                            },
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.add, color: theme.onBackground, size: 32))
                        : IconButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: theme.onBackground,
                              disabledForegroundColor: theme.onBackground.withOpacity(0.5),
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: noteIndex == notesList.length - 1
                                ? null
                                : () {
                                    setState(() {
                                      editingTitle = false;
                                      noteIndex++;
                                      ref.read(editingNotesListProvider.notifier).overrideNote(notesList[noteIndex]);
                                    });
                                  },
                            icon: const Icon(
                              Icons.arrow_right_rounded,
                              size: 48,
                            )),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      for (var content in editingNotesList.content) ...[
                        if (content.content is TextContent)
                          GestureDetector(
                            onTap: () async {
                              await Future.delayed(const Duration(milliseconds: 100));
                              setState(() {
                                currentlyEditingIndex = editingNotesList.content.indexOf(content);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: editingNotesList.content.indexOf(content) != currentlyEditingIndex ? TextContentDisplay(textContent: content.content as TextContent) : TextContentEdit(key: ValueKey(editingNotesList.content.indexOf(content)), noteIndex: noteIndex, initText: (content.content as TextContent).text, contentIndex: editingNotesList.content.indexOf(content), editFinished: () => setState(() => currentlyEditingIndex = -1)),
                            ),
                          ),
                        if (content.content is ImageContent)
                          GestureDetector(
                            onTap: () async {
                              //* Open editing modal
                              showDialog(context: context, builder: (c) => ImageContentEdit(content: content.content as ImageContent));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ImageContentDisplay(content: content.content as ImageContent),
                            ),
                          )
                      ],
                      if (noteIndex != -1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: theme.onBackground,
                                backgroundColor: theme.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                ref.read(editingNotesListProvider.notifier).addContents([
                                  NoteContent(TextContent(text: "text")),
                                ]);
                              },
                              label: const Text("Add Text"),
                              icon: const Icon(Icons.text_fields),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: theme.secondary, shape: RoundedRectangleBorder(side: BorderSide.none, borderRadius: BorderRadius.circular(10))),
                                onPressed: () {
                                  ref.read(editingNotesListProvider.notifier).addContents([
                                    NoteContent(ImageContent(type: ImageContentTypes.empty, image: ""))
                                  ]);
                                },
                                icon: Icon(
                                  Icons.add_a_photo,
                                  color: theme.onBackground,
                                ),
                                label: Text(
                                  "Add Photo",
                                  style: textTheme.displaySmall,
                                ))
                          ],
                        ),
                    ],
                  ),
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}

//* Components
class SelectNoteDropdown extends ConsumerStatefulWidget {
  const SelectNoteDropdown({super.key, required this.constraints, required this.noteIndex, required this.updateNoteIndex, required this.closeDropdown});
  final BoxConstraints constraints;
  final int noteIndex;
  final Function updateNoteIndex;
  final Function closeDropdown;

  @override
  ConsumerState<SelectNoteDropdown> createState() => _SelectNoteDropdownState();
}

class _SelectNoteDropdownState extends ConsumerState<SelectNoteDropdown> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    var notesList = ref.watch(notesListProvider);

    return FadeInTransition(
      duration: 150,
      child: Container(
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(8),
        ),
        width: widget.constraints.maxWidth,
        child: Stack(
          children: [
            //* Tint to seperate from main content
            Container(
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //* Search
                    TextField(
                      style: textTheme.displaySmall,
                      cursorColor: theme.onBackground,
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: textTheme.displaySmall,
                        prefixIcon: Icon(Icons.search, color: theme.onBackground),
                        filled: true,
                        fillColor: theme.primaryContainer,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    //* Notes
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: notesList.length,
                      itemBuilder: (context, index) {
                        if (searchQuery.isEmpty || notesList[index].title.contains(searchQuery)) {
                          return InkWell(
                            onTap: () {
                              widget.updateNoteIndex(index);
                              ref.read(editingNotesListProvider.notifier).overrideNote(notesList[index]);
                              widget.closeDropdown();
                            },
                            child: ListTile(
                              title: Text(
                                notesList[index].title,
                                style: textTheme.displaySmall,
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: theme.onBackground.withOpacity(0.5),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: theme.secondary,
                          thickness: 0.5,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// <h1></h1> --> displayLarge
/// <h2></h2> --> displayMedium
/// others --> displaySmall
class TextContentDisplay extends StatefulWidget {
  const TextContentDisplay({super.key, required this.textContent});
  final TextContent textContent;

  @override
  State<TextContentDisplay> createState() => _TextContentDisplayState();
}

enum TextContentType {
  h1,
  h2,
  bold,
  p,
}

class _TextContentDisplayState extends State<TextContentDisplay> {
  List<TextSpan> divideText(String text, TextTheme textTheme) {
    Map<String, TextContentType> textSpans = {};
    //* Split <h1>

    String textNode = "";
    for (int i = 0; i < text.length; i++) {
      if (text[i] == "<" && i + 4 <= text.length - 1) {
        //* Check for <h1>
        if (text.substring(i, i + 4) == "<h1>") {
          //* Add textNode to textSpans
          if (textNode.isNotEmpty) {
            textSpans.addAll({
              textNode: TextContentType.p
            });
            textNode = "";
          }

          //* increment, skip <h1>
          i = i + 4;

          //* Find </h1>
          for (int j = i; j < text.length; j++) {
            if (text[j] == "<" && text.substring(j, j + 5) == "</h1>") {
              textSpans.addAll({
                textNode: TextContentType.h1
              });
              textNode = "";
              i = j + 4;
              break;
            } else {
              textNode += text[j];
            }
          }

          //* Did not find </h1>
          if (textNode.isNotEmpty) {
            textSpans.addAll({
              textNode: TextContentType.h1
            });
            textNode = "";
            break;
          }
        } else

        //* Check for <h2>
        if (text.substring(i, i + 4) == "<h2>") {
          //* Add textNode to textSpans
          if (textNode.isNotEmpty) {
            textSpans.addAll({
              textNode: TextContentType.p
            });
            textNode = "";
          }

          //* increment, skip <h1>
          i = i + 4;

          //* Find </h1>
          for (int j = i; j < text.length; j++) {
            if (text[j] == "<" && text.substring(j, j + 5) == "</h2>") {
              textSpans.addAll({
                textNode: TextContentType.h2
              });
              textNode = "";
              i = j + 4;
              break;
            } else {
              textNode += text[j];
            }
          }

          //* Did not find </h2>
          if (textNode.isNotEmpty) {
            textSpans.addAll({
              textNode: TextContentType.h2
            });
            textNode = "";
            break;
          }
        } else

        //* Check for <bl>
        if (text.substring(i, i + 4) == "<bl>") {
          //* Add textNode to textSpans
          if (textNode.isNotEmpty) {
            textSpans.addAll({
              textNode: TextContentType.p
            });
            textNode = "";
          }

          //* increment, skip <bl>
          i = i + 4;

          //* Find </bl>
          for (int j = i; j < text.length; j++) {
            if (text[j] == "<" && text.substring(j, j + 5) == "</bl>") {
              textSpans.addAll({
                textNode: TextContentType.bold
              });
              textNode = "";
              i = j + 4;
              break;
            } else {
              textNode += text[j];
            }
          }

          //* Did not find </bl>
          if (textNode.isNotEmpty) {
            textSpans.addAll({
              textNode: TextContentType.bold
            });
            textNode = "";
            break;
          }
        } else {
          textNode += text[i];
        }
      } else {
        textNode += text[i];
      }
    }

    //* Finally return the spans
    if (textNode.isNotEmpty) {
      textSpans.addAll({
        textNode: TextContentType.p
      });
    }
    return textSpans.entries
        .map((e) => TextSpan(
              text: e.key,
              style: e.value == TextContentType.h1
                  ? textTheme.displayLarge
                  : e.value == TextContentType.h2
                      ? textTheme.displayMedium
                      : e.value == TextContentType.bold
                          ? textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)
                          : textTheme.displaySmall,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return RichText(text: TextSpan(children: divideText(widget.textContent.text, textTheme)));
  }
}

class TextContentEdit extends ConsumerStatefulWidget {
  const TextContentEdit({super.key, required this.noteIndex, required this.initText, required this.contentIndex, required this.editFinished});
  final int noteIndex;
  final String initText;
  final int contentIndex;
  final Function editFinished;

  @override
  ConsumerState<TextContentEdit> createState() => TextContentEditState();
}

class TextContentEditState extends ConsumerState<TextContentEdit> {
  late final textController = TextEditingController(text: widget.initText);

  void onEditingComplete() {
    ref.read(editingNotesListProvider.notifier).changeNoteContent(widget.contentIndex, NoteContent<TextContent>(TextContent(text: textController.text)));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Stack(
      children: [
        TextField(
          cursorColor: theme.onBackground,
          style: textTheme.displaySmall,
          decoration: InputDecoration(filled: true, fillColor: theme.primary, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none)),
          maxLines: null,
          controller: textController,
          onEditingComplete: () => onEditingComplete(),
        ),
        //* Check button
        Positioned(
          right: 4,
          top: 4,
          child: Opacity(
            opacity: 0.5,
            child: Row(
              children: [
                IconButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const CircleBorder(),
                  ),
                  onPressed: () {
                    widget.editFinished();
                    ref.read(editingNotesListProvider.notifier).deleteContent(widget.contentIndex);
                  },
                  icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                ),
                IconButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: const CircleBorder(),
                  ),
                  onPressed: () {
                    onEditingComplete();
                    widget.editFinished();
                    setState(() {});
                  },
                  icon: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ImageContentDisplay extends StatefulWidget {
  const ImageContentDisplay({super.key, required this.content});
  final ImageContent content;

  @override
  State<ImageContentDisplay> createState() => _ImageContentDisplayState();
}

class _ImageContentDisplayState extends State<ImageContentDisplay> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return ClipRRect(borderRadius: BorderRadius.circular(10), child: content(widget.content, theme, textTheme));
  }

  Widget content(ImageContent content, ColorScheme theme, TextTheme textTheme) {
    if (content.type == ImageContentTypes.empty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: theme.primary, border: Border.all(color: theme.secondary)),
        child: Center(
            child: Text(
          "No Image",
          style: textTheme.displaySmall,
        )),
      );
    }
    if (content.type == ImageContentTypes.local && content.image != null) {
      return Image.file(File(content.image!));
    }
    if (content.type == ImageContentTypes.link && content.image != null) {
      return Image.network(
        content.image!,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return BaseShimmer(
            enabled: true,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      );
    }
    return Center(
      child: Text("Unidentified", style: textTheme.displaySmall),
    );
  }
}

class ImageContentEdit extends ConsumerStatefulWidget {
  const ImageContentEdit({super.key, required this.content});
  final ImageContent content;

  @override
  ConsumerState<ImageContentEdit> createState() => _ImageContentEditState();
}

class _ImageContentEditState extends ConsumerState<ImageContentEdit> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    // var textTheme = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: theme.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () async {
                final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (file == null) return;
                String filePath = file.path;
                final editingNotifier = ref.read(editingNotesListProvider.notifier);
                final editingProvider = ref.read(editingNotesListProvider);
                editingNotifier.changeNoteContent(editingProvider.content.indexWhere((element) => element.content == widget.content), NoteContent<ImageContent>(ImageContent(type: ImageContentTypes.local, image: filePath)));
              },
              child: Container(
                decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Icon(
                    Icons.folder,
                    color: theme.onBackground,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    builder: (context) => ImageLinkDialog(onSubmit: (link, ref) {
                          final editingNotifier = ref.read(editingNotesListProvider.notifier);
                          final editingProvider = ref.read(editingNotesListProvider);
                          editingNotifier.changeNoteContent(editingProvider.content.indexWhere((element) => element.content == widget.content), NoteContent<ImageContent>(ImageContent(type: ImageContentTypes.link, image: link)));
                        }));
              },
              child: Container(
                decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Icon(
                    Icons.language,
                    color: theme.onBackground,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                final editingNotifier = ref.read(editingNotesListProvider.notifier);
                final editingProvider = ref.read(editingNotesListProvider);
                editingNotifier.deleteContent(editingProvider.content.indexWhere((element) => element.content == widget.content));
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(color: theme.primary, borderRadius: BorderRadius.circular(10)),
                child: const Padding(
                  padding: EdgeInsets.all(32),
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageLinkDialog extends StatefulWidget {
  const ImageLinkDialog({super.key, required this.onSubmit});
  final Function onSubmit;

  @override
  State<ImageLinkDialog> createState() => _ImageLinkDialogState();
}

class _ImageLinkDialogState extends State<ImageLinkDialog> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTeme = Theme.of(context).textTheme;
    return Consumer(builder: (context, ref, child) {
      return Dialog(
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                style: textTeme.displaySmall,
                cursorColor: theme.onBackground,
                decoration: InputDecoration(
                  hintStyle: textTeme.displaySmall!.copyWith(fontWeight: FontWeight.bold, color: theme.onBackground.withOpacity(0.25)),
                  hintText: "Link",
                  filled: true,
                  fillColor: theme.primary,
                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            IconButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  widget.onSubmit(controller.text, ref);

                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.check,
                  color: Colors.white,
                ))
          ],
        ),
      );
    });
  }
}

//* State

class EditingNotesList extends Notifier<Note> {
  void changeNoteTitle(String title) {
    state = Note(title: title, content: state.content);
  }

  void addContents(List<NoteContent> contents) {
    state = Note(title: state.title, content: [
      ...state.content,
      ...contents
    ]);
  }

  void overrideNote(Note note) {
    state = note;
  }

  void deleteContent(int index) {
    state = Note(title: state.title, content: [
      ...state.content.sublist(0, index),
      ...state.content.sublist(index + 1),
    ]);
  }

  void changeNoteContent(int index, NoteContent content) {
    state = Note(title: state.title, content: [
      ...state.content.sublist(0, index),
      content,
      ...state.content.sublist(index + 1),
    ]);
  }

  @override
  Note build() {
    return const Note(title: "", content: []);
  }
}

final editingNotesListProvider = NotifierProvider<EditingNotesList, Note>(EditingNotesList.new);

class NotesList extends Notifier<List<Note>> {
  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("notes", jsonEncode(state.map((e) => e.toJson()).toList()));
    logger.d(jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final notes = prefs.getString("notes");
    if (notes != null) {
      state = (jsonDecode(notes) as List).map((e) => Note.fromJson(e)).toList();
    }
    logger.d("Load from disk $state");
  }

  void updateNote(Note note, int index) {
    state = [
      ...state.sublist(0, index),
      note,
      ...state.sublist(index + 1),
    ];
  }

  void addNote() {
    state = [
      ...state,
      const Note(title: "New Note", content: []),
    ];
  }

  @override
  List<Note> build() {
    return [
      Note(title: "building materials for john", content: [
        NoteContent<TextContent>(TextContent(text: "galvanised <h1>square</h1> steel")),
        NoteContent<TextContent>(TextContent(text: "screws <h2>borrowed</h2> from aunt")),
        NoteContent<TextContent>(TextContent(text: "eco-friendly wood <bl>veneers</bl>")),
      ]),
    ];
  }
}

final notesListProvider = NotifierProvider<NotesList, List<Note>>(NotesList.new);

// TORPEDO!!!!!!!! from jailbreak