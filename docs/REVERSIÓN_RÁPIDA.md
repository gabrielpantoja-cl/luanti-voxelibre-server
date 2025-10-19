# 🔄 REVERSIÓN RÁPIDA A MODO CREATIVO

## Para mañana 20 de octubre de 2025

### Opción 1: Script Automático (RECOMENDADO) ⚡

```bash
ssh gabriel@<VPS_IP> "cd /home/gabriel/luanti-voxelibre-server && ./scripts/revert-to-creative.sh"
```

**Tiempo estimado**: 2-3 minutos
**Acciones automáticas**:
- ✅ Verifica backups
- ✅ Crea backup del mundo actual
- ✅ Restaura configuración nuclear
- ✅ Restaura luanti.conf
- ✅ Reinicia servidor
- ✅ Verifica estado final

---

### Opción 2: Manual (solo si el script falla) 🔧

#### Paso 1: Conectar al VPS
```bash
ssh gabriel@<VPS_IP>
cd /home/gabriel/luanti-voxelibre-server
```

#### Paso 2: Crear backup de seguridad
```bash
./scripts/backup.sh
```

#### Paso 3: Restaurar configuración nuclear
```bash
docker-compose exec -T luanti-server cp \
  /config/.minetest/games/mineclone2/minetest.conf.backup_20251019_creativo \
  /config/.minetest/games/mineclone2/minetest.conf
```

#### Paso 4: Restaurar luanti.conf
```bash
cp server/config/luanti.conf.backup_20251019_creativo \
   server/config/luanti.conf
```

#### Paso 5: Reiniciar servidor
```bash
docker-compose restart luanti-server
```

#### Paso 6: Esperar 30 segundos
```bash
sleep 30
```

#### Paso 7: Verificar reversión exitosa
```bash
# Debe mostrar: creative_mode = true, enable_damage = false, etc.
docker-compose exec -T luanti-server cat \
  /config/.minetest/games/mineclone2/minetest.conf | \
  grep -E "(creative_mode|enable_damage|enable_pvp|mobs_spawn)"
```

**Resultado esperado**:
```
creative_mode = true
enable_damage = false
enable_pvp = false
mobs_spawn = false
```

---

### Verificación Post-Reversión ✅

```bash
# Estado del servidor
docker-compose ps

# Ver logs recientes
docker-compose logs --tail=50 luanti-server

# Verificar que no aparezcan mobs enemigos
docker-compose logs luanti-server | grep -i "zombie\|skeleton\|spider\|creeper" | tail -20
```

---

### En caso de emergencia 🚨

Si algo sale mal durante la reversión:

1. **Detener servidor**:
   ```bash
   docker-compose down
   ```

2. **Restaurar desde backup del mundo**:
   ```bash
   # Listar backups disponibles
   ls -lht server/backups/

   # Restaurar último backup (ejemplo)
   cd server/worlds
   rm -rf world
   tar -xzf ../backups/world_backup_YYYYMMDD_HHMMSS.tar.gz
   ```

3. **Reiniciar desde cero**:
   ```bash
   docker-compose up -d
   ```

4. **Contactar soporte**: Revisar logs completos
   ```bash
   docker-compose logs --tail=200 luanti-server > error_log.txt
   ```

---

## Archivos Importantes

- **Backup configuración nuclear**: `/config/.minetest/games/mineclone2/minetest.conf.backup_20251019_creativo`
- **Backup luanti.conf**: `server/config/luanti.conf.backup_20251019_creativo`
- **Script de reversión**: `scripts/revert-to-creative.sh`
- **Documentación completa**: `docs/SUPERVIVENCIA_TEMPORAL_20251019.md`
- **Resumen ejecutivo**: `RESUMEN_SUPERVIVENCIA_20251019.txt`

---

## Checklist de Reversión

- [ ] Ejecutar script de reversión
- [ ] Verificar `creative_mode = true`
- [ ] Verificar `enable_damage = false`
- [ ] Verificar `mobs_spawn = false`
- [ ] Servidor reiniciado y healthy
- [ ] Conectar al juego y verificar modo creativo
- [ ] Verificar que no aparezcan mobs enemigos de noche
- [ ] Avisar a jugadores que volvió el modo normal
- [ ] Limpiar archivos temporales (opcional)

---

**Creado**: 19 de Octubre 2025
**Propósito**: Guía rápida de reversión a modo creativo
**Válido hasta**: 20 de Octubre 2025