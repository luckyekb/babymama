import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pregnancy_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  DateTime? selectedDate;
  bool useDueDate = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 90)),
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
      lastDate: DateTime.now(),
      helpText: useDueDate
          ? 'Выберите предполагаемую дату родов'
          : 'Выберите дату последних месячных',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _continue() {
    if (selectedDate == null) return;

    final provider = Provider.of<PregnancyProvider>(context, listen: false);

    if (useDueDate) {
      provider.setDueDate(selectedDate!);
    } else {
      provider.setLastPeriodDate(selectedDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Emoji
                const Text(
                  '🤰',
                  style: TextStyle(fontSize: 80),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Заголовок
                Text(
                  'Добро пожаловать!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  'Давайте начнем отслеживать вашу беременность',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Переключатель метода
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Как вы хотите указать срок?',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),

                        RadioListTile<bool>(
                          title: const Text('По дате последних месячных'),
                          subtitle: const Text('Обычно более точный способ'),
                          value: false,
                          groupValue: useDueDate,
                          onChanged: (value) {
                            setState(() {
                              useDueDate = value!;
                              selectedDate = null;
                            });
                          },
                        ),

                        RadioListTile<bool>(
                          title: const Text('По предполагаемой дате родов'),
                          subtitle: const Text('Если врач уже сказал срок'),
                          value: true,
                          groupValue: useDueDate,
                          onChanged: (value) {
                            setState(() {
                              useDueDate = value!;
                              selectedDate = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Кнопка выбора даты
                OutlinedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    selectedDate == null
                        ? (useDueDate
                            ? 'Выбрать дату родов'
                            : 'Выбрать дату месячных')
                        : '${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),

                // Кнопка продолжить
                FilledButton(
                  onPressed: selectedDate == null ? null : _continue,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    'Продолжить',
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                const Spacer(),

                // Подсказка
                Text(
                  'Вы всегда сможете изменить дату позже',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
