import 'package:flutter/material.dart';
import 'dart:async';

// Enhanced Practice Tests Page with Filtering and Sorting
class PracticeTestsPage extends StatefulWidget {
  const PracticeTestsPage({super.key});

  @override
  _PracticeTestsPageState createState() => _PracticeTestsPageState();
}

class _PracticeTestsPageState extends State<PracticeTestsPage> {
  String _selectedSubject = 'All';
  String _selectedDifficulty = 'All';
  String _sortBy = 'Name';

  final List<String> _subjects = [
    'All',
    'Mathematics',
    'Chemistry',
    'Computer Science',
    'English',
  ];
  final List<String> _difficulties = ['All', 'Easy', 'Medium', 'Hard'];
  final List<String> _sortOptions = [
    'Name',
    'Difficulty',
    'Progress',
    'Questions',
  ];

  final List<Map<String, dynamic>> _allTests = [
    {
      'title': 'Calculus Fundamentals',
      'subject': 'Mathematics',
      'questions': 25,
      'duration': '30 mins',
      'difficulty': 'Medium',
      'completion': 0.4,
      'totalMarks': 100,
      'description':
          'Test your understanding of calculus basics including limits, derivatives, and integrals.',
    },
    {
      'title': 'Organic Chemistry',
      'subject': 'Chemistry',
      'questions': 20,
      'duration': '25 mins',
      'difficulty': 'Hard',
      'completion': 0.8,
      'totalMarks': 80,
      'description':
          'Advanced organic chemistry concepts including reactions and mechanisms.',
    },
    {
      'title': 'Python Basics',
      'subject': 'Computer Science',
      'questions': 15,
      'duration': '20 mins',
      'difficulty': 'Easy',
      'completion': 0.2,
      'totalMarks': 60,
      'description': 'Fundamental Python programming concepts and syntax.',
    },
    {
      'title': 'Literary Analysis',
      'subject': 'English',
      'questions': 10,
      'duration': '15 mins',
      'difficulty': 'Medium',
      'completion': 0.0,
      'totalMarks': 40,
      'description':
          'Analyze literary works and understand various literary devices.',
    },
  ];

  List<Map<String, dynamic>> get _filteredAndSortedTests {
    List<Map<String, dynamic>> filtered =
        _allTests.where((test) {
          bool subjectMatch =
              _selectedSubject == 'All' || test['subject'] == _selectedSubject;
          bool difficultyMatch =
              _selectedDifficulty == 'All' ||
              test['difficulty'] == _selectedDifficulty;
          return subjectMatch && difficultyMatch;
        }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'Name':
          return a['title'].compareTo(b['title']);
        case 'Difficulty':
          List<String> difficultyOrder = ['Easy', 'Medium', 'Hard'];
          return difficultyOrder
              .indexOf(a['difficulty'])
              .compareTo(difficultyOrder.indexOf(b['difficulty']));
        case 'Progress':
          return b['completion'].compareTo(a['completion']);
        case 'Questions':
          return b['questions'].compareTo(a['questions']);
        default:
          return 0;
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Tests'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
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
                            SizedBox(width: 8),
                            Text('Sort by $option'),
                          ],
                        ),
                      );
                    }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _filteredAndSortedTests.length,
              itemBuilder: (context, index) {
                final test = _filteredAndSortedTests[index];
                return _buildTestCard(context, test);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: InputDecoration(
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
                });
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: InputDecoration(
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
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, Map<String, dynamic> test) {
    Color difficultyColor;
    switch (test['difficulty'].toLowerCase()) {
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
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExamPage(testData: test)),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      test['subject'],
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(test['difficulty']),
                    backgroundColor: difficultyColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: difficultyColor),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                test['title'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                test['description'],
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.help_outline, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('${test['questions']} questions'),
                  SizedBox(width: 16),
                  Icon(Icons.timer, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(test['duration']),
                  SizedBox(width: 16),
                  Icon(Icons.grade, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('${test['totalMarks']} marks'),
                ],
              ),
              SizedBox(height: 16),
              if (test['completion'] > 0)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: test['completion'],
                      backgroundColor: Colors.grey[200],
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(test['completion'] * 100).toInt()}% completed',
                        style: TextStyle(color: Colors.grey),
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
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text('Start Test'),
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
  final Map<String, dynamic> testData;

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

  // Sample questions data
  late List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _initializeQuestions();
    _initializeTimer();
  }

  void _initializeQuestions() {
    // Generate sample questions based on the test
    _questions = List.generate(widget.testData['questions'], (index) {
      return {
        'question':
            'Sample question ${index + 1} for ${widget.testData['title']}?',
        'options': [
          'Option A - First possible answer',
          'Option B - Second possible answer',
          'Option C - Third possible answer',
          'Option D - Fourth possible answer',
        ],
        'correct': 'Option A - First possible answer',
      };
    });
  }

  void _initializeTimer() {
    // Parse duration string to minutes
    String durationStr = widget.testData['duration'];
    int minutes = int.parse(durationStr.split(' ')[0]);
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
    Timer.periodic(Duration(seconds: 1), (timer) {
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
    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]['correct']) {
        correctAnswers++;
      }
    }

    double percentage = (correctAnswers / _questions.length) * 100;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Exam Completed!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  percentage >= 70 ? Icons.check_circle : Icons.cancel,
                  size: 64,
                  color: percentage >= 70 ? Colors.green : Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  'Score: ${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('$correctAnswers out of ${_questions.length} correct'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Back to Tests'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _restartExam();
                },
                child: Text('Retake'),
              ),
            ],
          ),
    );
  }

  void _restartExam() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
      _isExamStarted = false;
    });
    _timerController.reset();
    _initializeTimer();
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isExamStarted) {
      return _buildExamInstructions();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testData['title']),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: _timeRemaining.inMinutes < 5 ? Colors.red : Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_timeRemaining.inMinutes}:${(_timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(child: _buildQuestionContent()),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildExamInstructions() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.testData['title'])),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exam Instructions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            _buildInstructionItem('Duration: ${widget.testData['duration']}'),
            _buildInstructionItem('Questions: ${widget.testData['questions']}'),
            _buildInstructionItem(
              'Total Marks: ${widget.testData['totalMarks']}',
            ),
            _buildInstructionItem('Passing Score: 70%'),
            SizedBox(height: 24),
            Text(
              'Rules:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildRuleItem(
              'You cannot go back to previous questions once submitted',
            ),
            _buildRuleItem('The exam will auto-submit when time runs out'),
            _buildRuleItem('Make sure you have a stable internet connection'),
            _buildRuleItem('Do not refresh the page during the exam'),
            Spacer(),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.testData['description'],
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startExam,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Start Exam'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 12),
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.grey),
          SizedBox(width: 12),
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

  Widget _buildProgressBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              ),
              Text('${_selectedAnswers.length}/${_questions.length} answered'),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey[200],
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    final question = _questions[_currentQuestionIndex];

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question['question'],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          ...question['options'].map<Widget>((option) {
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

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(16),
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
                child: Text('Previous'),
              ),
            ),
          if (_currentQuestionIndex > 0) SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  _selectedAnswers.containsKey(_currentQuestionIndex)
                      ? () {
                        if (_currentQuestionIndex < _questions.length - 1) {
                          setState(() {
                            _currentQuestionIndex++;
                          });
                        } else {
                          _showSubmitDialog();
                        }
                      }
                      : null,
              child: Text(
                _currentQuestionIndex < _questions.length - 1
                    ? 'Next'
                    : 'Submit',
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
            title: Text('Submit Exam'),
            content: Text(
              'Are you sure you want to submit your exam? '
              'You have answered ${_selectedAnswers.length} out of ${_questions.length} questions.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _submitExam();
                },
                child: Text('Submit'),
              ),
            ],
          ),
    );
  }
}

// Import this for Timer
