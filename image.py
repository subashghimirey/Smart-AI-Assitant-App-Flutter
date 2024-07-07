import requests
import json

api_key =     'lmwr_sk_yLnA2MkV7t_LSVwhsVeS9mjKSiFdqQ8FRsCcX8LQ3VnL6fH1'

def generate_image(prompt, api_key):
    url = "https://api.limewire.com/api/image/generation"
    
    payload = {
        "prompt": prompt,
        "aspect_ratio": "1:1"
    }
    
    headers = {
        "Content-Type": "application/json",
        "X-Api-Version": "v1",
        "Accept": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    
    try:
        response = requests.post(url, json=payload, headers=headers)
        
        if response.status_code == 200:
            data = response.json()
            print(json.dumps(data, indent=2))  # Pretty print the JSON response
            return data
        else:
            print(f"Error: {response.status_code}")
            print(response.json())
            return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

# Example usage
prompt = "A cute baby sea otter"
api_key = api_key  # Replace with your actual API key

data = generate_image(prompt, api_key)

if data:
    # Extract the URL of the generated image if present in the response
    image_url = data.get('data', [])[0].get('asset_url')
    if image_url:
        print(f"Generated Image URL: {image_url}")
    else:
        print("Generated image URL not found in the response.")
