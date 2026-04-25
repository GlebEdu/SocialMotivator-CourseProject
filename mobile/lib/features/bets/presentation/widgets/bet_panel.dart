import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
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
  bool _hasPendingBetSubmission = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(placeBetControllerProvider, (previous, next) {
      final shouldHandleSubmissionResult =
          _hasPendingBetSubmission && previous?.isLoading == true;
      if (!shouldHandleSubmissionResult) {
        return;
      }

      next.whenOrNull(
        data: (_) {
          _hasPendingBetSubmission = false;
          final messenger = ScaffoldMessenger.of(context);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Ставка успешно размещена.')),
            );
          _amountController.clear();
        },
        error: (error, _) {
          _hasPendingBetSubmission = false;
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
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Сделать ставку',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Выберите сторону и сумму, чтобы зафиксировать свою позицию по этой цели.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: HabitBetTheme.inkSoft),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Сумма ставки',
                prefixText: 'Монеты  ',
              ),
            ),
            const SizedBox(height: 16),
            if (!isBettingOpen)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: HabitBetTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Ставки доступны только для активных целей.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HabitBetTheme.inkSoft,
                  ),
                ),
              )
            else
              Row(
                children: <Widget>[
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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.trending_up_rounded),
                                SizedBox(width: 8),
                                Text('За'),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: HabitBetTheme.danger,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: HabitBetTheme.danger
                            .withValues(alpha: 0.4),
                        disabledForegroundColor: Colors.white70,
                      ),
                      onPressed: betState.isLoading
                          ? null
                          : () => _submitBet(BetSide.againstGoal),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.trending_down_rounded),
                          SizedBox(width: 8),
                          Text('Против'),
                        ],
                      ),
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
          const SnackBar(content: Text('Введите корректную сумму ставки.')),
        );
      return;
    }

    _hasPendingBetSubmission = true;
    await ref
        .read(placeBetControllerProvider.notifier)
        .placeBet(
          PlaceBetInput(goalId: widget.goal.id, side: side, amount: amount),
        );
  }
}
