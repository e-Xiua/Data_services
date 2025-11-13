#!/bin/bash
# Script de despliegue rápido para Data Services

set -e

echo "🚀 DESPLIEGUE DE DATA SERVICES"
echo "================================"

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose no está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker y Docker Compose encontrados${NC}"

# Verificar archivo .env
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  Archivo .env no encontrado${NC}"
    echo "📝 Creando .env desde .env.example..."
    cp .env.example .env
    echo -e "${YELLOW}⚠️  Por favor, revisa y ajusta las variables en .env${NC}"
    read -p "Presiona Enter para continuar..."
fi

# Crear red si no existe
if ! docker network inspect tesisNetwork >/dev/null 2>&1; then
    echo "🌐 Creando red tesisNetwork..."
    docker network create tesisNetwork
    echo -e "${GREEN}✅ Red creada${NC}"
else
    echo -e "${GREEN}✅ Red tesisNetwork ya existe${NC}"
fi

# Preguntar qué hacer
echo ""
echo "Selecciona una opción:"
echo "1) Construir e iniciar servicios"
echo "2) Solo construir imágenes"
echo "3) Iniciar servicios existentes"
echo "4) Detener servicios"
echo "5) Detener y eliminar todo (incluyendo volúmenes)"
echo "6) Ver logs"
read -p "Opción [1]: " option
option=${option:-1}

case $option in
    1)
        echo "🏗️  Construyendo e iniciando servicios..."
        docker-compose up -d --build
        echo -e "${GREEN}✅ Servicios iniciados${NC}"
        echo ""
        echo "📊 Estado de los servicios:"
        docker-compose ps
        echo ""
        echo "📝 Para ver logs: docker-compose logs -f"
        echo "🌐 API disponible en: http://localhost:5000"
        ;;
    2)
        echo "🏗️  Construyendo imágenes..."
        docker-compose build
        echo -e "${GREEN}✅ Imágenes construidas${NC}"
        ;;
    3)
        echo "▶️  Iniciando servicios..."
        docker-compose up -d
        echo -e "${GREEN}✅ Servicios iniciados${NC}"
        docker-compose ps
        ;;
    4)
        echo "⏸️  Deteniendo servicios..."
        docker-compose down
        echo -e "${GREEN}✅ Servicios detenidos${NC}"
        ;;
    5)
        echo -e "${RED}⚠️  Esto eliminará todos los datos${NC}"
        read -p "¿Estás seguro? (si/no) [no]: " confirm
        if [ "$confirm" = "si" ]; then
            echo "🗑️  Eliminando servicios y volúmenes..."
            docker-compose down -v
            echo -e "${GREEN}✅ Todo eliminado${NC}"
        else
            echo "Operación cancelada"
        fi
        ;;
    6)
        echo "📝 Mostrando logs (Ctrl+C para salir)..."
        docker-compose logs -f
        ;;
    *)
        echo -e "${RED}❌ Opción inválida${NC}"
        exit 1
        ;;
esac

echo ""
echo "================================"
echo -e "${GREEN}✅ Operación completada${NC}"
