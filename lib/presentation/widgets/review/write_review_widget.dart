import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/review/review_provider.dart';

class WriteReviewWidget extends ConsumerStatefulWidget {
  const WriteReviewWidget({
    super.key,
    required this.productId,
    required this.productName,
  });

  final String productId;
  final String productName;

  @override
  ConsumerState<WriteReviewWidget> createState() => _WriteReviewWidgetState();
}

class _WriteReviewWidgetState extends ConsumerState<WriteReviewWidget> {
  double _rating = 5;
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(writeReviewControllerProvider);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Write a Review',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.productName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 10),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            allowHalfRating: true,
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: AppColors.ratingActive),
            onRatingUpdate: (v) => setState(() => _rating = v),
            itemSize: 26,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Title',
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Review',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      await ref.read(writeReviewControllerProvider.notifier).submit(
                            productId: widget.productId,
                            productName: widget.productName,
                            rating: _rating,
                            title: _title.text,
                            body: _body.text,
                          );

                      final st = ref.read(writeReviewControllerProvider);
                      st.whenOrNull(
                        data: (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Review submitted for approval.')),
                          );
                          _title.clear();
                          _body.clear();
                          setState(() => _rating = 5);
                        },
                        error: (e, _) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        },
                      );
                    },
              child: state.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Review'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reviews are published after admin approval.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
