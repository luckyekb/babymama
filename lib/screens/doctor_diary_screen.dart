import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/doctor_diary_provider.dart';
import '../models/doctor_visit.dart';
import 'add_doctor_visit_screen.dart';

class DoctorDiaryScreen extends StatelessWidget {
  const DoctorDiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Дневник врача'),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<DoctorDiaryProvider>(
        builder: (context, provider, _) {
          if (!provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final upcomingVisits = provider.getUpcomingVisits();
          final pastVisits = provider.getPastVisits();

          if (provider.visits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет записей о визитах',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Добавьте первый визит к врачу',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcomingVisits.isNotEmpty) ...[
                Text(
                  'Предстоящие визиты',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...upcomingVisits.map((visit) => _VisitCard(
                      visit: visit,
                      isUpcoming: true,
                    )),
                const SizedBox(height: 24),
              ],
              if (pastVisits.isNotEmpty) ...[
                Text(
                  'Прошедшие визиты',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...pastVisits.map((visit) => _VisitCard(
                      visit: visit,
                      isUpcoming: false,
                    )),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDoctorVisitScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Добавить визит'),
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final DoctorVisit visit;
  final bool isUpcoming;

  const _VisitCard({
    required this.visit,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy, HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDoctorVisitScreen(visit: visit),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isUpcoming ? Icons.event_available : Icons.event,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateFormat.format(visit.date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (isUpcoming)
                    Chip(
                      label: const Text('Скоро'),
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              if (visit.doctorName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      visit.doctorName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
              if (visit.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  visit.notes,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (visit.weight != null || visit.bloodPressure != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (visit.weight != null) ...[
                      Icon(Icons.monitor_weight_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${visit.weight} кг',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 16),
                    ],
                    if (visit.bloodPressure != null) ...[
                      Icon(Icons.favorite_outline,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(visit.bloodPressure!,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
