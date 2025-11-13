# Usar imagen base de Python
FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias del sistema necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copiar archivos de requisitos
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copiar archivos de la aplicación
COPY consumer.py .
COPY data_analisys.py .
COPY start.sh .

# Hacer el script ejecutable
RUN chmod +x start.sh

# Agregar pika a los requirements si no está
RUN pip install --no-cache-dir pika==1.3.2

# Crear usuario no-root para seguridad
RUN useradd -m -u 1000 dataservices && \
    chown -R dataservices:dataservices /app

USER dataservices

# Exponer puerto para Flask API
EXPOSE 5000

# Variables de entorno
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=data_analisys.py

# Health check para Flask API
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/api/dashboard-admin').read()" || exit 1

# Ejecutar script de inicio que maneja ambos servicios
CMD ["./start.sh"]
