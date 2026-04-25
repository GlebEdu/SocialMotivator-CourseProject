import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/register_input.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_card.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<dynamic>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (ref.read(currentAuthenticatedUserProvider) != null) {
            context.go('/my-goals');
          }
        },
        error: (error, _) {
          final messenger = ScaffoldMessenger.of(context);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });

    final authState = ref.watch(authControllerProvider);

    return AuthFormCard(
      title: 'Регистрация',
      submitLabel: 'Регистрация',
      isSubmitting: authState.isLoading,
      onSubmit: _submit,
      footer: TextButton(
        onPressed: authState.isLoading ? null : () => context.go('/login'),
        child: const Text('Уже есть аккаунт? Войти'),
      ),
      children: <Widget>[
        TextField(
          controller: _displayNameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Отображаемое имя'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const <String>[AutofillHints.email],
          decoration: const InputDecoration(labelText: 'Почта'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          autofillHints: const <String>[AutofillHints.newPassword],
          decoration: const InputDecoration(labelText: 'Пароль'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final displayName = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    const minPasswordLength = 8;

    if (displayName.isEmpty ||
        email.isEmpty ||
        !email.contains('@') ||
        password.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Введите имя, корректную почту и пароль.'),
          ),
        );
      return;
    }

    if (password.length < minPasswordLength) {
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Пароль должен быть не короче 8 символов.'),
          ),
        );
      return;
    }

    await ref.read(registerActionProvider)(
      RegisterInput(displayName: displayName, email: email, password: password),
    );
  }
}
