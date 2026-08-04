FROM postgis/postgis:18-3.6
RUN apt update && apt install -y postgresql-18-pgvector