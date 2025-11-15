import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pregnancy_provider.dart';
import '../models/pregnancy_week.dart';

class WeekDetailScreen extends StatefulWidget {
  final int weekNumber;

  const WeekDetailScreen({
    super.key,
    required this.weekNumber,
  });

  @override
  State<WeekDetailScreen> createState() => _WeekDetailScreenState();
}

class _WeekDetailScreenState extends State<WeekDetailScreen> {
  late int currentWeekNumber;

  @override
  void initState() {
    super.initState();
    currentWeekNumber = widget.weekNumber;
  }

  void _previousWeek() {
    if (currentWeekNumber > 1) {
      setState(() {
        currentWeekNumber--;
      });
    }
  }

  void _nextWeek() {
    if (currentWeekNumber < 40) {
      setState(() {
        currentWeekNumber++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PregnancyProvider>(
      builder: (context, provider, _) {
        final weekData = provider.getWeekData(currentWeekNumber);
        final isCurrentWeek = currentWeekNumber == provider.getCurrentWeek();

        return Scaffold(
          appBar: AppBar(
            title: Text('Неделя $currentWeekNumber'),
            backgroundColor: Colors.transparent,
            actions: [
              if (isCurrentWeek)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Chip(
                    label: const Text(
                      'Текущая',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Фрукт карточка
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Text(
                                  weekData.fruitEmoji,
                                  style: const TextStyle(fontSize: 120),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  weekData.fruitName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Размер: ${weekData.babySize}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Развитие малыша
                        _buildSection(
                          context,
                          icon: Icons.child_care,
                          title: 'Развитие малыша',
                          content: weekData.babyDevelopment,
                          color: Colors.pink.shade50,
                        ),
                        const SizedBox(height: 16),

                        // Изменения в теле
                        _buildSection(
                          context,
                          icon: Icons.pregnant_woman,
                          title: 'Изменения в вашем теле',
                          content: weekData.bodyChanges,
                          color: Colors.purple.shade50,
                        ),
                        const SizedBox(height: 16),

                        // Симптомы
                        _buildListSection(
                          context,
                          icon: Icons.health_and_safety,
                          title: 'Возможные симптомы',
                          items: weekData.symptoms,
                          color: Colors.blue.shade50,
                        ),
                        const SizedBox(height: 16),

                        // Питание
                        _buildListSection(
                          context,
                          icon: Icons.restaurant,
                          title: 'Советы по питанию',
                          items: weekData.nutritionTips,
                          color: Colors.green.shade50,
                        ),
                        const SizedBox(height: 16),

                        // Общие советы
                        _buildListSection(
                          context,
                          icon: Icons.lightbulb_outline,
                          title: 'Полезные советы',
                          items: weekData.generalTips,
                          color: Colors.amber.shade50,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Навигация между неделями
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              currentWeekNumber > 1 ? _previousWeek : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Предыдущая'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              currentWeekNumber < 40 ? _nextWeek : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Следующая'),
                          iconAlignment: IconAlignment.end,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
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
