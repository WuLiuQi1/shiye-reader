import 'package:flutter/material.dart';
import 'package:xxread/models/book.dart';

class LibraryGridBookDetails extends StatelessWidget {
  const LibraryGridBookDetails({super.key, required this.book});

  // Keep room for a two-line title and a quiet reading-progress line.  The
  // library should read as a shelf of books first, rather than a dense data
  // grid.
  static const double height = 54;

  final Book book;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = book.totalPages > 0
        ? (book.currentPage / book.totalPages).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progress * 100).round();

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 9, 2, 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              key: const ValueKey('library-grid-title'),
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13,
                height: 1.18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      key: const ValueKey('library-grid-progress'),
                      value: progress,
                    minHeight: 2.5,
                    backgroundColor: scheme.onSurface.withValues(alpha: 0.10),
                      valueColor: AlwaysStoppedAnimation(scheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.72),
                    fontSize: 10.5,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
