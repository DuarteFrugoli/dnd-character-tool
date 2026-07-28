part of '../../character_detail_screen.dart';

class _FeatureDetailSheet extends StatelessWidget {
  const _FeatureDetailSheet({
    required this.name,
    required this.description,
    required this.subtitle,
  });

  final String name;
  final String description;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 1.0,
      builder: (_, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          // Drag handle
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Name
          Text(name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),

          // Subtitle (level · type)
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Description
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
