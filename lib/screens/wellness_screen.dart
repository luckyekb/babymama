import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import '../providers/wellness_provider.dart';
import '../models/wellness_entry.dart';

class WellnessScreen extends StatelessWidget {
  const WellnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вес и самочувствие'),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<WellnessProvider>(
        builder: (context, provider, _) {
          if (!provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final latestWeight = provider.getLatestWeight();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Текущий вес
              if (latestWeight != null)
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Текущий вес',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$latestWeight кг',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // График веса
              if (provider.getEntriesWithWeight().length >= 2) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'График веса',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: _WeightChart(
                            entries: provider.getEntriesWithWeight(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // История записей
              if (provider.entries.isNotEmpty) ...[
                Text(
                  'История записей',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...provider.entries.map((entry) => _EntryCard(entry: entry)),
              ],

              if (provider.entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.favorite_outline,
                          size: 80,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нет записей',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Добавьте первую запись о самочувствии',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddEntryDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Добавить запись'),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    final weightController = TextEditingController();
    final bloodPressureController = TextEditingController();
    final notesController = TextEditingController();
    int? selectedMood;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Новая запись'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Вес (кг)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monitor_weight),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bloodPressureController,
                  decoration: const InputDecoration(
                    labelText: 'Давление',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.favorite),
                    hintText: '120/80',
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Настроение:'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        final mood = index + 1;
                        final emojis = ['😢', '😕', '😐', '🙂', '😊'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMood = mood;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedMood == mood
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              emojis[index],
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Заметки',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final entry = WellnessEntry(
                  id: const Uuid().v4(),
                  date: DateTime.now(),
                  weight: weightController.text.isEmpty
                      ? null
                      : double.tryParse(weightController.text),
                  bloodPressure: bloodPressureController.text.isEmpty
                      ? null
                      : bloodPressureController.text,
                  mood: selectedMood,
                  notes: notesController.text,
                );

                Provider.of<WellnessProvider>(dialogContext, listen: false)
                    .addEntry(entry);
                Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final WellnessEntry entry;

  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'ru_RU');
    final moodEmojis = ['😢', '😕', '😐', '🙂', '😊'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(entry.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (entry.mood != null)
                  Text(
                    moodEmojis[entry.mood! - 1],
                    style: const TextStyle(fontSize: 24),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (entry.weight != null || entry.bloodPressure != null)
              Row(
                children: [
                  if (entry.weight != null) ...[
                    Icon(Icons.monitor_weight_outlined,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${entry.weight} кг',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: 16),
                  ],
                  if (entry.bloodPressure != null) ...[
                    Icon(Icons.favorite_outline,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(entry.bloodPressure!,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            if (entry.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                entry.notes,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<WellnessEntry> entries;

  const _WeightChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    final spots = entries.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.weight!,
      );
    }).toList();

    final minWeight = entries.map((e) => e.weight!).reduce((a, b) => a < b ? a : b);
    final maxWeight = entries.map((e) => e.weight!).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= entries.length) return const Text('');
                final date = entries[value.toInt()].date;
                return Text(
                  '${date.day}/${date.month}',
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 22,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minY: minWeight - 2,
        maxY: maxWeight + 2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
