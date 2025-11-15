import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/doctor_diary_provider.dart';
import '../models/doctor_visit.dart';

class AddDoctorVisitScreen extends StatefulWidget {
  final DoctorVisit? visit;

  const AddDoctorVisitScreen({super.key, this.visit});

  @override
  State<AddDoctorVisitScreen> createState() => _AddDoctorVisitScreenState();
}

class _AddDoctorVisitScreenState extends State<AddDoctorVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final _doctorNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final List<TextEditingController> _testResultsControllers = [];
  final List<TextEditingController> _questionsControllers = [];

  @override
  void initState() {
    super.initState();

    if (widget.visit != null) {
      _selectedDate = widget.visit!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.visit!.date);
      _doctorNameController.text = widget.visit!.doctorName;
      _notesController.text = widget.visit!.notes;
      if (widget.visit!.weight != null) {
        _weightController.text = widget.visit!.weight.toString();
      }
      if (widget.visit!.bloodPressure != null) {
        _bloodPressureController.text = widget.visit!.bloodPressure!;
      }

      for (var result in widget.visit!.testResults) {
        final controller = TextEditingController(text: result);
        _testResultsControllers.add(controller);
      }

      for (var question in widget.visit!.questionsToAsk) {
        final controller = TextEditingController(text: question);
        _questionsControllers.add(controller);
      }
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    _bloodPressureController.dispose();
    for (var controller in _testResultsControllers) {
      controller.dispose();
    }
    for (var controller in _questionsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTestResult() {
    setState(() {
      _testResultsControllers.add(TextEditingController());
    });
  }

  void _addQuestion() {
    setState(() {
      _questionsControllers.add(TextEditingController());
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
      lastDate: DateTime.now().add(const Duration(days: 280)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveVisit() {
    if (!_formKey.currentState!.validate()) return;

    final finalDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final testResults = _testResultsControllers
        .map((c) => c.text)
        .where((text) => text.isNotEmpty)
        .toList();

    final questions = _questionsControllers
        .map((c) => c.text)
        .where((text) => text.isNotEmpty)
        .toList();

    final visit = DoctorVisit(
      id: widget.visit?.id ?? const Uuid().v4(),
      date: finalDate,
      doctorName: _doctorNameController.text,
      notes: _notesController.text,
      testResults: testResults,
      questionsToAsk: questions,
      weight: _weightController.text.isEmpty
          ? null
          : double.tryParse(_weightController.text),
      bloodPressure: _bloodPressureController.text.isEmpty
          ? null
          : _bloodPressureController.text,
    );

    final provider = Provider.of<DoctorDiaryProvider>(context, listen: false);

    if (widget.visit != null) {
      provider.updateVisit(visit);
    } else {
      provider.addVisit(visit);
    }

    Navigator.pop(context);
  }

  void _deleteVisit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить визит?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final provider =
                  Provider.of<DoctorDiaryProvider>(context, listen: false);
              provider.deleteVisit(widget.visit!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.visit == null ? 'Добавить визит' : 'Редактировать'),
        backgroundColor: Colors.transparent,
        actions: [
          if (widget.visit != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteVisit,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Дата и время
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Дата и время',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectTime,
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Врач
            TextFormField(
              controller: _doctorNameController,
              decoration: const InputDecoration(
                labelText: 'Имя врача',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // Заметки
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Заметки о визите',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Вес и давление
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Вес (кг)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_weight),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _bloodPressureController,
                    decoration: const InputDecoration(
                      labelText: 'Давление',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.favorite),
                      hintText: '120/80',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Результаты анализов
            _buildListSection(
              title: 'Результаты анализов',
              controllers: _testResultsControllers,
              onAdd: _addTestResult,
              hint: 'Например: Гемоглобин 120',
            ),
            const SizedBox(height: 24),

            // Вопросы врачу
            _buildListSection(
              title: 'Вопросы к врачу',
              controllers: _questionsControllers,
              onAdd: _addQuestion,
              hint: 'Ваш вопрос',
            ),
            const SizedBox(height: 24),

            // Кнопка сохранить
            FilledButton(
              onPressed: _saveVisit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                widget.visit == null ? 'Добавить визит' : 'Сохранить',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Добавить'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...controllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      controllers.removeAt(index);
                      controller.dispose();
                    });
                  },
                ),
              ],
            ),
          );
        }),
        if (controllers.isEmpty)
          Text(
            'Пусто',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
      ],
    );
  }
}
