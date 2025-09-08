

class UIHelper {
  static String formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if message is from today
    if (messageDate == today) {
      // Show time in 12-hour format
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

      return '${displayHour}:${minute} $period';
    }
    // Check if message is from yesterday
    else if (messageDate == yesterday) {
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

      return 'Yesterday ${displayHour}:${minute} $period';
    }
    // Check if message is older than yesterday
    else {
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

      // Format date as "MMM dd" (e.g., "Jan 15")
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final month = monthNames[timestamp.month - 1];
      final day = timestamp.day.toString().padLeft(2, '0');

      return '$month $day ${displayHour}:${minute} $period';
    }
  }
}
