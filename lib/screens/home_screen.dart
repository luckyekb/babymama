import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pregnancy_provider.dart';
import 'week_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PregnancyProvider>(
        builder: (context, provider, _) {
          final currentWeek = provider.getCurrentWeek();
          final weekData = provider.getCurrentWeekData();
          final daysInWeek = provider.getDaysInCurrentWeek();
          final weeksRemaining = provider.getWeeksRemainingText();

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                ],
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    title: const Text('BabyMama'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () {
                          _showSettingsDialog(context, provider);
                        },
                      ),
                    ],
                  ),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Неделя и прогресс
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Неделя $currentWeek',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'День $daysInWeek из 7',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                weeksRemaining,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Карточка с фруктом
                        Card(
                          elevation: 4,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WeekDetailScreen(
                                    weekNumber: currentWeek,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Ваш малыш размером с',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 16),

                                  // Фрукт эмодзи
                                  Text(
                                    weekData.fruitEmoji,
                                    style: const TextStyle(fontSize: 100),
                                  ),
                                  const SizedBox(height: 16),

                                  Text(
                                    weekData.fruitName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    weekData.babySize,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Краткая информация
                        _buildInfoCard(
                          context,
                          icon: Icons.favorite,
                          title: 'Развитие малыша',
                          content: weekData.babyDevelopment,
                          color: Colors.pink.shade100,
                        ),
                        const SizedBox(height: 16),

                        _buildInfoCard(
                          context,
                          icon: Icons.person,
                          title: 'Изменения в вашем теле',
                          content: weekData.bodyChanges,
                          color: Colors.purple.shade100,
                        ),
                        const SizedBox(height: 24),

                        // Кнопка подробнее
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WeekDetailScreen(
                                  weekNumber: currentWeek,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Подробная информация'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Кнопка посмотреть другие недели
                        OutlinedButton.icon(
                          onPressed: () {
                            _showWeekSelector(context, provider);
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Посмотреть другие недели'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(
      BuildContext context, PregnancyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройки'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_calendar),
              title: const Text('Изменить дату'),
              subtitle: Text(
                'Текущий срок: ${provider.getCurrentWeek()} недель',
              ),
              onTap: () {
                Navigator.pop(context);
                _showDateChangeDialog(context, provider);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showDateChangeDialog(
      BuildContext context, PregnancyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить дату'),
        content: const Text(
          'Вы хотите изменить дату последних месячных или предполагаемую дату родов?',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final date = await showDatePicker(
                context: context,
                initialDate:
                    DateTime.now().subtract(const Duration(days: 90)),
                firstDate:
                    DateTime.now().subtract(const Duration(days: 280)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                provider.setLastPeriodDate(date);
              }
            },
            child: const Text('Дата месячных'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 100)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 280)),
              );
              if (date != null) {
                provider.setDueDate(date);
              }
            },
            child: const Text('Дата родов'),
          ),
        ],
      ),
    );
  }

  void _showWeekSelector(BuildContext context, PregnancyProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 400,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Выберите неделю',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 40,
                itemBuilder: (context, index) {
                  final weekNumber = index + 1;
                  final isCurrent = weekNumber == provider.getCurrentWeek();

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WeekDetailScreen(weekNumber: weekNumber),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$weekNumber',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? Colors.white : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
