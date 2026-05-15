# Mapetite Backend & Web Engine ⚙️

The core engine for Mapetite. This project serves the **JSON API** for the mobile client, the **Merchant Web Dashboard**, and the project **Landing Pages**.

## 🛠 Prerequisites

* **Python 3.14.x**: We enforce a strict version guardrail to ensure environment parity across the team.
* **Database**: PostgreSQL 18 (Managed via the root `docker-compose.yml`).

## 📥 Local Setup

### 1. Install Python 3.14
Depending on your operating system, use one of the following methods:

**For WSL (Ubuntu) / Linux:**
```bash
# Install build dependencies, then:
curl [https://pyenv.run](https://pyenv.run) | bash
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

* **Mobile API Base**: `http://127.0.0.1:8000/api/`
* **Merchant Dashboard**: `http://127.0.0.1:8000/dashboard/`
* **Django Admin**: `http://127.0.0.1:8000/admin/`

---

## 📂 Modular Architecture

All domain logic is located in the `apps/` directory to keep the root clean:

| App | Responsibility |
| --- | --- |
| **`apps.users`** | Identity and Authentication. |

## ⚠️ Guardrails

* **Python Version**: `manage.py` will block execution if your Python version is not 3.14.x.
* **App Creation**: Always create new apps inside the `apps/` folder:
`python manage.py startapp name apps/name`
  * **CRITICAL**: You must manually update `apps/name/apps.py` so that `name = "apps.name"`.
* **Static/Media**: Store global assets in `/static` and user uploads in `/media`.

