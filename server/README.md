# Mapetite Backend & Web Engine ⚙️

The core engine for Mapetite. This project serves the **JSON API** for the mobile client, the **Merchant Web Dashboard**, and the project **Landing Pages**.

## 🛠 Prerequisites

- **Python 3.14.x**: We enforce a strict version guardrail to ensure environment parity across the team.
- **Database**: PostgreSQL 18 (Managed via the root `docker-compose.yml`).

## 📥 Local Setup

### 1. Install Python 3.14

Depending on your operating system, use one of the following methods:

**For WSL (Ubuntu) / Linux:**

```bash
# Install build dependencies, then:
curl https://pyenv.run | bash
pyenv install 3.14.5
pyenv global 3.14.5 # Optional if you wish to keep your existing Python version for terminal as .python-version will force use Python 3.14 for this specific project

```

**For macOS (Intel or Apple Silicon):**

```bash
brew update
brew install pyenv
pyenv install 3.14.5
pyenv global 3.14.5 # Optional if you wish to keep your existing Python version for terminal as .python-version will force use Python 3.14 for this specific project

```

**🛠 Shell Configuration (Required Once)**

To enable automatic version switching via the `.python-version` file, add the following to your shell profile (`~/.zshrc` for Mac/Zsh or `~/.bashrc` for WSL/Bash):

```bash
# Add this to the end of your ~/.zshrc or ~/.bashrc
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

**After adding the lines**: Restart your terminal or run source ~/.zshrc (or ~/.bashrc).

### 2. Environment Variables

Copy the template and fill in the secrets. **Never commit the `.env` file.**

```bash
cp .env.example .env

```

### 3. Virtual Environment & Dependencies

```bash
python -m venv env
source env/bin/activate  # On Windows/WSL or macOS
pip install -r requirements.txt

```

### 4. Database Initialisation

Ensure the Docker container is running in the root directory, then apply the migrations:

```bash
python manage.py migrate

```

### 5. Create a Super User

To access the Django Admin dashboard, you need to have a super user account. You can create one using Django's CLI tool:

```bash
python manage.py createsuperuser
```

## 🛰 Development & Access

Run the local development server:

```bash
python manage.py runserver

```

- **Mobile API Base**: `http://127.0.0.1:8000/api/`
- **Merchant Dashboard**: `http://127.0.0.1:8000/dashboard/`
- **Django Admin**: `http://127.0.0.1:8000/admin/`
- **API Documentation (Swagger UI)**: `http://127.0.0.1:8000/api/schema/swagger-ui/` (Requires Admin)
- **API Documentation (Redoc)**: `http://127.0.0.1:8000/api/schema/redoc/` (Requires Admin)

---

## 📂 Modular Architecture

All domain logic is located in the `apps/` directory to keep the root clean:

| App              | Responsibility               |
| ---------------- | ---------------------------- |
| **`apps.users`** | Identity and Authentication. |

---

## 🔐 Google Authentication Setup

To enable Google Sign-In for the mobile API, you must configure credentials in both the Google Cloud Console and the local Django Admin dashboard.

### 1. Generate Google Credentials

1. Navigate to the [Google Cloud Console - Create OAuth client ID](https://console.cloud.google.com/auth/clients/create).
2. Create a new **Web application** OAuth client ID (this is required to generate the Client Secret for the backend server).
3. Leave the "Authorized redirect URIs" field empty, as the mobile app fetches and passes the token directly.
4. Copy the newly generated **Client ID** and **Client Secret**.

### 2. Configure Django Admin & Sites

1. With the local development server running, log in to the [Django Admin Dashboard](http://127.0.0.1:8000/admin/) using your superuser account.
2. First, navigate to the Sites section on the main dashboard and click on the default `example.com` record.
3. Change the Domain name to `127.0.0.1:8000` (or localhost:8000) and the Display name to `Mapetite Local`, then click Save.
4. Next, navigate to Social Accounts > Social applications and click Add social application.
5. Set the Provider to `Google`.
6. Enter a name (e.g., "Google OAuth"), then paste your Client ID and Secret key into the respective fields.
7. Scroll down to the Sites box. Highlight `Mapetite Local` in the "Available sites" list on the left, and click the rightward arrow to move it into the Chosen sites box.
8. Click Save.

### 3. Testing the Implementation

If you need to test the authentication API endpoint locally (e.g., via Postman) before the mobile app is integrated, you can generate temporary tokens:

1. Go to the [Google OAuth2 Playground](https://developers.google.com/oauthplayground/).
2. Under "Step 1", scroll to **Google OAuth2 API v2** and select both the `email` and `profile` scopes.
3. Click **Authorize APIs**, sign in with a Google account, and click **Exchange authorization code for tokens** in Step 2.
4. Copy the `access_token` and `id_token`. Send these as the JSON payload in a POST request to the local API endpoint.

---

## ⚠️ Guardrails

- **Python Version**: `manage.py` will block execution if your Python version is not 3.14.x.
- **App Creation**: Always create new apps inside the `apps/` folder:
  `python manage.py startapp name apps/name`
- **CRITICAL**: You must manually update `apps/name/apps.py` so that `name = "apps.name"`.

- **Static/Media**: Store global assets in `/static` and user uploads in `/media`.
