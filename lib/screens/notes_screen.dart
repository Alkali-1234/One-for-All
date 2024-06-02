import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:oneforall/components/animations/fade_in_transition.dart";
import "package:oneforall/models/note_models/note_content.dart";
import "package:oneforall/models/note_models/note_contents.dart";
import "package:oneforall/models/note_models/note_model.dart";
import "../components/main_container.dart";

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final selectNoteDropdownController = OverlayPortalController();
  final selectNoteDropdownLayerLink = LayerLink();

  int noteIndex = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    final editingNotesList = ref.watch(editingNotesListProvider);
    final notesList = ref.watch(notesListProvider);
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
                        onPressed: noteIndex == 0
                            ? null
                            : () {
                                setState(() {
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
                                },
                                child: Text(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  editingNotesList.title.isEmpty ? "Select Note" : editingNotesList.title,
                                  style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                                )),
                          ),
                        );
                      }),
                    ),
                    //* Right
                    IconButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: theme.onBackground,
                          disabledForegroundColor: theme.onBackground.withOpacity(0.5),
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: noteIndex == notesList.length - 1
                            ? null
                            : () {
                                setState(() {
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
                      for (var content in editingNotesList.content)
                        if (content is NoteContent<TextContent>)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextContentDisplay(textContent: content.content),
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
  const TextContentEdit({super.key, required this.noteIndex, required this.initText});
  final int noteIndex;
  final String initText;

  @override
  ConsumerState<TextContentEdit> createState() => _TextContentEditState();
}

class _TextContentEditState extends ConsumerState<TextContentEdit> {
  late final textController = TextEditingController(text: widget.initText);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return TextField(
      style: textTheme.displaySmall,
      decoration: InputDecoration(filled: true, fillColor: theme.primary, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none)),
      maxLines: null,
      controller: textController,
    );
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
