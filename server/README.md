# Mapetite Backend & Web Engine ⚙️

The core engine for Mapetite. This project serves the **JSON API** for the mobile client, the **Merchant Web Dashboard**, and the project **Landing Pages**.

## 🛠 Prerequisites

- **Docker Desktop**: The entire Python environment, PostgreSQL 18 (PostGIS), and spatial C-libraries (GDAL) are containerised. You do not need Python installed on your local machine.
- **VS Code**: Required for the backend development workflow.
- **Dev Containers Extension**: Install the official Microsoft `Dev Containers` extension in VS Code.

## 📥 Local Setup & Architecture

This project uses a **VS Code Dev Container**. Instead of managing virtual environments on your Windows or Mac machine, VS Code will inject itself directly into the running Linux Docker container, giving you perfect IntelliSense, Git tracking, and a native terminal.

### 1. Environment Variables

Copy the template and fill in the secrets. **Never commit the `.env` file.**

```bash
cp .env.example .env

```

_(Ensure `POSTGRES_HOST=database` is set in your `.env` so Django can find Postgres inside the Docker network)._

### 2. Booting the Dev Container

1. Open this repository in VS Code.
2. Press **`Ctrl + Shift + P`** (Windows/Linux) or **`Cmd + Shift + P`** (Mac) to open the Command Palette.
3. Search for and select: **`Dev Containers: Reopen in Container`**.

VS Code will build the container, install all necessary extensions (like Black, DJLint, and Pylance), and log you in.

### 3. The Native Terminal

Once inside the Dev Container, open a new terminal in VS Code (`Ctrl + ~`). **You are now natively inside the Linux container at the `/workspace/server` directory.**

You do not need to use `make` or `docker compose exec...` anymore. You can run standard Django commands directly:

```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser

```

### 4. Seeding Database

This step can be ignored if you have already done this by following the [root README](../README.md).

There are fixtures provided for:

- **`fixtures/merchants.json`**: merchants (`StoreProfile`), operating hours (`StoreOperatingHour`), item categories (`ItemCategory`), and menu items/products (`StoreItem`)
- **`fixtures/recipes.json`**: recipes (`Recipe`), ingredients (`RecipeIngredient`), and instruction steps (`RecipeStep`)

You should seed these into your database:

```bash
python manage.py loaddata fixtures/merchants.json
python manage.py loaddata fixtures/recipes.json
```

From the repo root, `make seed` loads both fixtures via Docker.

After seeding your database, you will need to generate the embeddings for vector searching store items. To do that, there is a custom command located at [`apps/merchants/management/commands/generate_embeddings.py`](apps/merchants/management/commands/generate_embeddings.py). You can run this custom command in your terminal and may take a few minutes to complete:

```bash
python manage.py generate_embeddings
```

---

## 🛰 Development & Debugging

Because VS Code is running inside the container with your code, debugging works seamlessly out of the box.

1. Open the Run & Debug tab in VS Code.
2. Select the **Django** configuration and press **F5**.
3. Set breakpoints anywhere in your Python code.

**Access Points:**

- **Mobile API Base**: `http://127.0.0.1:8000/api/`
- **Merchant Dashboard**: `http://127.0.0.1:8000/dashboard/`
- **Django Admin**: `http://127.0.0.1:8000/admin/`

---

## 📂 Modular Architecture

All domain logic is located in the `apps/` directory to keep the root clean:

| App                  | Responsibility                                                                     |
| -------------------- | ---------------------------------------------------------------------------------- |
| **`apps.core`**      | Services used throughout the system such as GeminiService and Notification model.  |
| **`apps.users`**     | Identity and Authentication.                                                       |
| **`apps.merchants`** | Store profiles, spatial location (PostGIS), vector embeddings, and business logic. |
| **`apps.recipes`**   | Recipes, ingredients, recipe instruction steps, and business logic.                |
| **`apps.budgets`**   | Spending records of authenticated users for budget tracking.                       |

---

## 🔐 Google Authentication Setup

To enable Google Sign-In for the mobile API:

1. Generate a **Web application** OAuth client ID in the [Google Cloud Console](https://console.cloud.google.com/auth/clients/create). Leave redirect URIs empty.
2. Under **Authorised redirect URIs**, add `https://developers.google.com/oauthplayground` which will be needed when testing using Postman and Google OAuth Playground.
3. Log in to the local [Django Admin Dashboard](http://127.0.0.1:8000/admin/).
4. Under **Sites**, update `example.com` to `127.0.0.1:8000` (Display name: `Mapetite Local`).
5. Under **Social Accounts > Social applications**, add a new Google application with your Client ID and Secret key. Move `Mapetite Local` to the "Chosen sites" box.
6. _(For API Testing)_: Use the [Google OAuth2 Playground](https://developers.google.com/oauthplayground/) (Google OAuth2 API) to generate temporary `access_token` and `id_token` payloads for Postman.

---

## ⚠️ Guardrails & Best Practices

- **Adding Dependencies**: If you need a new Python package, add it to `requirements.txt` and run `pip install -r requirements.txt` directly in your VS Code terminal. No need to rebuild the container manually.
- **App Creation**: Always create new apps inside the `apps/` folder:
  `python manage.py startapp name apps/name`
- **CRITICAL**: You must manually update `apps/name/apps.py` so that `name = "apps.name"`.
- **Static/Media**: Store global assets in `/static` and user uploads in `/media`.
