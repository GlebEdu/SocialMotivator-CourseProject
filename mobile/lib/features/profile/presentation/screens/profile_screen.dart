import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUser = ref.watch(currentAuthenticatedUserProvider);

    if (authState.isLoading && currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentUser == null) {
      return const _ProfileMessage(
        icon: Icons.person_off_outlined,
        title: 'No user signed in',
        description: 'Sign in to see your profile information.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 28,
                  child: Text(
                    currentUser.displayName.isEmpty
                        ? '?'
                        : currentUser.displayName[0].toUpperCase(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentUser.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.monetization_on_outlined),
                title: const Text('Balance'),
                subtitle: Text(
                  '${currentUser.balance.toStringAsFixed(0)} Coins',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.star_border_outlined),
                title: const Text('Rating'),
                subtitle: Text(currentUser.rating.toString()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileMessage extends StatelessWidget {
  const _ProfileMessage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
