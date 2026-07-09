// Turns a DateTime into a short, friendly relative-time string like
// "2d ago", "5h ago", or "just now" - shown under each opportunity card
// instead of a full date/time stamp, matching the sample UI design.
String timeAgo(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);

  if (difference.inMinutes < 1) return 'just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  if (difference.inDays < 7) return '${difference.inDays}d ago';

  final weeks = (difference.inDays / 7).floor();
  return '${weeks}w ago';
}
