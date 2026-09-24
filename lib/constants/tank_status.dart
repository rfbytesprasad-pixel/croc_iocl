// lib/constants/tank_status.dart
//
// Tank `status` values from the tankstatus packet.
//
// Confirmed with <senior name> on <date>:
//   1 = Offline
//   2 = Online
//
// The device spec doc only defines status=0 as a placeholder sample.
// If the device team changes these meanings, update ONLY this file.

const int kTankStatusOffline = 1;
const int kTankStatusOnline = 2;

/// True if the tank status means the tank is online/normal.
bool isTankOnline(int status) => status == kTankStatusOnline;

/// True if the tank status explicitly means offline.
bool isTankOffline(int status) => status == kTankStatusOffline;

/// True if we don't recognize this status value.
/// Use this to show a neutral/grey "Unknown" state instead of guessing.
bool isTankStatusUnknown(int status) =>
    status != kTankStatusOnline && status != kTankStatusOffline;