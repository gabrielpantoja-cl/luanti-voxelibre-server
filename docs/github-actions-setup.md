# Configuración GitHub Actions - Vegan Wetlands

## 🔐 Paso 1: Configurar GitHub Secrets

1. Ve a tu repositorio en GitHub
2. Settings → Secrets and variables → Actions
3. Haz clic en "New repository secret"
4. Agrega cada uno de estos secrets:

### Secrets Requeridos

| Nombre | Valor | Descripción |
|--------|--------|-------------|
| `VPS_HOST` | `167.172.251.27` | IP del servidor VPS |
| `VPS_USER` | `gabriel` | Usuario SSH del VPS |
| `VPS_SSH_KEY` | `[tu-clave-privada]` | Contenido de tu clave SSH privada |
| `VPS_PORT` | `22` | Puerto SSH (opcional, default: 22) |

## 🔑 Paso 2: Obtener la Clave SSH

### Si ya tienes acceso SSH al servidor:
```bash
# En tu máquina local, muestra la clave privada
cat ~/.ssh/id_rsa
# O si usas otro archivo de clave:
cat ~/.ssh/vps_key
```

### Si necesitas crear una nueva clave SSH:
```bash
# 1. Generar nueva clave SSH
ssh-keygen -t rsa -b 4096 -C "gabriel@vegan-wetlands"
# Guardar como: /home/user/.ssh/vps_vegan_wetlands

# 2. Copiar clave pública al servidor
ssh-copy-id -i ~/.ssh/vps_vegan_wetlands.pub gabriel@167.172.251.27

# 3. Probar conexión
ssh -i ~/.ssh/vps_vegan_wetlands gabriel@167.172.251.27

# 4. Mostrar clave privada para GitHub Secret
cat ~/.ssh/vps_vegan_wetlands
```

## 🚀 Paso 3: Primer Despliegue

### Opción A: Despliegue Automático (Recomendado)
```bash
# Agregar DNS primero en Cloudflare:
# luanti.gabrielpantoja.cl → 167.172.251.27

# Luego hacer push para activar GitHub Actions
git add .
git commit -m "🚀 Configurar despliegue inicial Vegan Wetlands

🌱 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
git push origin main
```

### Opción B: Despliegue Manual (Si Actions falla)
```bash
# Conectar al VPS
ssh gabriel@167.172.251.27

# Preparar directorio
sudo mkdir -p /opt/vegan-wetlands
sudo chown gabriel:gabriel /opt/vegan-wetlands
cd /opt/vegan-wetlands

# Clonar repositorio
git clone https://github.com/gabrielpantoja-cl/Vegan-Wetlands.git .

# Configurar VPS
chmod +x scripts/setup-vps.sh
sudo ./scripts/setup-vps.sh

# Iniciar servidor
./scripts/start.sh
```

## ✅ Paso 4: Verificar Despliegue

1. **GitHub Actions**: Ve a tu repo → Actions, verifica que el workflow se ejecute sin errores
2. **Servidor**: Verifica que `luanti.gabrielpantoja.cl:30000` sea accesible
3. **Lista pública**: El servidor aparecerá en la lista oficial de Luanti en ~5 minutos

## 🔧 Troubleshooting

### Error: "Permission denied (publickey)"
- Verifica que el `VPS_SSH_KEY` sea la clave privada completa (incluye `-----BEGIN` y `-----END`)
- Asegúrate que la clave pública esté en `~/.ssh/authorized_keys` del usuario gabriel en el VPS

### Error: "Directory not found /opt/vegan-wetlands"  
- El workflow creará el directorio automáticamente en el primer despliegue
- Si falla, conéctate manualmente y crea el directorio

### Error: Docker daemon not running
- El script `setup-vps.sh` instala Docker automáticamente
- Si falla, ejecuta manualmente: `sudo systemctl start docker`

## 📊 Monitoreo Post-Despliegue

```bash
# Verificar que el contenedor esté corriendo
docker ps

# Ver logs del servidor
docker-compose logs -f luanti-server

# Verificar puerto abierto
sudo ss -tulpn | grep :30000

# Test de conectividad externa
nmap -sU -p 30000 167.172.251.27
```