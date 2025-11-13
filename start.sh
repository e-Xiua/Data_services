#!/bin/bash
# Startup script para Data Services
# Ejecuta consumer.py y data_analisys.py en paralelo

echo "🚀 Iniciando Data Services..."
echo "================================"

# Función para manejar señales de salida
cleanup() {
    echo ""
    echo "🛑 Deteniendo servicios..."
    kill $CONSUMER_PID $API_PID 2>/dev/null
    wait $CONSUMER_PID $API_PID 2>/dev/null
    echo "✅ Servicios detenidos"
    exit 0
}

# Registrar manejador de señales
trap cleanup SIGTERM SIGINT

# Iniciar consumer.py en background
echo "📨 Iniciando RabbitMQ Consumer..."
python consumer.py &
CONSUMER_PID=$!
echo "   PID: $CONSUMER_PID"

# Esperar un momento para que el consumer se inicie
sleep 2

# Iniciar data_analisys.py (Flask API) en background
echo "🌐 Iniciando Flask Analytics API..."
python data_analisys.py &
API_PID=$!
echo "   PID: $API_PID"

echo "================================"
echo "✅ Servicios iniciados correctamente"
echo "   Consumer PID: $CONSUMER_PID"
echo "   Flask API PID: $API_PID"
echo "================================"

# Monitorear ambos procesos
while kill -0 $CONSUMER_PID 2>/dev/null && kill -0 $API_PID 2>/dev/null; do
    sleep 5
done

# Si alguno termina, detener el otro
echo "⚠️  Uno de los procesos terminó"
cleanup
