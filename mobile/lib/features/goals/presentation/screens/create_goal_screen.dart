import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/create_goal_input.dart';
import '../providers/goals_provider.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _deadline;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(createGoalControllerProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (error, _) {
          final messenger = ScaffoldMessenger.of(context);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });

    final createState = ref.watch(createGoalControllerProvider);
    final deadlineText = _deadline == null
        ? 'Срок не выбран'
        : _formatDate(_deadline!);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/my-goals');
            }
          },
        ),
        title: const Text('Создать цель'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Название'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 1,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Описание'),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event_outlined),
              title: const Text('Срок'),
              subtitle: Text(deadlineText),
              trailing: TextButton(
                onPressed: createState.isLoading ? null : _pickDeadline,
                child: const Text('Выбрать'),
              ),
            ),
          ),
          if (_deadline != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: createState.isLoading
                    ? null
                    : () => setState(() => _deadline = null),
                child: const Text('Очистить срок'),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: createState.isLoading ? null : _submit,
            child: createState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Создать цель'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final initialDate = _deadline ?? now.add(const Duration(days: 7));
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );

    if (selectedDate != null) {
      setState(() {
        _deadline = selectedDate;
      });
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Введите название и описание.')),
        );
      return;
    }

    try {
      await ref
          .read(createGoalControllerProvider.notifier)
          .createGoal(
            CreateGoalInput(
              title: title,
              description: description,
              deadline: _deadline,
            ),
          );

      if (!mounted) {
        return;
      }

      context.go('/my-goals');
    } catch (_) {
      // Error feedback is handled by the provider listener above.
    }
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }
}
