import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../models/note_model.dart';
import '../../theme/app_colors.dart';

/// Screen for writing a new note or editing an existing one.
/// - Pass [note] to edit it. Leave it null to write a new note.
/// - When the screen closes, it sends back the finished NoteModel,
///   or null if there is nothing to save.
/// - Going back saves automatically, so writing is never lost.
class NoteEditorScreen extends StatefulWidget {
  final NoteModel? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  late String _category;
  late bool _isPinned;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();

    final note = widget.note;
    if (note != null) {
      // Editing: start with the note's current values.
      _titleController.text = note.title;
      _contentController.text = note.content;
      _category = note.category;
      _isPinned = note.isPinned;
    } else {
      // New note: start with defaults.
      _category = NoteModel.categories.first;
      _isPinned = false;
    }

    // Refresh the word counter while typing.
    _contentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Number of words in the content.
  int get _wordCount {
    final String text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  // Works out what to send back when the screen closes.
  // Returns null when there is nothing new to save.
  NoteModel? _buildResult() {
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();
    final NoteModel? original = widget.note;

    if (original == null) {
      // New note: discard it if nothing was written.
      if (title.isEmpty && content.isEmpty) return null;

      final DateTime now = DateTime.now();
      return NoteModel(
        id: const Uuid().v4(),
        title: title,
        content: content,
        category: _category,
        isPinned: _isPinned,
        createdAt: now,
        updatedAt: now,
      );
    }

    // Existing note: do nothing if nothing changed.
    final bool unchanged = title == original.title &&
        content == original.content &&
        _category == original.category &&
        _isPinned == original.isPinned;
    if (unchanged) return null;

    return original.copyWith(
      title: title,
      content: content,
      category: _category,
      isPinned: _isPinned,
    );
  }

  // Saves and closes the screen.
  void _saveAndClose() {
    Navigator.of(context).pop(_buildResult());
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = NoteModel.colorForCategory(_category);

    // PopScope catches the phone's back button too,
    // so we can auto-save before the screen closes.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _saveAndClose();
      },
      child: Scaffold(
        backgroundColor: pageColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: _saveAndClose,
          ),
          title: Text(_isEditing ? 'Edit Note' : 'New Note'),
          actions: [
            // Pin or unpin
            IconButton(
              tooltip: _isPinned ? 'Unpin note' : 'Pin note',
              icon: Icon(
                _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: AppColors.terracotta,
              ),
              onPressed: () => setState(() => _isPinned = !_isPinned),
            ),
            // Save and close
            IconButton(
              tooltip: 'Save',
              icon: const Icon(
                Icons.check_rounded,
                color: AppColors.terracotta,
                size: 28,
              ),
              onPressed: _saveAndClose,
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chips
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: NoteModel.categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final String category = NoteModel.categories[index];
                      final bool isSelected = category == _category;

                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        showCheckmark: false,
                        onSelected: (_) =>
                            setState(() => _category = category),
                        selectedColor: AppColors.terracotta,
                        backgroundColor: AppColors.white.withOpacity(0.7),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.terracotta
                              : Colors.transparent,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.darkBrown,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Title (no border, large text)
                TextField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  maxLines: 2,
                  minLines: 1,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBrown,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 8),

                // Content (fills the remaining space)
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      height: 1.6,
                      color: AppColors.darkBrown,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textSecondary.withOpacity(0.6),
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // Footer: word count and auto-save hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_wordCount ${_wordCount == 1 ? 'word' : 'words'}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Saved automatically when you go back',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}