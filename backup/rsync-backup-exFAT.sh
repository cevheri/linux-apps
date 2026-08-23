#!/bin/bash
#
# Backs up $HOME to the external exFAT disk "chdev".
#
# Adapted for an exFAT destination on 2026-08-23.
# Original version kept as: rsync-backup.sh.bak
#
# WHY NOT `-a`:
#   `-a` expands to `-rlptgoD`, which tries to preserve permissions (-p),
#   owner (-o), group (-g), symlinks (-l) and device/special files (-D).
#   exFAT can store NONE of these, so every single file would raise a
#   chown/chmod error. The flags below keep only what exFAT can actually
#   represent.
#
# EXPECTED EXIT CODE:
#   rc=23 ("partial transfer") is NORMAL here, not a failure. exFAT rejects
#   filenames containing  :  *  ?  "  <  >  |  \  — rsync reports those as
#   `Invalid argument (22)` and finishes with 23. On the 2026-08-23 run this
#   affected 17 items out of 1,456,233 (log files with timestamps in their
#   names, build artifacts, one empty leftover directory). Check the log for
#   `No space` or `rsync error` to distinguish a real problem.
#
# DISK USAGE WARNING:
#   mkfs.exfat picks a 128 KB cluster size on a 3.7 TB volume. With ~1.5M
#   mostly-small files, 173 GB of data occupied 347 GB on disk — roughly
#   double. Size the destination accordingly.

SRC_DIR="$HOME/"
DEST_DIR="/media/$USER/chdev/"      # straight to the disk root, no subfolder
EXCLUDE_FILE="$HOME/rsync-exclude.txt"
LOG_FILE="$HOME/backup.log"

# --- Guard 1: is the destination actually mounted? ---
# Without this, an unmounted disk would make rsync write into the mount point
# directory on the system disk instead, silently filling the root filesystem.
# Requiring the source to be a /dev/sd* device also rejects any other target.
MOUNT_ROOT="/media/$USER/chdev"
if ! findmnt -no SOURCE --target "$MOUNT_ROOT" 2>/dev/null | grep -q '^/dev/sd'; then
  echo "!!! $(date) - ABORT: $MOUNT_ROOT is not mounted, no backup taken." >> "$LOG_FILE"
  exit 1
fi

# --- Guard 2: recursion protection ---
# If the destination ever ended up inside the source tree, rsync would copy
# its own output back into itself. Currently impossible (/media vs /home),
# but cheap to assert.
SRC_REAL="$(readlink -f "$SRC_DIR")"
DEST_REAL="$(readlink -f "$MOUNT_ROOT")"
case "$DEST_REAL/" in
  "$SRC_REAL"/*) echo "!!! $(date) - ABORT: destination ($DEST_REAL) lies inside source ($SRC_REAL), recursion risk." >> "$LOG_FILE"; exit 1;;
esac

mkdir -p "$DEST_DIR" || { echo "!!! $(date) - ABORT: could not create $DEST_DIR." >> "$LOG_FILE"; exit 1; }

echo "=== $(date) - Rsync Backup started ===" >> "$LOG_FILE"

rsync \
  -rtv \
  --no-perms --no-owner --no-group \
  --modify-window=1 \
  --exclude-from="$EXCLUDE_FILE" \
  --no-links \
  --ignore-errors \
  --ignore-missing-args \
  --stats \
  "$SRC_DIR" "$DEST_DIR" >> "$LOG_FILE" 2>&1
#  -rtv                  recurse, preserve mtimes, verbose file list.
#                        Deliberately NOT -a; see the header note.
#  --no-perms            \
#  --no-owner             > exFAT cannot store these; asking for them only
#  --no-group            /  produces one error per file.
#  --modify-window=1     exFAT timestamps have 2-second granularity. Without
#                        this, every incremental run sees every file as
#                        changed and recopies all ~150 GB.
#  --exclude-from        Patterns in rsync-exclude.txt. Note the anchoring
#                        rules: "/logs/" matches only $HOME/logs, while
#                        "__pycache__/" matches at any depth.
#  --no-links            Skip symlinks instead of failing on them. exFAT has
#                        no symlink support at all.
#  --ignore-errors       Keep going past I/O errors. CAUTION: this also
#                        disables rsync's safety rule that cancels --delete
#                        after an error. Harmless today because --delete is
#                        not used; revisit if it is ever added.
#  --ignore-missing-args Do not fail when a source path vanishes mid-run
#                        (caches and temp files come and go during a
#                        multi-hour backup).
#  --stats               Print the file/byte summary used for verification.

RC=$?
if [ $RC -eq 0 ]; then
  echo "=== $(date) - Backup Completed ===" >> "$LOG_FILE"
else
  echo "!!! $(date) - Backup finished with rc=$RC, see the log file: $LOG_FILE" >> "$LOG_FILE"
fi
exit $RC
