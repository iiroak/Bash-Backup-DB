#!/bin/bash

# Configuración
DB_USER="your_database_user"
DB_PASSWORD="your_database_password"
DATABASES=("database1" "database2" "database3")
BACKUP_DIR="/backups"
RCLONE_REMOTE="googledrive"
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
    BACKUP_FILE_GZ="${BACKUP_FILE}.gz"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creando backup de $DB_NAME..."
    mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILE
    
    if [ $? -eq 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✓ Backup creado: $(basename $BACKUP_FILE)"
        
        # Comprimir el backup
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Comprimiendo backup..."
        gzip -f "$BACKUP_FILE"
        
        if [ $? -eq 0 ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✓ Backup comprimido: $(basename $BACKUP_FILE_GZ)"
            
            # Subir con método más conservador para Google Drive
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Subiendo a Google Drive..."
            
            # Intentar subida con reintentos espaciados
            for attempt in 1 2 3; do
                rclone copy "$BACKUP_FILE_GZ" "$RCLONE_REMOTE:$RCLONE_DIR/$CURRENT_MONTH_YEAR/$CURRENT_DAY/" \
                    --ignore-existing \
                    --no-traverse \
                    --timeout 10m \
                    --transfers 1 \
                    --buffer-size 8M \
                    --log-level INFO
                
                if [ $? -eq 0 ]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✓ Backup subido exitosamente (intento $attempt)"
                    rm -f "$BACKUP_FILE_GZ"
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✓ Archivo local eliminado"
                    break
                else
                    if [ $attempt -lt 3 ]; then
                        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠ Error en intento $attempt, esperando 30 segundos..."
                        sleep 30
                    else
                        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✗ Error después de 3 intentos, manteniendo backup local:"
                        echo "  $BACKUP_FILE_GZ"
                    fi
                fi
            done
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✗ Error al comprimir backup"
        fi
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✗ Error al crear backup de $DB_NAME"
    fi
    
    echo ""
done

# Eliminar backups locales antiguos (opcional)
find $BACKUP_DIR -type f -mtime +7 -exec rm {} \;
