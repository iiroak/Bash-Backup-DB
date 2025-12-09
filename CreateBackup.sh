#!/bin/bash

# Configuración
DB_USER="your_database_user"
DB_PASSWORD="your_database_password"
DATABASES=("database1" "database2")
BACKUP_DIR="/backups"
RCLONE_REMOTE="your_rclone_remote"
RCLONE_DIR="Database/Backups"

# Obtener la fecha y hora actual
CURRENT_DATE=$(date +"%Y-%m-%d")
CURRENT_TIME=$(date +"%H-%M-%S")
CURRENT_MONTH_YEAR=$(date +"%m_%Y")
CURRENT_DAY=$(date +"%d")

# Crear directorio de backup
BACKUP_PATH="$BACKUP_DIR/$CURRENT_MONTH_YEAR/$CURRENT_DAY"
mkdir -p "$BACKUP_PATH"

# Realizar backup de cada base de datos
for DB_NAME in "${DATABASES[@]}"; do
    BACKUP_FILE="$BACKUP_PATH/${DB_NAME}_${CURRENT_DATE}_${CURRENT_TIME}.sql"
    mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILE

    # Mover el backup a rclone
    rclone copy $BACKUP_FILE $RCLONE_REMOTE:$RCLONE_DIR/$CURRENT_MONTH_YEAR/$CURRENT_DAY/
done

# Eliminar backups locales antiguos (opcional, por defecto 7 días)
find $BACKUP_DIR -type f -mtime +7 -exec rm {} \;