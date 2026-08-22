import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/utils/match_datetime_formatter.dart';
import '../../../data/local/database.dart';
import '../../common/widgets/draft_delete_dialog.dart';

class DraftMatchCard extends StatelessWidget {
  final MatchesTableData match;
  final VoidCallback onResume;
  final Future<void> Function() onDelete;

  const DraftMatchCard({
    super.key,
    required this.match,
    required this.onResume,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final lastUpdated = match.updatedAt != null
        ? DateTime.fromMillisecondsSinceEpoch(match.updatedAt!)
        : DateTime.fromMillisecondsSinceEpoch(match.createdAt);
    final updatedText = MatchDateTimeFormatter.smartUpdatedTime(lastUpdated);

    final oversText = match.totalOvers != null ? '${match.totalOvers} Overs' : '20 Overs';
    final formatText = match.format.toUpperCase() == 'T20' ? 'T20' : 'Custom';
    final venueText = (match.venueName != null && match.venueName!.trim().isNotEmpty)
        ? match.venueName!.trim()
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onResume,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Compact DRAFT pill & Overflow menu button
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7), // Light warm amber tint
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 13,
                            color: Color(0xFFB45309),
                          ),
                          SizedBox(width: 3),
                          Text(
                            'DRAFT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (action) async {
                        if (action == 'resume' || action == 'edit') {
                          onResume();
                        } else if (action == 'delete') {
                          final name = match.matchName ?? 'Draft Match';
                          final confirm = await showDeleteDraftConfirmationSheet(
                            context,
                            matchName: name,
                          );
                          if (confirm) {
                            await onDelete();
                          }
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'resume',
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow_rounded,
                                  color: AppColors.primary, size: 18),
                              SizedBox(width: 8),
                              Text('Resume',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined,
                                  color: Color(0xFF4B5563), size: 18),
                              SizedBox(width: 8),
                              Text('Edit',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  color: Color(0xFFDC2626), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Delete draft',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Match Title: Shield11 vs Vengai Kings
                Text(
                  match.matchName ?? 'Match Setup',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Match Metadata: 2 Overs • Custom • Venue
                Text(
                  '$oversText  •  $formatText${venueText != null ? "  •  $venueText" : ""}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),

                // Last Updated Metadata: Updated Today, 11:57 AM
                Text(
                  'Updated $updatedText',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 10),

                // Resume Action Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4), // Soft TurfScore green tint
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDCFCE7)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Resume Draft',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
