import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/error_handler.dart';
import '../../core/utils/validators.dart';
import '../../services/quiz_service.dart';
import '../../models/quiz_model.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quizService = QuizService();

  List<Question> _questions = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addQuestionDialog() {
    final questionCtrl = TextEditingController();
    final optionControllers = List.generate(4, (_) => TextEditingController());
    int correctIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Yangi savol',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),

                    // Question text
                    TextFormField(
                      controller: questionCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Savol matni',
                        hintText: 'Savolni yozing...',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Option fields
                    ...List.generate(4, (i) {
                      final labels = ['A', 'B', 'C', 'D'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            // Radio button for correct answer
                            GestureDetector(
                              onTap: () => setSheetState(() => correctIndex = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: correctIndex == i
                                      ? AppConstants.successColor
                                      : Colors.grey.shade200,
                                ),
                                child: Center(
                                  child: Text(
                                    labels[i],
                                    style: TextStyle(
                                      color: correctIndex == i
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: optionControllers[i],
                                decoration: InputDecoration(
                                  hintText: 'Variant ${labels[i]}',
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                    Text(
                      'To\'g\'ri javobni tanlash uchun harfni bosing',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 20),

                    // Add button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (questionCtrl.text.trim().isEmpty) {
                            ErrorHandler.showError(ctx, 'Savol matnini kiriting');
                            return;
                          }
                          final hasEmptyOption = optionControllers.any(
                            (c) => c.text.trim().isEmpty,
                          );
                          if (hasEmptyOption) {
                            ErrorHandler.showError(ctx, 'Barcha variantlarni to\'ldiring');
                            return;
                          }

                          setState(() {
                            _questions.add(Question(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              questionText: questionCtrl.text.trim(),
                              options: optionControllers.map((c) => c.text.trim()).toList(),
                              correctAnswerIndex: correctIndex,
                            ));
                          });

                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.successColor,
                        ),
                        child: const Text('Qo\'shish'),
                      ),
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

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    if (_questions.isEmpty) {
      ErrorHandler.showError(context, 'Kamida 1 ta savol qo\'shing');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Foydalanuvchi topilmadi');

      final quiz = Quiz(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdBy: user.uid,
        questions: _questions,
      );

      await _quizService.createQuiz(quiz);

      if (mounted) {
        ErrorHandler.showSuccess(context, 'Quiz muvaffaqiyatli yaratildi!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, 'Xatolik: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Quiz yaratish'),
        actions: [
          if (_questions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _isLoading ? null : _saveQuiz,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Saqlash'),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Form fields
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    validator: (v) => Validators.required(v, 'Quiz nomi'),
                    decoration: InputDecoration(
                      labelText: 'Quiz nomi',
                      hintText: 'Masalan: Flutter Asoslari',
                      prefixIcon: const Icon(Icons.title, color: AppConstants.primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Tavsif (ixtiyoriy)',
                      hintText: 'Quiz haqida qisqacha...',
                      prefixIcon: const Icon(Icons.description_outlined, color: AppConstants.primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Questions header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Savollar (${_questions.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                FilledButton.tonalIcon(
                  onPressed: _addQuestionDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Savol qo\'shish'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Questions list
          Expanded(
            child: _questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.help_outline, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Hozircha savollar yo\'q',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _questions.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _questions.removeAt(oldIndex);
                        _questions.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final q = _questions[index];
                      return _buildQuestionCard(q, index);
                    },
                  ),
          ),

          // Save button (bottom)
          if (_questions.isNotEmpty)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveQuiz,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Quizni saqlash'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question q, int index) {
    return Container(
      key: ValueKey(q.id),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    q.questionText,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppConstants.errorColor, size: 20),
                  onPressed: () => setState(() => _questions.removeAt(index)),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: List.generate(q.options.length, (i) {
                final isCorrect = i == q.correctAnswerIndex;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? AppConstants.successColor.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: isCorrect
                        ? Border.all(color: AppConstants.successColor.withOpacity(0.3))
                        : null,
                  ),
                  child: Text(
                    '${String.fromCharCode(65 + i)}: ${q.options[i]}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCorrect ? AppConstants.successColor : Colors.grey.shade700,
                      fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
