import 'package:flutter/material.dart';
import '../../core/logic/app_state.dart';

class WeeklySettlementDialog extends StatefulWidget {
  final SettlementReport report;

  const WeeklySettlementDialog({super.key, required this.report});

  @override
  State<WeeklySettlementDialog> createState() => _WeeklySettlementDialogState();
}

class _WeeklySettlementDialogState extends State<WeeklySettlementDialog>
    with SingleTickerProviderStateMixin {
  bool _showOutcome = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Simulate "Tally Drop" animation delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showOutcome = true;
        });
        _pulseController.stop();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final color = report.newTier.color;

    return AlertDialog(
      title: const Center(child: Text('WEEKLY SETTLEMENT')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${report.weeklyNet > 0 ? '+' : ''}${report.weeklyNet.toStringAsFixed(1)} pts',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: report.weeklyNet >= 0 ? Colors.green : Colors.red,
            ),
          ),
          const Text('Net effort from last week'),
          const SizedBox(height: 24),

          // Tally Bar Animation Simulation
          SizedBox(
            height: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _showOutcome
                    ? ((report.newTally + 25) / 50).clamp(0.0, 1.0)
                    : ((report.previousTally + 25) / 50).clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'League Tally: ${report.newTally.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          if (_showOutcome) ...[
            AnimatedScale(
              scale: _showOutcome ? 1.0 : 0.8,
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              child: AnimatedOpacity(
                opacity: _showOutcome ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    if (report.levelChange > 0) ...[
                      const Icon(Icons.upgrade, size: 64, color: Colors.orange),
                      const SizedBox(height: 8),
                      Text(
                        report.levelChange == 2
                            ? 'DOUBLE PROMOTION!'
                            : 'PROMOTED!',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'New Rank: ${report.newTier.name}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else if (report.levelChange < 0) ...[
                      const Icon(Icons.warning, size: 64, color: Colors.red),
                      const SizedBox(height: 8),
                      const Text(
                        'DEMOTED',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Back to: ${report.newTier.name}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.check_circle,
                        size: 64,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'POSITION SECURED',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Still ${report.newTier.name}',
                        style: TextStyle(color: color),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 100), // Height of outcome section
            _SettlementScanner(controller: _pulseController),
          ],
        ],
      ),
      actions: [
        if (_showOutcome)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Center(child: Text('START NEW WEEK')),
          ),
      ],
    );
  }
}

class _SettlementScanner extends StatelessWidget {
  final AnimationController controller;

  const _SettlementScanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final progress = (controller.value + (index / 3)) % 1.0;
                return Container(
                  width: 60 * progress,
                  height: 60 * progress,
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
        const SizedBox(height: 24),
        Text(
          'ANALYZING PERFORMANCE...',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
