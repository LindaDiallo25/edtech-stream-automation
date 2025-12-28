FROM python:3.9-slim

# On installe seulement le strict nécessaire pour PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev && rm -rf /var/lib/apt/lists/*

# On utilise psycopg2-binary pour éviter de compiler (gain de temps énorme)
RUN pip install --no-cache-dir psycopg2-binary

WORKDIR /app
COPY scripts/edtech_simulator.py .

CMD ["python", "edtech_simulator.py"]