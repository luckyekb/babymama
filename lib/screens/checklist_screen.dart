import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/checklist_provider.dart';
import '../models/checklist_item.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подготовка к родам'),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, provider, _) {
          if (!provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = provider.getCategories();
          final progress = provider.getProgress();

          return Column(
            children: [
              // Прогресс
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Прогресс подготовки',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${provider.getCompletedCount()} из ${provider.getTotalCount()} выполнено',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),

              // Список по категориям
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final items = provider.getItemsByCategory(category);
                    final completedInCategory =
                        items.where((i) => i.isCompleted).length;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: completedInCategory < items.length,
                          title: Text(
                            category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '$completedInCategory/${items.length} выполнено',
                            style: TextStyle(
                              color: completedInCategory == items.length
                                  ? Colors.green
                                  : null,
                            ),
                          ),
                          children: items.map((item) {
                            return CheckboxListTile(
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  decoration: item.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: item.isCompleted
                                      ? Colors.grey
                                      : null,
                                ),
                              ),
                              subtitle: item.notes != null && item.notes!.isNotEmpty
                                  ? Text(item.notes!)
                                  : null,
                              value: item.isCompleted,
                              onChanged: (value) {
                                provider.toggleItem(item.id);
                              },
                              secondary: IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () {
                                  _showEditItemDialog(context, item);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddItemDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Добавить пункт'),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Новый пункт'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(),
                hintText: 'Например: Сумка для мамы',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Заметки (необязательно)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  categoryController.text.isEmpty) {
                return;
              }

              final item = ChecklistItem(
                id: const Uuid().v4(),
                title: titleController.text,
                category: categoryController.text,
                notes: notesController.text.isEmpty
                    ? null
                    : notesController.text,
              );

              Provider.of<ChecklistProvider>(dialogContext, listen: false)
                  .addItem(item);
              Navigator.pop(context);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, ChecklistItem item) {
    final titleController = TextEditingController(text: item.title);
    final notesController = TextEditingController(text: item.notes);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Редактировать'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Заметки',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<ChecklistProvider>(dialogContext, listen: false)
                  .deleteItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final updatedItem = item.copyWith(
                title: titleController.text,
                notes: notesController.text.isEmpty
                    ? null
                    : notesController.text,
              );

              Provider.of<ChecklistProvider>(dialogContext, listen: false)
                  .updateItem(updatedItem);
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
