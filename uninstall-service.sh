#!/bin/bash

# Script para desinstalar el cron job de backup automático

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=========================================="
echo "Desinstalador de Backup Automático"
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

echo -e "${YELLOW}Eliminando cron job...${NC}"

# Eliminar el cron job
if crontab -l 2>/dev/null | grep -q "$BACKUP_SCRIPT"; then
    crontab -l 2>/dev/null | grep -v "$BACKUP_SCRIPT" | crontab -
    echo -e "${GREEN}✓ Cron job eliminado${NC}"
else
    echo -e "${YELLOW}No se encontró ningún cron job configurado${NC}"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "Desinstalación completada"
echo "==========================================${NC}"
echo ""
echo "El script CreateBackup.sh permanece en el sistema."
echo "Puedes seguir ejecutándolo manualmente si lo deseas."
echo ""
