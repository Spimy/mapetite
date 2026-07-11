import time
from google.genai import types
from django.core.management.base import BaseCommand
from apps.core.services import GeminiService
from apps.merchants.models import StoreItem


class Command(BaseCommand):
    help = "Generates Gemini vector embeddings for seeded StoreItems"

    def handle(self, *args, **kwargs):
        # Target: 100 RPM = 1.66 requests per second
        # Aim for 1.5 requests per second (approx 0.65s delay) to be safe
        REQUESTS_PER_MINUTE = 95  # Giving a safety buffer
        DELAY_BETWEEN_REQUESTS = 60 / REQUESTS_PER_MINUTE

        # Find all items that don't have an embedding yet
        items_to_process = StoreItem.objects.filter(embedding__isnull=True)
        total_items = items_to_process.count()

        if total_items == 0:
            self.stdout.write(self.style.SUCCESS("All items already have embeddings!"))
            return

        self.stdout.write(
            self.style.WARNING(
                f"Found {total_items} items missing embeddings. Starting AI generation..."
            )
        )

        client = GeminiService.get_client()

        # Loop through and process them
        success_count = 0
        for item in items_to_process:
            start_time = time.time()

            try:
                # Embed the item metadata (name, description, category) into a vector
                text_to_embed = (
                    item.name
                    + " "
                    + (item.description or "")
                    + (item.category.name if item.category else "")
                ).strip()

                response = client.models.embed_content(
                    model="gemini-embedding-2",
                    contents=text_to_embed,
                    config=types.EmbedContentConfig(output_dimensionality=768),
                )

                # Extract the vector array
                assert response.embeddings is not None
                vector = response.embeddings[0].values

                # Save it to the database
                item.embedding = vector
                item.save(update_fields=["embedding"])

                success_count += 1
                self.stdout.write(
                    self.style.SUCCESS(f"Successfully embedded: {item.name}")
                )

            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(f"Failed to embed {item.name}: {str(e)}")
                )
                time.sleep(5)  # Short pause before retrying the next item
                continue

            # Prevent hitting the Gemini Free Tier Rate Limit (100 Requests Per Minute)
            # Pause briefly between API calls.
            elapsed = time.time() - start_time
            if elapsed < DELAY_BETWEEN_REQUESTS:
                time.sleep(DELAY_BETWEEN_REQUESTS - elapsed)

        self.stdout.write(
            self.style.SUCCESS(
                f"\nDone! Successfully generated {success_count}/{total_items} embeddings."
            )
        )
