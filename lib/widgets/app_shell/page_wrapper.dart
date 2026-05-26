import 'package:flutter/material.dart';

class PageWrapper extends StatelessWidget {
  final Widget child;
  final String? subtitle;
  final bool centerEmpty;

  const PageWrapper({
    super.key,
    required this.child,
    this.subtitle,
    this.centerEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (subtitle != null) ...[
            Text(subtitle!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}
