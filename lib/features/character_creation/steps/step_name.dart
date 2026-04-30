import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../character_draft_provider.dart';

class StepName extends ConsumerStatefulWidget {
  const StepName({super.key});

  @override
  ConsumerState<StepName> createState() => _StepNameState();
}

class _StepNameState extends ConsumerState<StepName> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _playerCtrl;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(characterDraftProvider);
    _nameCtrl = TextEditingController(text: draft.name);
    _playerCtrl = TextEditingController(text: draft.playerName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _playerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Give your character a name.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'You can always change this later.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Character name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (v) =>
                ref.read(characterDraftProvider.notifier).setName(v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _playerCtrl,
            decoration: const InputDecoration(
              labelText: 'Player name (optional)',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (v) =>
                ref.read(characterDraftProvider.notifier).setPlayerName(v),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              _nameCtrl.clear();
              ref
                  .read(characterDraftProvider.notifier)
                  .setName('');
            },
            icon: const Icon(Icons.skip_next),
            label: const Text('Decide later'),
          ),
        ],
      ),
    );
  }
}
