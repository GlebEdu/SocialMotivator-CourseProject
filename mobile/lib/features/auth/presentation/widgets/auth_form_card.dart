import 'package:flutter/material.dart';

import '../../../../app/widgets/brand_backdrop.dart';
import '../../../../app/widgets/glowing_gradient_panel.dart';

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    required this.children,
    required this.footer,
    this.isSubmitting = false,
    super.key,
  });

  final String title;
  final String submitLabel;
  final VoidCallback? onSubmit;
  final List<Widget> children;
  final Widget footer;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BrandBackdrop(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  GlowingGradientPanel(
                    padding: const EdgeInsets.all(24),
                    radius: 32,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'HabitBet - сообщество для улучшения жизни',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ...children,
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: isSubmitting ? null : onSubmit,
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(submitLabel),
                          ),
                          const SizedBox(height: 16),
                          footer,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
