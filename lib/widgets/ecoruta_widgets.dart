import 'package:flutter/material.dart';

import '../models/destination.dart';

IconData iconForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'playa':
      return Icons.beach_access;
    case 'cultura':
      return Icons.account_balance;
    case 'aventura':
      return Icons.hiking;
    case 'historia':
      return Icons.history_edu;
    default:
      return Icons.park;
  }
}

class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF66A34A)],
          ),
          borderRadius: BorderRadius.circular(size * .28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(Icons.eco, color: Colors.white, size: size * .55),
      ),
    );
  }
}

class BackendBadge extends StatelessWidget {
  final bool remote;
  final String label;

  const BackendBadge({
    super.key,
    required this.remote,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        remote ? Icons.cloud_done_outlined : Icons.phone_android_outlined,
        size: 18,
      ),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.favorite,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  iconForCategory(destination.category),
                  color: colors.onPrimaryContainer,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${destination.department} · ${destination.category}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: favorite ? 'Quitar favorito' : 'Guardar favorito',
                onPressed: onFavorite,
                icon: Icon(
                  favorite ? Icons.favorite : Icons.favorite_border,
                  color: favorite ? colors.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.black38),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            if (action != null) ...[
              const SizedBox(height: 18),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
