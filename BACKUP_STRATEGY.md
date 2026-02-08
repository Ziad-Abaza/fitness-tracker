# Data Backup & Recovery Plan (BACKUP_STRATEGY.md)

This document outlines the architecture and implementation of the backup and recovery system for the Fitness Tracker application.

**STATUS: ✅ FULLY IMPLEMENTED**

---

## 1. Scope of Backup
The backup system consolidates the following data into a single compressed `.bak` archive:
- **SQLite Database**: The main application database (`fitness_tracker.db`) containing user sessions, routines, set logs, and custom exercise data.
- **App Settings**: A JSON export of `SharedPreferences` including language preference (EN/AR), unit systems (KG/LB), and user preferences.
- **Local Media**: All custom images or GIFs uploaded by the user for custom exercises (located in the `user_images/` directory).

---

## 2. Automation & Scheduling ✅
Automated background backup is handled via `workmanager`.
- **Frequency**: A periodic task scheduled every **14 days**.
- **Execution Constraints**: Backups only trigger when:
  - Device is **charging** (`requiresCharging: true`)
  - Battery is **not low** (`requiresBatteryNotLow: true`)
  - Network is **not required** (`NetworkType.notRequired`)

---

## 3. Manual Backup Trigger ✅
Users have full control via the **Settings Screen**.
- **Action**: A "Backup Now" button with real-time progress indicator.
- **Feedback**: LinearProgressIndicator + status text (Creating backup..., Success/Fail).
- **Display**: Shows "Last Backup Date" from SharedPreferences.

---

## 4. Storage Management (Rolling Backup) ✅
The system implements a **Two-File Rolling System**:
- **Naming Convention**: `ft_backup_timestamp.bak`
- **Retention Logic**: Automatically keeps only the **2 most recent** backups, deleting older files.

---

## 5. Smart Recovery Flow ✅
On a fresh installation (detected via `has_launched_before` flag):
- **Discovery**: Auto-scans the backup directory for valid `.bak` files.
- **User Prompt**: Displays a styled dialog: "Backup Found - Restore data or Start fresh?"
- **Options**: [RESTORE NOW] or [START FRESH]

---

## 6. Implementation Details

### A. Archive Generation (`BackupService.createBackup`)
1. Exports SharedPreferences to `settings.json`
2. Closes DB safely with `closeForBackup()`
3. Uses `ZipFileEncoder` to create `.bak` archive
4. Cleans up temporary files

### B. Storage Location
Files are stored in `getApplicationDocumentsDirectory()/backups/` ensuring they persist within the app's private storage.

### C. Validation (`BackupService.validateBackup`) ✅
Before restoration, the system:
- Verifies ZIP structure integrity
- Confirms `fitness_tracker.db` exists
- Checks minimum DB size (1KB threshold)

### D. Atomic Restore (`BackupService.restoreBackup`) ✅
Uses **Copy-then-Swap** approach:
1. Validate backup file integrity
2. Close active database
3. Create safety backup of current DB (`*.old_backup`)
4. Unzip to temporary staging directory
5. Move staged DB to active location
6. **On Success**: Delete staging and old backup
7. **On Failure**: Rollback to previous DB state

---

## 7. Security Highlights
- **No Cloud Dependency**: 100% local storage, ensuring privacy and offline capability.
- **Atomic Operations**: Prevents data corruption with rollback safety net.
- **Battery-Friendly**: Background tasks only run when device is charging.
