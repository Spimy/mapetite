# Makefile

# Run migrations
mm:
	docker compose exec web python manage.py makemigrations

migrate:
	docker compose exec web python manage.py migrate

createsuperuser:
	docker compose exec web python manage.py createsuperuser

# Open a python shell inside the container
shell:
	docker compose exec web python manage.py shell

# Jump inside the container's terminal as root
bash:
	docker compose exec web bash