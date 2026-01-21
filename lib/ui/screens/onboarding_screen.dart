import 'package:flutter/material.dart';
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
  double _weeklyRunKm = 0.0;
  String _selectedVice = '🍕';
  bool _isEditingVice = false;
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
    if (_currentPage < 2) {
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
                  _buildVolumePage(),
                  _buildVicePage(),
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
                        onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        ),
                        child: const Text('Back'),
                      )
                    else
                      const SizedBox.shrink(),
                    FilledButton.icon(
                      onPressed: _nextPage,
                      label: Text(
                        _currentPage == 2 ? 'CALCULATE RANK' : 'NEXT',
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

  Widget _buildVolumePage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '1. VOLUME Check',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 48),
          Text(
            '${_weeklyRunKm.toInt()} KM',
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900),
          ),
          const Text('average weekly running distance'),
          Slider(
            value: _weeklyRunKm,
            min: 0,
            max: 100, // We keep it at 100 for onboarding simplicity
            divisions: 20,
            label: '${_weeklyRunKm.toInt()} km',
            onChanged: (val) => setState(() => _weeklyRunKm = val),
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
    if (_weeklyRunKm >= 80) {
      label = 'LEGENDARY';
      color = Colors.black;
    } else if (_weeklyRunKm >= 50) {
      label = 'ELITE';
      color = Colors.purple;
    } else if (_weeklyRunKm >= 30) {
      label = 'ATHLETE';
      color = Colors.blue;
    } else if (_weeklyRunKm >= 10) {
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

  Widget _buildVicePage() {
    final quickPicks = ['🍕', '🎮', '🍩', '🥤', '🍫', '☕', '🍰', '🍟'];
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '2. VICE Setup',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          const Text(
            'Choose your poison. What are we earning today?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 40),
          Stack(
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
                    decoration: const InputDecoration(hintText: 'Emoji...'),
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
                right: -40,
                child: IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      _isEditingVice = !_isEditingVice;
                    });
                  },
                  icon: Icon(_isEditingVice ? Icons.check : Icons.edit),
                ),
              ),
            ],
            clipBehavior: Clip.none,
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
    // Determine level from runVolume
    int seededLevel = 0;
    if (_weeklyRunKm >= 100)
      seededLevel = 20;
    else if (_weeklyRunKm >= 60)
      seededLevel = 15;
    else if (_weeklyRunKm >= 40)
      seededLevel = 10;
    else if (_weeklyRunKm >= 20)
      seededLevel = 5;
    else
      seededLevel = 0;

    // Use dummy display logic since we haven't onboarded yet
    // In a real app we'd fetch this from the LeagueTier list
    return Scaffold(
      backgroundColor: Colors.black, // High contrast reveal
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
                      runVolume: _weeklyRunKm,
                      viceEmoji: _selectedVice,
                    );
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
