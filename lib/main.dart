import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main() => runApp(const FitTrackApp());

const lime = Color(0xFFB6FF36);
const panel = Color(0xFF15191E);
const panel2 = Color(0xFF1C2127);
const muted = Color(0xFF8E96A0);
const line = Color(0xFF252B32);

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: lime, surface: panel),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lime,
          foregroundColor: bg,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),
    home: const SplashScreen(),
  );
}

class UserProfile {
  String name = 'Athlete';
  String goal = 'Build Muscle';
  String level = 'Intermediate';
  final Set<String> days = {'Mon', 'Wed', 'Fri'};
  String time = 'Morning';
  bool reminders = true;
  bool metric = true;
  List<WorkoutModel> workouts = [];
}

class WorkoutModel {
  final String title;
  final String duration;
  final String count;
  final String calories;
  final List<String> exercises;

  WorkoutModel({
    required this.title,
    required this.duration,
    required this.count,
    required this.calories,
    required this.exercises,
  });
}

class _ApiResponse {
  final int statusCode;
  final String body;

  const _ApiResponse(this.statusCode, this.body);
}

// Gemini AI Backend Service
class GeminiBackend {
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static Future<_ApiResponse> _post(Uri url, Map<String, dynamic> body) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(url);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      return _ApiResponse(response.statusCode, responseBody);
    } finally {
      client.close();
    }
  }

  static Future<List<WorkoutModel>> generateWorkouts(UserProfile user) async {
    if (_apiKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _fallback(user);
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey',
    );

    final prompt =
        '''
Generate 3 workout sessions for ${user.name}. Goal: ${user.goal}. Level: ${user.level}.
Return ONLY a JSON array of objects with keys: "title", "duration", "count", "calories", and "exercises" (array of 4 strings).
''';

    try {
      final res = await _post(url, {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {'responseMimeType': 'application/json'},
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        final List list = jsonDecode(text);
        return list
            .map(
              (e) => WorkoutModel(
                title: e['title'] ?? 'Custom Session',
                duration: e['duration'] ?? '45 min',
                count: e['count'] ?? '5 exercises',
                calories: e['calories'] ?? '320 kcal',
                exercises: List<String>.from(e['exercises'] ?? []),
              ),
            )
            .toList();
      }
    } catch (_) {}
    return _fallback(user);
  }

  static Future<String> askCoach(UserProfile user, String question) async {
    if (_apiKey.isEmpty) {
      return 'Focus on progressive overload and 1.8g of protein per kg of body weight to support your ${user.goal.toLowerCase()} goal.';
    }
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey',
    );
    try {
      final res = await _post(url, {
        'contents': [
          {
            'parts': [
              {
                'text':
                    'You are a concise fitness coach for ${user.name} (Goal: ${user.goal}, Level: ${user.level}). Answer in 2 sentences without emojis: $question',
              },
            ],
          },
        ],
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
    } catch (_) {}
    return 'Stay consistent with your ${user.days.join(', ')} schedule and keep rest periods between 60–90 seconds.';
  }

  static List<WorkoutModel> _fallback(UserProfile user) => [
    WorkoutModel(
      title: 'Upper Body Strength',
      duration: '45 min',
      count: '6 exercises',
      calories: '320 kcal',
      exercises: [
        'Incline Dumbbell Press — 3 × 10',
        'Lat Pulldown — 3 × 12',
        'Seated Shoulder Press — 3 × 10',
        'Cable Seated Row — 3 × 12',
      ],
    ),
    WorkoutModel(
      title: 'Lower Body Power',
      duration: '50 min',
      count: '5 exercises',
      calories: '380 kcal',
      exercises: [
        'Barbell Back Squat — 4 × 8',
        'Romanian Deadlift — 3 × 10',
        'Leg Press — 3 × 12',
        'Standing Calf Raises — 3 × 15',
      ],
    ),
    WorkoutModel(
      title: 'Core & Conditioning',
      duration: '30 min',
      count: '4 exercises',
      calories: '240 kcal',
      exercises: [
        'Hanging Leg Raises — 3 × 12',
        'Weighted Plank — 3 × 45 sec',
        'Cable Woodchoppers — 3 × 12',
        'Rowing Intervals — 10 min',
      ],
    ),
  ];
}

// Shared Shell & Components
class FlowShell extends StatelessWidget {
  final Widget child;
  final int setupStep; // 1..3 for profile setup, 0 otherwise
  const FlowShell({super.key, required this.child, this.setupStep = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (setupStep > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile Setup',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    Text(
                      '$setupStep of 3',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(
                    3,
                    (i) => Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                        decoration: BoxDecoration(
                          color: i < setupStep ? lime : line,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

Widget titleBlock(String first, String second, String sub) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1.18,
          color: Colors.white,
        ),
        children: [
          TextSpan(text: '$first\n'),
          TextSpan(
            text: second,
            style: const TextStyle(color: lime),
          ),
        ],
      ),
    ),
    const SizedBox(height: 8),
    Text(sub, style: const TextStyle(color: muted, fontSize: 13, height: 1.45)),
  ],
);

class SelectCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const SelectCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? lime : line),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: panel2,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: selected ? lime : Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: muted, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? lime : muted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// 1. SPLASH SCREEN (Styled after reference: clean, iconic F mark, subtle glow)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.25),
            radius: 0.85,
            colors: [Color(0x22B6FF36), bg],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'F',
                style: TextStyle(
                  fontSize: 82,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: lime,
                  height: 0.9,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'FitTrack',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Train Smarter /\nGet Stronger',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 13.5, height: 1.5),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnterNameScreen(user: UserProfile()),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Get Started',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. ENTER YOUR NAME
class EnterNameScreen extends StatefulWidget {
  final UserProfile user;
  const EnterNameScreen({super.key, required this.user});

  @override
  State<EnterNameScreen> createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<EnterNameScreen> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlowShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          titleBlock(
            "What's Your",
            'First Name?',
            'Personalize your Gemini AI workout plans and daily check-ins.',
          ),
          const SizedBox(height: 26),
          const Text(
            'Your Name',
            style: TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: const TextStyle(
                color: muted,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: panel,
              prefixIcon: const Icon(Icons.person_outline_rounded, color: lime),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: lime),
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              if (_nameCtrl.text.trim().isNotEmpty) {
                widget.user.name = _nameCtrl.text.trim();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GoalStepScreen(user: widget.user),
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 3. PROFILE SETUP (1/3): GOAL
class GoalStepScreen extends StatefulWidget {
  final UserProfile user;
  const GoalStepScreen({super.key, required this.user});

  @override
  State<GoalStepScreen> createState() => _GoalStepScreenState();
}

class _GoalStepScreenState extends State<GoalStepScreen> {
  @override
  Widget build(BuildContext context) {
    return FlowShell(
      setupStep: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock(
            "What's Your",
            'Fitness Goal?',
            'Choose one goal to get a Gemini AI personalized workout plan.',
          ),
          const SizedBox(height: 22),
          SelectCard(
            icon: Icons.fitness_center_rounded,
            title: 'Build Muscle',
            subtitle: 'Gain strength and build lean muscle',
            selected: widget.user.goal == 'Build Muscle',
            onTap: () => setState(() => widget.user.goal = 'Build Muscle'),
          ),
          SelectCard(
            icon: Icons.local_fire_department_rounded,
            title: 'Lose Weight',
            subtitle: 'Burn calories and improve conditioning',
            selected: widget.user.goal == 'Lose Weight',
            onTap: () => setState(() => widget.user.goal = 'Lose Weight'),
          ),
          SelectCard(
            icon: Icons.favorite_border_rounded,
            title: 'Stay Fit',
            subtitle: 'Improve overall health and stamina',
            selected: widget.user.goal == 'Stay Fit',
            onTap: () => setState(() => widget.user.goal = 'Stay Fit'),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LevelStepScreen(user: widget.user),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 4. PROFILE SETUP (2/3): FITNESS LEVEL
class LevelStepScreen extends StatefulWidget {
  final UserProfile user;
  const LevelStepScreen({super.key, required this.user});

  @override
  State<LevelStepScreen> createState() => _LevelStepScreenState();
}

class _LevelStepScreenState extends State<LevelStepScreen> {
  @override
  Widget build(BuildContext context) {
    return FlowShell(
      setupStep: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock(
            "What's Your",
            'Fitness Level?',
            'This helps us calibrate training volume and intensity.',
          ),
          const SizedBox(height: 22),
          SelectCard(
            icon: Icons.flag_outlined,
            title: 'Beginner',
            subtitle: 'New to working out (0–3 months)',
            selected: widget.user.level == 'Beginner',
            onTap: () => setState(() => widget.user.level = 'Beginner'),
          ),
          SelectCard(
            icon: Icons.trending_up_rounded,
            title: 'Intermediate',
            subtitle: '3–12 months of consistent training',
            selected: widget.user.level == 'Intermediate',
            onTap: () => setState(() => widget.user.level = 'Intermediate'),
          ),
          SelectCard(
            icon: Icons.bolt_rounded,
            title: 'Advanced',
            subtitle: 'More than a year of experience',
            selected: widget.user.level == 'Advanced',
            onTap: () => setState(() => widget.user.level = 'Advanced'),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RoutineStepScreen(user: widget.user),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 5. PROFILE SETUP (3/3): WORKOUT ROUTINE
class RoutineStepScreen extends StatefulWidget {
  final UserProfile user;
  const RoutineStepScreen({super.key, required this.user});

  @override
  State<RoutineStepScreen> createState() => _RoutineStepScreenState();
}

class _RoutineStepScreenState extends State<RoutineStepScreen> {
  final _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  bool _generating = false;

  Future<void> _startJourney() async {
    setState(() => _generating = true);
    widget.user.workouts = await GeminiBackend.generateWorkouts(widget.user);
    if (!mounted) return;
    setState(() => _generating = false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainNavigationHub(user: widget.user)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowShell(
      setupStep: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock(
            'Set Your',
            'Workout Routine',
            'Choose the days and preferred time to train.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Days',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: _allDays.map((d) {
              final active = widget.user.days.contains(d);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    active
                        ? widget.user.days.remove(d)
                        : widget.user.days.add(d);
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(right: 5),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: active ? lime : panel,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: active ? lime : line),
                    ),
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: active ? bg : muted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Choose Time',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 10),
          SelectCard(
            icon: Icons.wb_sunny_outlined,
            title: 'Morning',
            subtitle: '06:00 – 09:00',
            selected: widget.user.time == 'Morning',
            onTap: () => setState(() => widget.user.time = 'Morning'),
          ),
          SelectCard(
            icon: Icons.nightlight_round_outlined,
            title: 'Evening',
            subtitle: '18:00 – 21:00',
            selected: widget.user.time == 'Evening',
            onTap: () => setState(() => widget.user.time = 'Evening'),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _generating ? null : _startJourney,
            child: _generating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: bg),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start My Journey',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// MAIN HUB (Connects Home, Workouts, Nutrition, Settings + Sub-screens)
class MainNavigationHub extends StatefulWidget {
  final UserProfile user;
  const MainNavigationHub({super.key, required this.user});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeDashboardScreen(
        user: widget.user,
        onSwitchTab: (i) => setState(() => _tab = i),
      ),
      WorkoutsListScreen(user: widget.user),
      NutritionPlanScreen(user: widget.user),
      SettingsScreen(user: widget.user, onRefresh: () => setState(() {})),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: line)),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF101317),
          selectedItemColor: lime,
          unselectedItemColor: muted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded),
              label: 'Workouts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded),
              label: 'Nutrition',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// 6. HOME DASHBOARD (Connected to Active Session, Progress Details, AI Coach, and Workouts)
class HomeDashboardScreen extends StatelessWidget {
  final UserProfile user;
  final ValueChanged<int> onSwitchTab;
  const HomeDashboardScreen({
    super.key,
    required this.user,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    final todayWorkout = user.workouts.first;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ready to train,',
              style: TextStyle(color: muted, fontSize: 12.5),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AICoachScreen(user: user)),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: lime),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: lime, size: 13),
                    SizedBox(width: 5),
                    Text(
                      'AI Coach',
                      style: TextStyle(
                        color: lime,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Text(
              'Hey, ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: lime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: lime,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TODAY'S WORKOUT",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                todayWorkout.title,
                style: const TextStyle(
                  color: bg,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${todayWorkout.duration}  ·  ${todayWorkout.count}  ·  ${todayWorkout.calories}',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bg,
                  foregroundColor: lime,
                  minimumSize: const Size(155, 42),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActiveWorkoutScreen(workout: todayWorkout),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text(
                  'Start Workout',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProgressDetailScreen(user: user),
                ),
              ),
              child: const Text(
                'See Details',
                style: TextStyle(
                  color: lime,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statCard(
              Icons.check_circle_outline_rounded,
              '3/${user.days.length}',
              'Workouts',
            ),
            const SizedBox(width: 8),
            _statCard(Icons.access_time_rounded, '2.5 hrs', 'Active Time'),
            const SizedBox(width: 8),
            _statCard(
              Icons.local_fire_department_outlined,
              '1,250',
              'Calories',
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Routine',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => onSwitchTab(1),
              child: const Text(
                'See All',
                style: TextStyle(
                  color: lime,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...user.workouts.map((w) => _workoutTile(context, w)),
      ],
    );
  }

  Widget _statCard(IconData icon, String val, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: lime, size: 17),
          const SizedBox(height: 6),
          Text(
            val,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: muted, fontSize: 10.5)),
        ],
      ),
    ),
  );

  Widget _workoutTile(BuildContext context, WorkoutModel w) => GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(workout: w)),
    ),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: panel2,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: lime,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${w.duration} · ${w.count}',
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: lime),
        ],
      ),
    ),
  );
}

// 7. CONNECTED: WORKOUTS & GEMINI REGENERATION
class WorkoutsListScreen extends StatefulWidget {
  final UserProfile user;
  const WorkoutsListScreen({super.key, required this.user});

  @override
  State<WorkoutsListScreen> createState() => _WorkoutsListScreenState();
}

class _WorkoutsListScreenState extends State<WorkoutsListScreen> {
  bool _loading = false;

  Future<void> _regenerate() async {
    setState(() => _loading = true);
    widget.user.workouts = await GeminiBackend.generateWorkouts(widget.user);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        titleBlock(
          'Personal',
          'Workouts',
          'Generated by Gemini AI for ${widget.user.goal}.',
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: lime,
            side: const BorderSide(color: lime),
            minimumSize: const Size.fromHeight(46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          onPressed: _loading ? null : _regenerate,
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: Text(
            _loading ? 'Generating Plan...' : 'Regenerate Plan with Gemini AI',
          ),
        ),
        const SizedBox(height: 16),
        ...widget.user.workouts.map(
          (w) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      w.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      w.duration,
                      style: const TextStyle(
                        color: lime,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...w.exercises.map(
                  (ex) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: lime),
                        const SizedBox(width: 8),
                        Text(
                          ex,
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActiveWorkoutScreen(workout: w),
                    ),
                  ),
                  child: const Text(
                    'Start Session',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// 8. CONNECTED: ACTIVE WORKOUT SESSION
class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutModel workout;
  const ActiveWorkoutScreen({super.key, required this.workout});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final Set<int> _done = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          widget.workout.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_done.length} of ${widget.workout.exercises.length} exercises completed',
              style: const TextStyle(
                color: lime,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.workout.exercises.length,
                itemBuilder: (_, i) {
                  final checked = _done.contains(i);
                  return GestureDetector(
                    onTap: () => setState(
                      () => checked ? _done.remove(i) : _done.add(i),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: panel,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: checked ? lime : line),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            checked
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: checked ? lime : muted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.workout.exercises[i],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                                color: checked ? muted : Colors.white,
                                decoration: checked
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Complete Workout',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 9. CONNECTED: WEEKLY PROGRESS DETAILS
class ProgressDetailScreen extends StatelessWidget {
  final UserProfile user;
  const ProgressDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text('Progress', style: TextStyle(fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          titleBlock(
            'Weekly',
            'Analytics',
            'Tracking consistency for ${user.name}.',
          ),
          const SizedBox(height: 20),
          _metricTile(
            Icons.local_fire_department_rounded,
            'Active Streak',
            '12 consecutive days',
          ),
          _metricTile(
            Icons.fitness_center_rounded,
            'Total Volume Lifted',
            '8,450 kg this week',
          ),
          _metricTile(
            Icons.check_circle_outline_rounded,
            'Plan Adherence',
            '92% completion rate',
          ),
        ],
      ),
    );
  }

  Widget _metricTile(IconData icon, String title, String sub) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: line),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: panel2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: lime, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(color: muted, fontSize: 11.5)),
          ],
        ),
      ],
    ),
  );
}

// 10. CONNECTED: GEMINI AI COACH SCREEN
class AICoachScreen extends StatefulWidget {
  final UserProfile user;
  const AICoachScreen({super.key, required this.user});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final _ctrl = TextEditingController();
  String _reply =
      'Ask anything about form, recovery, or adjusting your workouts.';
  bool _busy = false;

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty) return;
    final q = _ctrl.text.trim();
    _ctrl.clear();
    setState(() => _busy = true);
    final res = await GeminiBackend.askCoach(widget.user, q);
    if (mounted) {
      setState(() {
        _reply = res;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text('Gemini AI Coach', style: TextStyle(fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: lime),
              ),
              child: Text(
                _busy ? 'Thinking...' : _reply,
                style: const TextStyle(fontSize: 13.5, height: 1.5),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: 'Ask your AI coach...',
                      hintStyle: const TextStyle(color: muted),
                      filled: true,
                      fillColor: panel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: lime,
                    foregroundColor: bg,
                    padding: const EdgeInsets.all(14),
                  ),
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 11. CONNECTED: NUTRITION SCREEN
class NutritionPlanScreen extends StatelessWidget {
  final UserProfile user;
  const NutritionPlanScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        titleBlock(
          'Daily',
          'Nutrition',
          'Macro targets synced to ${user.goal}.',
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _macro('2,650', 'Calories'),
            const SizedBox(width: 8),
            _macro('170g', 'Protein'),
            const SizedBox(width: 8),
            _macro('310g', 'Carbs'),
          ],
        ),
        const SizedBox(height: 18),
        _meal(
          Icons.wb_sunny_outlined,
          'Breakfast · 620 kcal',
          'Oats, 3 eggs & whey · 45g protein',
        ),
        _meal(
          Icons.restaurant_rounded,
          'Lunch · 810 kcal',
          'Grilled chicken, rice & greens · 62g protein',
        ),
        _meal(
          Icons.nightlight_round_outlined,
          'Dinner · 720 kcal',
          'Lean beef, potatoes & vegetables · 54g protein',
        ),
      ],
    );
  }

  Widget _macro(String v, String l) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            v,
            style: const TextStyle(
              color: lime,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 3),
          Text(l, style: const TextStyle(color: muted, fontSize: 11)),
        ],
      ),
    ),
  );

  Widget _meal(IconData icon, String title, String sub) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: line),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: panel2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: lime, size: 19),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(color: muted, fontSize: 11)),
          ],
        ),
      ],
    ),
  );
}

// 12. SETTINGS SCREEN
class SettingsScreen extends StatefulWidget {
  final UserProfile user;
  final VoidCallback onRefresh;
  const SettingsScreen({
    super.key,
    required this.user,
    required this.onRefresh,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        titleBlock(
          'App',
          'Settings',
          'Manage profile, Gemini AI backend, and preferences.',
        ),
        const SizedBox(height: 18),
        _tile(
          icon: Icons.person_outline_rounded,
          title: widget.user.name,
          subtitle: '${widget.user.goal} · ${widget.user.level}',
          trailing: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GoalStepScreen(user: widget.user),
              ),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(color: lime, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        _tile(
          icon: Icons.auto_awesome_outlined,
          title: 'Gemini AI Backend',
          subtitle: 'Connected · Dynamic workout generation',
          trailing: const Icon(
            Icons.check_circle_rounded,
            color: lime,
            size: 19,
          ),
        ),
        _tile(
          icon: Icons.notifications_none_rounded,
          title: 'Workout Reminders',
          subtitle: '${widget.user.days.join(', ')} (${widget.user.time})',
          trailing: Switch(
            value: widget.user.reminders,
            activeTrackColor: lime,
            activeThumbColor: bg,
            onChanged: (v) {
              setState(() => widget.user.reminders = v);
              widget.onRefresh();
            },
          ),
        ),
        _tile(
          icon: Icons.straighten_rounded,
          title: 'Units',
          subtitle: widget.user.metric
              ? 'Metric (kg / km)'
              : 'Imperial (lbs / mi)',
          trailing: Switch(
            value: widget.user.metric,
            activeTrackColor: lime,
            activeThumbColor: bg,
            onChanged: (v) {
              setState(() => widget.user.metric = v);
              widget.onRefresh();
            },
          ),
        ),
      ],
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: line),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: panel2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: lime, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ),
        ),
        trailing,
      ],
    ),
  );
}
