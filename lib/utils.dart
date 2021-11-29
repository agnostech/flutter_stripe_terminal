enum ReaderConnectionStatus {
  CONNECTED,
  CONNECTING,
  NOT_CONNECTED,
  DISCONNECTED
}

enum ReaderPaymentStatus { NOT_READY, READY, WAITING_FOR_INPUT, PROCESSING }

enum ReaderUpdateStatus {
  UPDATE_AVAILABLE,
  STARTING_UPDATE_INSTALLATION,
  SOFTWARE_UPDATE_IN_PROGRESS,
  FINISHED_UPDATE_INSTALLATION
}

enum ReaderEvent {
  LOW_BATTERY,
  CHECK_MOBILE_DEVICE,
  RETRY_CARD,
  INSERT_CARD,
  INSERT_OR_SWIPE_CARD,
  SWIPE_CARD,
  REMOVE_CARD,
  MULTIPLE_CONTACTLESS_CARDS_DETECTED,
  TRY_ANOTHER_READ_METHOD,
  TRY_ANOTHER_CARD,
  CARD_REMOVED,
  CARD_INSERTED,
}