import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/note_model.dart';
import '../../providers/note_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/note_card.dart';
import 'note_editor_screen.dart';

/// The Notes tab: search, category filter, pinned notes and all other notes.
/// The notes come from NoteProvider, so every screen shares the same data.
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 'All' or one of NoteModel.categories.
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // The notes to show, after applying the category filter and the search.
  List<NoteModel> _visibleNotes(List<NoteModel> allNotes) {
    final String query = _searchQuery.trim().toLowerCase();

    final List<NoteModel> list = allNotes.where((note) {
      // 1. Category filter
      if (_selectedCategory != 'All' && note.category != _selectedCategory) {
        return false;
      }

      // 2. Search (title or content)
      if (query.isEmpty) return true;
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();

    // Most recently changed notes first.
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  // Opens the editor to write a note (note == null) or edit one.
  Future<void> _openEditor({NoteModel? note}) async {
    final NoteModel? result = await Navigator.of(context).push<NoteModel>(
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );

    // null means there was nothing to save.
    if (result == null || !mounted) return;

    final NoteProvider provider = context.read<NoteProvider>();
    if (note == null) {
      provider.addNote(result);
    } else {
      provider.updateNote(result);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(note == null ? 'Note saved' : 'Note updated')),
    );
  }

  // Asks for confirmation, then deletes the note.
  Future<void> _confirmDelete(NoteModel note) async {
    final String name =
        note.title.trim().isEmpty ? 'This note' : '"${note.title}"';

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.warmCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Delete note?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: AppColors.darkBrown,
            ),
          ),
          content: Text(
            '$name will be removed permanently.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.priorityHigh,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    context.read<NoteProvider>().deleteNote(note.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note deleted')),
    );
  }

  // Small section title such as "Pinned" or "Others".
  Widget _sectionTitle(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.terracotta),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Shows notes in two columns. Notes alternate: left, right, left, right...
  Widget _buildGrid(List<NoteModel> notes) {
    final List<Widget> leftColumn = [];
    final List<Widget> rightColumn = [];

    for (int i = 0; i < notes.length; i++) {
      final NoteModel note = notes[i];
      final Widget card = Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: NoteCard(
          key: ValueKey(note.id),
          note: note,
          onTap: () => _openEditor(note: note),
          onTogglePin: () => context.read<NoteProvider>().togglePin(note.id),
          onDelete: () => _confirmDelete(note),
        ),
      );

      if (i.isEven) {
        leftColumn.add(card);
      } else {
        rightColumn.add(card);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(children: leftColumn)),
        const SizedBox(width: 14),
        Expanded(child: Column(children: rightColumn)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch: this screen rebuilds whenever the notes change anywhere.
    final NoteProvider noteProvider = context.watch<NoteProvider>();
    final List<NoteModel> visibleNotes = _visibleNotes(noteProvider.notes);
    final List<NoteModel> pinnedNotes =
        visibleNotes.where((n) => n.isPinned).toList();
    final List<NoteModel> otherNotes =
        visibleNotes.where((n) => !n.isPinned).toList();
    final int totalNotes = noteProvider.totalCount;

    // "All" followed by every category.
    final List<String> categoryOptions = ['All', ...NoteModel.categories];

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New Note',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Notes',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalNotes ${totalNotes == 1 ? 'note' : 'notes'}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.darkBrown,
                ),
                decoration: InputDecoration(
                  hintText: 'Search notes',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.terracotta,
                  ),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Category chips
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: categoryOptions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final String category = categoryOptions[index];
                  final bool isSelected = category == _selectedCategory;

                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = category),
                    selectedColor: AppColors.terracotta,
                    backgroundColor: AppColors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.terracotta
                          : AppColors.softBeige,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? AppColors.white : AppColors.darkBrown,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Notes or empty state
            Expanded(
              child: visibleNotes.isEmpty
                  ? _EmptyState(
                      isSearching: _searchQuery.trim().isNotEmpty,
                      isFiltered: _selectedCategory != 'All',
                    )
                  : SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pinnedNotes.isNotEmpty) ...[
                            _sectionTitle('Pinned',
                                icon: Icons.push_pin_rounded),
                            _buildGrid(pinnedNotes),
                          ],
                          if (otherNotes.isNotEmpty) ...[
                            // Only show the "Others" title when there are
                            // also pinned notes above it.
                            if (pinnedNotes.isNotEmpty)
                              _sectionTitle('Others'),
                            _buildGrid(otherNotes),
                          ],
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

/// Friendly message shown when no note matches.
class _EmptyState extends StatelessWidget {
  final bool isSearching;
  final bool isFiltered;

  const _EmptyState({required this.isSearching, required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    String title;
    String message;
    IconData icon;

    if (isSearching) {
      title = 'No results found';
      message = 'Try a different word.';
      icon = Icons.search_off_rounded;
    } else if (isFiltered) {
      title = 'No notes here';
      message = 'You have no notes in this category yet.';
      icon = Icons.folder_open_rounded;
    } else {
      title = 'No notes yet';
      message = 'Tap "New Note" to write your first one.';
      icon = Icons.edit_note_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.lightApricot,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 46, color: AppColors.terracotta),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}