import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../models/task_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

/// Form for adding a new task or editing an existing one.
/// - Pass [task] to edit it. Leave it null to add a new task.
/// - When saved, the finished TaskModel is sent back with Navigator.pop.
class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late String _category;
  late TaskPriority _priority;
  late DateTime _dueDate;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    final task = widget.task;
    if (task != null) {
      // Editing: start with the task's current values.
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _category = task.category;
      _priority = task.priority;
      _dueDate = task.dueDate;
    } else {
      // Adding: start with sensible defaults.
      _category = TaskModel.categories.first;
      _priority = TaskPriority.medium;
      _dueDate = DateTime.now().add(const Duration(hours: 1));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Checks that a title was entered.
  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'Please enter a task title';
    return null;
  }

  // Opens the date picker and keeps the current time.
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      _dueDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _dueDate.hour,
        _dueDate.minute,
      );
    });
  }

  // Opens the time picker and keeps the current date.
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (picked == null) return;

    setState(() {
      _dueDate = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  // Builds the task and sends it back to the previous screen.
  void _saveTask() {
    // Stop here if the title is empty.
    if (!_formKey.currentState!.validate()) return;

    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();

    final TaskModel result;
    if (_isEditing) {
      result = widget.task!.copyWith(
        title: title,
        description: description,
        category: _category,
        priority: _priority,
        dueDate: _dueDate,
      );
    } else {
      final DateTime now = DateTime.now();
      result = TaskModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        category: _category,
        priority: _priority,
        dueDate: _dueDate,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );
    }

    Navigator.of(context).pop(result);
  }

  // Small bold label above a section.
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkBrown,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                CustomTextField(
                  label: 'Title',
                  hint: 'What needs to be done?',
                  prefixIcon: Icons.edit_outlined,
                  controller: _titleController,
                  validator: _validateTitle,
                ),
                const SizedBox(height: 20),

                // Description
                _sectionLabel('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.darkBrown,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Add some details (optional)',
                  ),
                ),
                const SizedBox(height: 24),

                // Due date and time
                _sectionLabel('Due date and time'),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _PickerTile(
                        icon: Icons.calendar_today_rounded,
                        text: DateFormat('EEE, d MMM yyyy').format(_dueDate),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _PickerTile(
                        icon: Icons.schedule_rounded,
                        text: DateFormat('h:mm a').format(_dueDate),
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Priority
                _sectionLabel('Priority'),
                Wrap(
                  spacing: 10,
                  children: TaskPriority.values.map((priority) {
                    final bool isSelected = priority == _priority;
                    return ChoiceChip(
                      label: Text(priority.label),
                      selected: isSelected,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _priority = priority),
                      selectedColor: priority.color,
                      backgroundColor: AppColors.white,
                      side: BorderSide(
                        color: isSelected ? priority.color : AppColors.softBeige,
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
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Category
                _sectionLabel('Category'),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: TaskModel.categories.map((category) {
                    final bool isSelected = category == _category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _category = category),
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
                  }).toList(),
                ),
                const SizedBox(height: 36),

                // Save button
                CustomButton(
                  label: _isEditing ? 'Update Task' : 'Save Task',
                  icon: Icons.check_rounded,
                  onPressed: _saveTask,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tappable white box showing a date or a time.
class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.softBeige),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.terracotta),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}