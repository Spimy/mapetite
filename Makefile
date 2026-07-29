# Makefile

# Run migrations
mm:
	docker compose exec web python manage.py makemigrations

migrate:
	docker compose exec web python manage.py migrate

createsuperuser:
	docker compose exec web python manage.py createsuperuser

seed-merchants:
	docker compose exec web python manage.py loaddata fixtures/merchants.json

seed-recipes:
	docker compose exec web python manage.py loaddata fixtures/recipes.json

seed: seed-merchants seed-recipes

generate-embeddings:
	docker compose exec web python manage.py generate_embeddings

# Open a python shell inside the container
shell:
	docker compose exec web python manage.py shell

# Jump inside the container's terminal as root
bash:
	docker compose exec web bash

# Flutter commands
flutter-run:
	cd mobile-client && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080