import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../utils/modelsAndRepsositories/models_and_repositories.dart';
import '../../../utils/providers/providers.dart';

class PracticeTestsPage extends StatefulWidget {
  const PracticeTestsPage({super.key});

  @override
  _PracticeTestsPageState createState() => _PracticeTestsPageState();
}

class _PracticeTestsPageState extends State<PracticeTestsPage> {
  String _selectedSubject = 'All';
  String _selectedDifficulty = 'All';
  String _sortBy = 'title'; // Updated to match Firestore field

  final List<String> _subjects = [
    'All',
    'Mathematics',
    'Chemistry',
    'Computer Science',
    'English',
  ];
  final List<String> _difficulties = ['All', 'Easy', 'Medium', 'Hard'];
  final List<String> _sortOptions = [
    'title',
    'difficulty',
    'completion',
    'questions',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      Provider.of<PracticeTestsProvider>(
        context,
        listen: false,
      ).loadPracticeTests(
        userId: userId,
        subject: _selectedSubject,
        difficulty: _selectedDifficulty,
        sortBy: _sortBy,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Tests'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                Provider.of<PracticeTestsProvider>(
                  context,
                  listen: false,
                ).loadPracticeTests(
                  userId: FirebaseAuth.instance.currentUser?.uid,
                  subject: _selectedSubject,
                  difficulty: _selectedDifficulty,
                  sortBy: _sortBy,
                  forceRefresh: true,
                );
              });
            },
            itemBuilder:
                (context) =>
                    _sortOptions.map((option) {
                      return PopupMenuItem(
                        value: option,
                        child: Row(
                          children: [
                            Icon(
                              _sortBy == option
                                  ? Icons.check
                                  : Icons.sort_by_alpha,
                            ),
                            const SizedBox(width: 8),
                            Text('Sort by ${option.capitalize()}'),
                          ],
                        ),
                      );
                    }).toList(),
          ),
        ],
      ),
      body: Consumer<PracticeTestsProvider>(
        builder: (context, provider, child) {
          if (FirebaseAuth.instance.currentUser == null) {
            return const Center(child: Text('Please log in to view tests.'));
          }

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final tests = provider.practiceTests ?? [];

          return Column(
            children: [
              _buildFilterSection(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    final test = tests[index];
                    return _buildTestCard(context, test);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items:
                  _subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value!;
                  Provider.of<PracticeTestsProvider>(
                    context,
                    listen: false,
                  ).loadPracticeTests(
                    userId: FirebaseAuth.instance.currentUser?.uid,
                    subject: _selectedSubject,
                    difficulty: _selectedDifficulty,
                    sortBy: _sortBy,
                    forceRefresh: true,
                  );
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items:
                  _difficulties.map((difficulty) {
                    return DropdownMenuItem(
                      value: difficulty,
                      child: Text(difficulty),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                  Provider.of<PracticeTestsProvider>(
                    context,
                    listen: false,
                  ).loadPracticeTests(
                    userId: FirebaseAuth.instance.currentUser?.uid,
                    subject: _selectedSubject,
                    difficulty: _selectedDifficulty,
                    sortBy: _sortBy,
                    forceRefresh: true,
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, PracticeTest test) {
    Color difficultyColor;
    switch (test.difficulty.toLowerCase()) {
      case 'easy':
        difficultyColor = Colors.green;
        break;
      case 'medium':
        difficultyColor = Colors.orange;
        break;
      case 'hard':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExamPage(testData: test)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      test.subject,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(test.difficulty),
                    backgroundColor: difficultyColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: difficultyColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                test.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(test.description, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.help_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${test.questions} questions'),
                  const SizedBox(width: 16),
                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(test.duration),
                  const SizedBox(width: 16),
                  const Icon(Icons.grade, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${test.totalMarks} marks'),
                ],
              ),
              const SizedBox(height: 16),
              if (test.completion > 0)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: test.completion,
                      backgroundColor: Colors.grey[200],
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(test.completion * 100).toInt()}% completed',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExamPage(testData: test),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('Start Test'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Exam Page
class ExamPage extends StatefulWidget {
  final PracticeTest testData;

  const ExamPage({super.key, required this.testData});

  @override
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> with TickerProviderStateMixin {
  late AnimationController _timerController;
  int _currentQuestionIndex = 0;
  final Map<int, String> _selectedAnswers = {};
  bool _isExamStarted = false;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PracticeTestsProvider>(
        context,
        listen: false,
      ).loadTestQuestions(widget.testData.id);
    });
  }

  void _initializeTimer() {
    int minutes = int.parse(widget.testData.duration.split(' ')[0]);
    _timeRemaining = Duration(minutes: minutes);
    _timerController = AnimationController(
      duration: _timeRemaining,
      vsync: this,
    );
  }

  void _startExam() {
    setState(() {
      _isExamStarted = true;
    });
    _timerController.forward();
    _startTimer();
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining.inSeconds <= 0) {
        timer.cancel();
        _submitExam();
      } else {
        setState(() {
          _timeRemaining = Duration(seconds: _timeRemaining.inSeconds - 1);
        });
      }
    });
  }

  void _submitExam() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('You must be logged in to submit the exam.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    Provider.of<PracticeTestsProvider>(context, listen: false)
        .submitTestAnswers(widget.testData.id, _selectedAnswers, userId)
        .then((_) {
          final provider = Provider.of<PracticeTestsProvider>(
            context,
            listen: false,
          );
          final results = provider.testResults;
          if (results != null) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Exam Completed!'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          results['score'] >= 70
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 64,
                          color:
                              results['score'] >= 70
                                  ? Colors.green
                                  : Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Score: ${results['score'].toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${results['correct']} out of ${results['total']} correct',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Back to Tests'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _restartExam();
                        },
                        child: const Text('Retake'),
                      ),
                    ],
                  ),
            );
          }
        })
        .catchError((e) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Error'),
                  content: Text('Failed to submit exam: $e'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        });
  }

  void _restartExam() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
      _isExamStarted = false;
    });
    _timerController.reset();
    _initializeTimer();
    Provider.of<PracticeTestsProvider>(
      context,
      listen: false,
    ).loadTestQuestions(widget.testData.id);
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PracticeTestsProvider>(
      builder: (context, provider, child) {
        if (!_isExamStarted) {
          return _buildExamInstructions();
        }

        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            body: Center(child: Text('Error: ${provider.error}')),
          );
        }

        final questions = provider.testQuestions ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.testData.title),
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color:
                      _timeRemaining.inMinutes < 5 ? Colors.red : Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_timeRemaining.inMinutes}:${(_timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body:
              questions.isEmpty
                  ? const Center(child: Text('No questions available'))
                  : Column(
                    children: [
                      _buildProgressBar(questions.length),
                      Expanded(child: _buildQuestionContent(questions)),
                      _buildNavigationButtons(questions.length),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildExamInstructions() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.testData.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exam Instructions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildInstructionItem('Duration: ${widget.testData.duration}'),
            _buildInstructionItem('Questions: ${widget.testData.questions}'),
            _buildInstructionItem('Total Marks: ${widget.testData.totalMarks}'),
            _buildInstructionItem('Passing Score: 70%'),
            const SizedBox(height: 24),
            const Text(
              'Rules:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRuleItem(
              'You cannot go back to previous questions once submitted',
            ),
            _buildRuleItem('The exam will auto-submit when time runs out'),
            _buildRuleItem('Make sure you have a stable internet connection'),
            _buildRuleItem('Do not refresh the page during the exam'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.testData.description,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startExam,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Start Exam'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int totalQuestions) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${_currentQuestionIndex + 1} of $totalQuestions'),
              Text('${_selectedAnswers.length}/$totalQuestions answered'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / totalQuestions,
            backgroundColor: Colors.grey[200],
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(List<TestQuestion> questions) {
    final question = questions[_currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ...question.options.map<Widget>((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _selectedAnswers[_currentQuestionIndex],
              onChanged: (value) {
                setState(() {
                  _selectedAnswers[_currentQuestionIndex] = value!;
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(int totalQuestions) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentQuestionIndex--;
                  });
                },
                child: const Text('Previous'),
              ),
            ),
          if (_currentQuestionIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  _selectedAnswers.containsKey(_currentQuestionIndex)
                      ? () {
                        if (_currentQuestionIndex < totalQuestions - 1) {
                          setState(() {
                            _currentQuestionIndex++;
                          });
                        } else {
                          _showSubmitDialog();
                        }
                      }
                      : null,
              child: Text(
                _currentQuestionIndex < totalQuestions - 1 ? 'Next' : 'Submit',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Submit Exam'),
            content: Text(
              'Are you sure you want to submit your exam? '
              'You have answered ${_selectedAnswers.length} out of ${Provider.of<PracticeTestsProvider>(context, listen: false).testQuestions?.length ?? 0} questions.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _submitExam();
                },
                child: const Text('Submit'),
              ),
            ],
          ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
