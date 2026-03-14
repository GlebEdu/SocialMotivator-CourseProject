import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../bets/domain/entities/bet_side.dart';
import '../../../bets/domain/entities/place_bet_input.dart';
import '../../../goals/domain/entities/goal.dart';
import '../providers/bets_provider.dart';

class BetPanel extends ConsumerStatefulWidget {
  const BetPanel({required this.goal, super.key});

  final Goal goal;

  @override
  ConsumerState<BetPanel> createState() => _BetPanelState();
}

class _BetPanelState extends ConsumerState<BetPanel> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(placeBetControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          final messenger = ScaffoldMessenger.of(context);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Bet placed successfully.')),
            );
          _amountController.clear();
        },
        error: (error, _) {
          final messenger = ScaffoldMessenger.of(context);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });

    final betState = ref.watch(placeBetControllerProvider);
    final isBettingOpen = widget.goal.status.name == 'active';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Place a Bet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Bet amount',
                prefixText: 'Coins ',
              ),
            ),
            const SizedBox(height: 16),
            if (!isBettingOpen)
              Text(
                'Betting is only available for active goals.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: betState.isLoading
                          ? null
                          : () => _submitBet(BetSide.againstGoal),
                      child: const Text('Bet Against'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: betState.isLoading
                          ? null
                          : () => _submitBet(BetSide.forGoal),
                      child: betState.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Bet For'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitBet(BetSide side) async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Enter a valid bet amount.')),
        );
      return;
    }

    await ref
        .read(placeBetControllerProvider.notifier)
        .placeBet(
          PlaceBetInput(goalId: widget.goal.id, side: side, amount: amount),
        );
  }
}
