import json


def extract_recipe_data(request, serializer_class):
    data = {key: value for key, value in request.data.items()}

    json_parsing_errors = {}

    for field in ["ingredients", "steps"]:
        if field in data and isinstance(data[field], str):
            try:
                data[field] = json.loads(data[field])
            except json.JSONDecodeError:
                nested_serializer = serializer_class.fields[field].child
                expected_keys = list(nested_serializer.fields.keys())
                keys_string = ", ".join(f"'{k}'" for k in expected_keys)

                json_parsing_errors[field] = [
                    f"Invalid JSON format. Expected an array of objects containing keys: {keys_string}."
                ]

    return data, json_parsing_errors
