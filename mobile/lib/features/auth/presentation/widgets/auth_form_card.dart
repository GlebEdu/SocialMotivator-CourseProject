import 'package:flutter/material.dart';

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(title, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 24),
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
            ),
          ),
        ),
      ),
    );
  }
}
