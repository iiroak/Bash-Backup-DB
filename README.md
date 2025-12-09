# Bash Database Backup Script

Script automatizado para realizar backups de bases de datos MySQL/MariaDB y sincronizarlos con almacenamiento en la nube usando rclone.

## 🚀 Características

- ✅ Backup automático de múltiples bases de datos
- ✅ Organización por mes/año y día
- ✅ Sincronización automática con almacenamiento en la nube (rclone)
- ✅ Limpieza automática de backups antiguos (>7 días)
- ✅ Nombres de archivo con timestamp

## 📋 Requisitos

- MySQL/MariaDB instalado
- `mysqldump` disponible en el sistema
- `rclone` configurado con un remote válido
- Bash shell

## ⚙️ Configuración

1. Copia el archivo de ejemplo:
```bash
cp CreateBackup.example.sh CreateBackup.sh
```

2. Edita `CreateBackup.sh` con tus credenciales:
```bash
nano CreateBackup.sh
```

3. Configura los siguientes parámetros:
   - `DB_USER`: Usuario de la base de datos
   - `DB_PASSWORD`: Contraseña del usuario
   - `DATABASES`: Array con los nombres de las bases de datos
   - `BACKUP_DIR`: Directorio local para backups
   - `RCLONE_REMOTE`: Nombre del remote de rclone
   - `RCLONE_DIR`: Directorio en el remote

## 📁 Estructura de Backups

Los backups se organizan de la siguiente manera:

```
/backups/
  ├── 01_2025/          # Mes_Año
  │   ├── 01/           # Día
  │   │   ├── database1_2025-01-01_14-30-00.sql
  │   │   └── database2_2025-01-01_14-30-00.sql
  │   └── 02/
  ├── 02_2025/
  ...
```

## 🔧 Uso

### Opción 1: Instalación con Cron (Recomendado) ⭐

**Instalación automática cada 6 horas:**
```bash
chmod +x install-service.sh
sudo ./install-service.sh
```

El backup se ejecutará automáticamente cada 6 horas:
- 00:00 (medianoche)
- 06:00 (6 AM)
- 12:00 (mediodía)
- 18:00 (6 PM)

**Comandos útiles:**
```bash
# Ver cron jobs instalados
crontab -l

# Ver logs en tiempo real
tail -f /var/log/database-backup.log

# Ejecutar backup manualmente
sudo ./CreateBackup.sh

# Editar horarios
crontab -e

# Desinstalar
sudo ./uninstall-service.sh
```

### Opción 2: Ejecución manual
```bash
chmod +x CreateBackup.sh
./CreateBackup.sh
```

### Opción 3: Configuración manual de cron

Edita el crontab:
```bash
crontab -e
```

Ejemplos:
```bash
# Cada 6 horas
0 */6 * * * /path/to/CreateBackup.sh >> /var/log/backup.log 2>&1

# Diario a las 2:00 AM
0 2 * * * /path/to/CreateBackup.sh >> /var/log/backup.log 2>&1

# Cada hora
0 * * * * /path/to/CreateBackup.sh >> /var/log/backup.log 2>&1
```

## 🔐 Configuración de rclone

Si no tienes rclone configurado:

```bash
# Instalar rclone
curl https://rclone.org/install.sh | sudo bash

# Configurar remote
rclone config
```

Sigue las instrucciones para configurar tu servicio en la nube (Google Drive, Dropbox, ProtonDrive, etc.).

## 🧹 Limpieza Automática

El script elimina automáticamente los backups locales más antiguos de 7 días. Para modificar este período, cambia el número en esta línea:

```bash
find $BACKUP_DIR -type f -mtime +7 -exec rm {} \;
```

## ⚠️ Seguridad

- **NUNCA** subas `CreateBackup.sh` con credenciales reales a GitHub
- Usa `CreateBackup.example.sh` como plantilla pública
- Asegúrate de que `CreateBackup.sh` esté en `.gitignore`
- Protege los permisos del archivo: `chmod 600 CreateBackup.sh`

## 📝 Logs

Para mantener un registro de los backups:

```bash
./CreateBackup.sh >> /var/log/backup.log 2>&1
```

Ver logs:
```bash
tail -f /var/log/backup.log
```

## 🆘 Solución de Problemas

### Error: "Access denied"
- Verifica las credenciales de MySQL
- Asegúrate de que el usuario tenga permisos de lectura

### Error: "rclone: command not found"
- Instala rclone: `curl https://rclone.org/install.sh | sudo bash`

### Los backups no se suben a la nube
- Verifica la configuración de rclone: `rclone config`
- Prueba la conexión: `rclone lsd REMOTE_NAME:`

## 📄 Licencia

Este script es de uso libre. Modifícalo según tus necesidades.

## 🤝 Contribuciones

Si encuentras mejoras o errores, siéntete libre de crear un issue o pull request.
