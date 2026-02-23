enum ReminderType {
  threeDaysBefore,
  oneDayBefore,
  onExpiryDate;

  int get daysBeforeExpiry => switch (this) {
        threeDaysBefore => 3,
        oneDayBefore => 1,
        onExpiryDate => 0,
      };

  String get displayName => switch (this) {
        threeDaysBefore => '3 Days Before',
        oneDayBefore => '1 Day Before',
        onExpiryDate => 'On Expiry',
      };

  // Notification ID offset to ensure unique IDs
  int get idOffset => switch (this) {
        threeDaysBefore => 0,
        oneDayBefore => 1,
        onExpiryDate => 2,
      };
}
