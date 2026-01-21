import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../core/logic/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Selections
  String _selectedSport = 'Run';
  double _weeklyVolume = 0.0;
  double _weeklyViceCount = 0.0;
  String _selectedVice = '🍕';
  bool _isEditingVice = false;
  String _startingVice = '🍕';
  final TextEditingController _viceController = TextEditingController(
    text: '🍕',
  );

  // Animation for scanner reveal
  late AnimationController _revealController;
  bool _isRevealing = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _startReveal();
    }
  }

  void _startReveal() {
    setState(() => _isRevealing = true);
    _revealController.forward().then((_) {
      setState(() {
        _isRevealing = false;
        _isComplete = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) {
      return _buildFinalRankReveal();
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildIntroPage(),
                  _buildDisciplinePage(),
                  _buildVolumePage(),
                  _buildVicePage(),
                  _buildAuditPage(),
                ],
              ),
            ),
            if (!_isRevealing)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: () {
                          if (_currentPage == 4 && _isEditingVice) {
                            setState(() {
                              _isEditingVice = false;
                              _selectedVice = _startingVice;
                              _viceController.text = _startingVice;
                            });
                          } else {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          (_currentPage == 4 && _isEditingVice)
                              ? 'DISCARD'
                              : 'Back',
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (!_isEditingVice)
                      FilledButton.icon(
                        onPressed: _nextPage,
                        label: Text(
                          _currentPage == 4 ? 'CALCULATE RANK' : 'NEXT',
                        ),
                        icon: const Icon(Icons.arrow_forward),
                      ),
                  ],
                ),
              ),
            if (_isRevealing)
              const Padding(
                padding: EdgeInsets.only(bottom: 100),
                child: Center(child: AnalyzingPerformanceAnimation()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPage() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏃', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          Text(
            'EARN YOUR VICES',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'The fitness community for the rest of us. We track the work so you can enjoy the reward.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDisciplinePage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '1. PRIMARY ENGINE',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _disciplineButton('Run', '🏃'),
              _disciplineButton('Cycle', '🚴'),
              _disciplineButton('Swim', '🏊'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _disciplineButton(String label, String emoji) {
    bool isSelected = _selectedSport == label;
    return InkWell(
      onTap: () => setState(() => _selectedSport = label),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumePage() {
    String unit = 'KM';
    double maxVol = 100.0;
    if (_selectedSport == 'Cycle') {
      unit = 'KM';
      maxVol = 300.0;
    } else if (_selectedSport == 'Swim') {
      unit = 'LENGTHS';
      maxVol = 3000.0;
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '2. ${_selectedSport.toUpperCase()} VOLUME',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            '${_weeklyVolume.toInt()} $unit',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
          ),
          const Text('average weekly output'),
          Slider(
            value: _weeklyVolume.clamp(0.0, maxVol),
            min: 0,
            max: maxVol,
            divisions: 20,
            label: '${_weeklyVolume.toInt()} $unit',
            onChanged: (val) => setState(() => _weeklyVolume = val),
          ),
          const SizedBox(height: 24),
          _buildVolumeBadge(),
        ],
      ),
    );
  }

  Widget _buildVolumeBadge() {
    String label = 'BEGINNER';
    Color color = Colors.grey;

    // Normalize to Running KM for badge logic
    double normKm = _weeklyVolume;
    if (_selectedSport == 'Cycle') normKm = _weeklyVolume / 3.0;
    if (_selectedSport == 'Swim') normKm = _weeklyVolume / 30.0;

    if (normKm >= 80) {
      label = 'LEGENDARY';
      color = Colors.black;
    } else if (normKm >= 50) {
      label = 'ELITE';
      color = Colors.purple;
    } else if (normKm >= 30) {
      label = 'ATHLETE';
      color = Colors.blue;
    } else if (normKm >= 10) {
      label = 'CONSISTENT';
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAuditPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '4. SUSTAINABILITY AUDIT',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 32),
          Text(
            'Be honest: how many $_selectedVice do you typically have in a week?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 48),
          Text(
            '${_weeklyViceCount.toInt()}',
            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900),
          ),
          const Text('vices per week'),
          Slider(
            value: _weeklyViceCount,
            min: 0,
            max: 40,
            divisions: 20,
            label: '${_weeklyViceCount.toInt()}',
            onChanged: (val) => setState(() => _weeklyViceCount = val),
          ),
          const SizedBox(height: 24),
          if (_weeklyViceCount > 25)
            const Text(
              '⚠️ HIGH VICE LOAD: WE\'LL ADJUST RATIOS FOR SUSTAINABILITY',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildVicePage() {
    final quickPicks = ['🍕', '🎮', '🍩', '🥤', '🍫', '☕', '🍰', '🍟'];
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '3. VICE SETUP',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          const Text(
            'Choose your poison. What are we earning today?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!_isEditingVice)
                  Text(_selectedVice, style: const TextStyle(fontSize: 120))
                else
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _viceController,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 80),
                      decoration: const InputDecoration(hintText: ''),
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          setState(() => _selectedVice = val);
                        }
                      },
                      onSubmitted: (val) {
                        setState(() => _isEditingVice = false);
                      },
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton.filledTonal(
                    onPressed: () {
                      setState(() {
                        if (_isEditingVice) {
                          _isEditingVice = false;
                        } else {
                          _startingVice = _selectedVice;
                          _isEditingVice = true;
                        }
                      });
                    },
                    icon: Icon(_isEditingVice ? Icons.check : Icons.edit),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          if (!_isEditingVice)
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: quickPicks
                  .map(
                    (e) => InkWell(
                      onTap: () {
                        setState(() {
                          _selectedVice = e;
                          _viceController.text = e;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedVice == e
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.2)
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          border: _selectedVice == e
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(e, style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFinalRankReveal() {
    // Calculate Seeded Level
    double basePoints = 0.5; // Run
    if (_selectedSport == 'Cycle') basePoints = 1.0 / 6.0;
    if (_selectedSport == 'Swim') basePoints = 1.0 / 60.0;

    double pointsAtT0 = _weeklyVolume * basePoints * 10.0;
    // log(pts/25) / 0.23025 (which is -log(0.7943))
    int seededLevel = 0;
    if (pointsAtT0 > 0) {
      double calculated = (math.log(pointsAtT0 / 25.0) / 0.23025);
      seededLevel = calculated.round().clamp(0, 20);
    }

    // Sustainability Adjustment: If projected balance is too low, suggest starting lower
    bool needsOffset = (pointsAtT0 - _weeklyViceCount) < -15;
    if (needsOffset) {
      seededLevel = (seededLevel - 5).clamp(0, 20);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ANALYSIS COMPLETE',
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 4,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 40),
              const Icon(Icons.stars, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              const Text(
                'YOUR STARTING RANK:',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'TIER $seededLevel',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              if (needsOffset)
                const Text(
                  'BALANCE TUNED: We adjusted your tier for sustainability based on your vice audit.',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 40),
              const Text(
                'We have skipped the initial grind for you based on your performance history.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 64),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    context.read<AppState>().completeOnboarding(
                      runVolume: _selectedSport == 'Run' ? _weeklyVolume : 0,
                      viceEmoji: _selectedVice,
                    );
                    // Force a level update in AppState for seeding
                    context.read<AppState>().debugSetLevel(seededLevel);
                  },
                  child: const Text('ENTER THE ARENA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sub-widget for scanning animation (reusable from WeeklySettlementDialog concept)
class AnalyzingPerformanceAnimation extends StatefulWidget {
  const AnalyzingPerformanceAnimation({super.key});

  @override
  State<AnalyzingPerformanceAnimation> createState() =>
      _AnalyzingPerformanceAnimationState();
}

class _AnalyzingPerformanceAnimationState
    extends State<AnalyzingPerformanceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final progress = (_controller.value + (index / 3)) % 1.0;
                return Container(
                  width: 100 * progress,
                  height: 100 * progress,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: (1.0 - progress) * 0.5,
                      ),
                      width: 2,
                    ),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 32),
        const Text(
          'ANALYZING LIFESTYLE...',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 4.0,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
