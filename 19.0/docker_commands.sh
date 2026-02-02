#!/usr/bin/bash

#!/bin/bash

# --- Configuración ---
DIR_ENTERPRISE="odoo_docker_enterprise"
DIR_COMMUNITY="odoo_docker_community"

# Colores para una mejor UX
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Odoo Docker Management Tool ===${NC}"

# 1. Selección de Edición
echo "Seleccione la edición de Odoo:"
options_edition=("Enterprise" "Community" "Salir")
select opt_ed in "${options_edition[@]}"
do
    case $opt_ed in
        "Enterprise")
            COMPOSE_FILE="$DIR_ENTERPRISE/docker-compose.yml"
            EDITION="Enterprise"
            break
            ;;
        "Community")
            COMPOSE_FILE="$DIR_COMMUNITY/docker-compose.yml"
            EDITION="Community"
            break
            ;;
        "Salir")
            exit 0
            ;;
        *) echo "Opción inválida $REPLY";;
    esac
done

# Verificar si el archivo existe antes de continuar
if [ ! -f "$COMPOSE_FILE" ]; then
    echo -e "${RED}Error: No se encontró el archivo $COMPOSE_FILE${NC}"
    exit 1
fi

# 2. Selección de Acción
echo -e "\n${BLUE}Acción para Odoo $EDITION:${NC}"
options_action=("Up (Detach)" "Down" "Build" "Build No-Cache" "Restart" "Logs" "Volver")

select opt_ac in "${options_action[@]}"
do
    case $opt_ac in
        "Up (Detach)")
            docker compose -f "$COMPOSE_FILE" up -d
            break
            ;;
        "Down")
            docker compose -f "$COMPOSE_FILE" down
            break
            ;;
        "Build")
            docker compose -f "$COMPOSE_FILE" build
            break
            ;;
        "Build No-Cache")
            echo -e "${RED}Limpiando sistema y reconstruyendo...${NC}"
            docker system prune -f && docker compose -f "$COMPOSE_FILE" build --no-cache
            break
            ;;
        "Restart")
            docker compose -f "$COMPOSE_FILE" restart
            break
            ;;
        "Logs")
            docker compose -f "$COMPOSE_FILE" logs -f
            break
            ;;
        "Volver")
            exec "$0" # Reinicia el script
            ;;
        *) echo "Opción inválida $REPLY";;
    esac
done