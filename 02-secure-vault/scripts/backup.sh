#Our backup.sh script is responsible for packaging our application data, uploading it to Amazon S3, recording whether the backup was successful or failed, and cleaning up temporary files after execution.
#Inside this file, we will write the Bash commands responsible for automating our backup process, from compressing our application data to uploading it to S3 and handling the cleanup process.

#!/bin/bash
set -euo pipefail

export AWS_DEFAULT_REGION=eu-west-2

BUCKET="secure-vault-backups-john-4827"
SRC_PARENT="/var/app"
LOG="/var/log/backup.log"
STAMP=$(date +%Y-%m-%d-%H%M)
ARCHIVE="/tmp/backup-${STAMP}.tar.gz"

log() { echo "$(date -Is) $1" >> "$LOG"; }

trap 'log "FAILURE: backup ${STAMP} failed"; rm -f "$ARCHIVE"' ERR

tar -czf "$ARCHIVE" -C "$SRC_PARENT" data
/usr/local/bin/aws s3 cp "$ARCHIVE" "s3://${BUCKET}/backups/" --only-show-errors

log "SUCCESS: uploaded backup-${STAMP}.tar.gz to s3://${BUCKET}/backups/"
rm -f "$ARCHIVE"


# what each part of the script means.

# Setting safety rules with (set -euo pipeline) so that the script stops at the first error instead of carrying on and pretending everything worked.

# Setting the region (AWS_DEFAULT_REGION) so that cron runs as root.

# Building a timestamped name (STAMP, ARCHIVE) for example backup-2026-11-14-0410.tar.gz, saved in /tmp, not inside the folder being archived.

# Compressing the data with (tar -czf) so that it can pack everything in /var/app/data including (app.log) into that one file.

# Uploading it to S3 with (aws s3 cp) so that the file goes to backups/ in your bucket, privately through the endpoint, using the role’s temporary credentials.

# Logging the result (log) so that it can appends a timestamped success line to /var/log/backup.log .

# Deleting the local archive (rm -f), this happens only after a successful upload, so the disk doesn’t fill up.
