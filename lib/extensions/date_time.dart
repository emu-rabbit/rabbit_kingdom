extension RelativeTime on DateTime {
  String toRelativeTimeString() {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 5) return '剛剛';
    if (diff.inSeconds < 60) return '${diff.inSeconds}秒前';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分鐘前';
    if (diff.inHours < 24) return '${diff.inHours}小時前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}週前';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}個月前';
    return '${(diff.inDays / 365).floor()}年前';
  }
}
