#!/bin/bash

# Script de instalación del cron job de backup automático
# Este script configura cron para ejecutar backups cada 6 horas

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=========================================="
echo "Instalador de Backup Automático con Cron"
echo "==========================================${NC}"
echo ""

# Verificar que se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Este script debe ejecutarse como root (sudo)${NC}" 
   exit 1
fi

# Obtener el directorio actual del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$SCRIPT_DIR/CreateBackup.sh"
LOG_FILE="/var/log/database-backup.log"

# Verificar que existe el script de backup
if [ ! -f "$BACKUP_SCRIPT" ]; then
    echo -e "${RED}Error: No se encontró CreateBackup.sh en $SCRIPT_DIR${NC}"
    echo "Por favor, asegúrate de que CreateBackup.sh existe y tiene las credenciales configuradas."
    exit 1
fi

# Hacer el script ejecutable
chmod +x "$BACKUP_SCRIPT"

echo -e "${YELLOW}Configurando cron job...${NC}"

# Crear entrada de cron (cada 6 horas: 0:00, 6:00, 12:00, 18:00)
CRON_JOB="0 */6 * * * $BACKUP_SCRIPT >> $LOG_FILE 2>&1"

# Verificar si ya existe el cron job
if crontab -l 2>/dev/null | grep -q "$BACKUP_SCRIPT"; then
    echo -e "${YELLOW}El cron job ya existe. Eliminando entrada anterior...${NC}"
    crontab -l 2>/dev/null | grep -v "$BACKUP_SCRIPT" | crontab -
fi

# Agregar el nuevo cron job
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo -e "${GREEN}✓ Cron job configurado${NC}"

# Crear el archivo de log si no existe
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# Ejecutar backup inmediatamente como prueba
echo ""
echo -e "${YELLOW}¿Deseas ejecutar un backup de prueba ahora? (y/N):${NC}"
read -r RESPONSE
if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Ejecutando backup de prueba...${NC}"
    $BACKUP_SCRIPT >> $LOG_FILE 2>&1
    echo -e "${GREEN}✓ Backup ejecutado${NC}"
    echo -e "${GREEN}✓ Revisa el log en: $LOG_FILE${NC}"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "¡Instalación completada exitosamente!"
echo "==========================================${NC}"
echo ""
echo "El backup se ejecutará automáticamente cada 6 horas:"
echo "  - 00:00 (medianoche)"
echo "  - 06:00 (6 AM)"
echo "  - 12:00 (mediodía)"
echo "  - 18:00 (6 PM)"
echo ""
echo -e "${GREEN}Comandos útiles:${NC}"
echo "  Ver cron jobs instalados:"
echo "    crontab -l"
echo ""
echo "  Ver logs del backup:"
echo "    tail -f $LOG_FILE"
echo ""
echo "  Ejecutar backup manualmente:"
echo "    $BACKUP_SCRIPT"
echo ""
echo "  Editar horarios de backup:"
echo "    crontab -e"
echo ""
echo "  Desinstalar backup automático:"
echo "    ./uninstall-service.sh"
echo ""