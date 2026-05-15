# Mapetite 📍🍔

Mapetite is a "Zero-Input" micro-economy platform designed to connect merchants with users through intelligent routine matching and location-based discovery.

## 🏗 Project Structure

This is a monorepo organised as follows:

* **`server/`**: The core engine. Contains the REST API for mobile, the Merchant Management Dashboard, and the project landing pages.
* **`mobile-client/`**: The mobile application (Flutter/React Native).
* **`docker-compose.yml`**: Orchestrates the shared infrastructure (Database).

## 🚀 Quick Start (Infrastructure)

The backend requires a PostgreSQL database. We use Docker to ensure everyone runs the same version without manual installation.

1.  Ensure Docker Desktop is running.
2.  From this root directory, run:
    ```bash
    docker compose up
    ```

## 👥 Team Guidelines

* **Backend:** See the [Server README](./server/README.md) for environment setup.
* **Frontend:** See the [Mobile Client README](./mobile-client/README.md) for environment setup.
* **Version Control:** Never commit `.env` files. Use the provided `.env.example` templates.