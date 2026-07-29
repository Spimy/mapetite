# Mapetite 📍🍔

Mapetite is a "Zero-Input" micro-economy platform designed to connect merchants with users through intelligent routine matching and location-based discovery.

## 🏗 Project Structure

This is a monorepo organised as follows:

- **`server/`**: The core Django engine. Contains the REST API for mobile, the Merchant Management Dashboard, and the project landing pages.
- **`mobile-client/`**: The mobile application (Flutter).
- **`docker-compose.yml`**: Orchestrates the shared backend infrastructure (PostGIS Database and the Django Web Server).

## 🚀 Quick Start (Mobile & Frontend Developers)

The entire backend (Database + Django Server) runs inside Docker. You do not need to install Python or configure any databases locally.

1. Ensure Docker Desktop is running.
2. From this root directory, build and start the containers:
   ```bash
   docker compose up
   ```
3. Run the database migrations and create your local admin account (requires `make`):

   ```bash
   make migrate
   make createsuperuser
   ```

   or without `make`:

   ```bash
   docker compose exec web python manage.py migrate
   docker compose exec web python manage.py createsuperuser
   ```


4. You should seed the database:

   ```bash
   docker compose exec web python manage.py loaddata fixtures/merchants.json
   docker compose exec web python manage.py loaddata fixtures/recipes.json
   # or
   make seed
   ```

   After seeding your database, you will need to generate the embeddings for vector searching store items and may take a few minutes to complete:

   ```bash
   docker compose exec web python manage.py generate_embeddings
   # or
   make generate-embeddings
   ```

**Mobile Emulator Note:** If you are testing the Flutter app on an Android Emulator, your API base URL must be `http://10.0.2.2:8000/api/` (not localhost) to connect to your host machine's Docker network.

## 👥 Team Guidelines

- **Backend:** See the [Server README](./server/README.md) for the Dev Container setup.
- **Frontend:** See the [Mobile Client README](./mobile-client/README.md) for environment setup.
- **Version Control:** Never commit `.env` files. Use the provided `.env.example` templates.
