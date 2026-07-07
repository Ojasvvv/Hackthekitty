import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'task_provider.dart';
import '../domain/cat_task.dart';
import '../../../shared/widgets/lottie_cat_avatar.dart';

class ScratchpadScreen extends ConsumerWidget {
  const ScratchpadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Scratchpad', 
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 22, 
            fontWeight: FontWeight.w800,
            color: const Color(0xFFD66B44), // AppColors.marmaladeDeep
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const LottieCatAvatar(
                            size: 200,
                            assetPath: 'assets/animations/cat_work.json',
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No prey in sight...',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3A3532), // AppColors.ink
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildPreyItem(context, ref, tasks[index]);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: ElevatedButton(
                onPressed: () => _showPreyDialog(context, ref),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🐾', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('Spot New Prey', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildPreyItem(BuildContext context, WidgetRef ref, CatTask task) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: task.isHunted ? const Color(0xFFDCD0BC) : const Color(0xFFFFFDF9), // line : white
        border: Border.all(color: const Color(0xFF3A3532), width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0xFFDCD0BC), offset: Offset(4, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => ref.read(taskProvider.notifier).huntPrey(task.id),
          onLongPress: () => _showPreyDialog(context, ref, task: task),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => ref.read(taskProvider.notifier).huntPrey(task.id),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: task.isHunted ? const Color(0xFF7C9082) : const Color(0xFFFFFDF9), // sage : white
                      border: Border.all(color: const Color(0xFF3A3532), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: task.isHunted
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: task.isHunted ? TextDecoration.lineThrough : null,
                          color: task.isHunted ? const Color(0xFF6B625B) : const Color(0xFF3A3532), // inkSoft : ink
                        ),
                      ),
                      if (task.deadline != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('⏳', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d, h:mm a').format(task.deadline!),
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: task.isHunted ? const Color(0xFF6B625B) : const Color(0xFFD66B44), // inkSoft : marmaladeDeep
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(taskProvider.notifier).tossInLitterbox(task.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE58765).withValues(alpha: 0.15), // marmalade transparent
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3A3532), width: 1.5),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD66B44), size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPreyDialog(BuildContext context, WidgetRef ref, {CatTask? task}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    DateTime? selectedDeadline = task?.deadline;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFDF9),
                  border: Border(
                    top: BorderSide(color: Color(0xFF3A3532), width: 2),
                    left: BorderSide(color: Color(0xFF3A3532), width: 2),
                    right: BorderSide(color: Color(0xFF3A3532), width: 2),
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      task == null ? 'Spot New Prey' : 'Edit Prey',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Color(0xFF3A3532),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3A3532),
                      ),
                      decoration: InputDecoration(
                        hintText: 'What is the prey?',
                        filled: true,
                        fillColor: const Color(0xFFF0EBE1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF3A3532), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF3A3532), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD66B44), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Text('⏳', style: TextStyle(fontSize: 16)),
                      label: Text(
                        selectedDeadline == null 
                            ? 'Set Hunting Deadline' 
                            : DateFormat('MMM d, h:mm a').format(selectedDeadline!),
                        style: const TextStyle(color: Color(0xFF3A3532)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFC94C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF3A3532), width: 2),
                        ),
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDeadline ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDeadline ?? DateTime.now()),
                          );
                          if (time != null) {
                            setState(() {
                              selectedDeadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        if (task == null) {
                          ref.read(taskProvider.notifier).addPrey(titleController.text.trim(), selectedDeadline);
                        } else {
                          ref.read(taskProvider.notifier).editPrey(task.id, titleController.text.trim(), selectedDeadline);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(task == null ? 'Save Prey' : 'Update Prey'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
