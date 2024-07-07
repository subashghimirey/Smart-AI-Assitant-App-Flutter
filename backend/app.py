from flask import Flask, request, jsonify
import requests
from flask_cors import CORS  # Import CORS

app = Flask(__name__)
CORS(app)  # Initialize CORS for the entire app

API_KEY = 'lmwr_sk_yLnA2MkV7t_LSVwhsVeS9mjKSiFdqQ8FRsCcX8LQ3VnL6fH1'  # Replace with your actual API key

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
            return data
        else:
            print(f"Error: {response.status_code}")
            print(response.json())
            return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

@app.route('/generate-image', methods=['POST'])
def generate_image_route():
    data = request.get_json()
    prompt = data.get('prompt')
    if not prompt:
        return jsonify({"error": "No prompt provided"}), 400

    result = generate_image(prompt, API_KEY)
    if result:
        image_url = result.get('data', [])[0].get('asset_url')
        if image_url:
            return jsonify({"image_url": image_url}), 200
        else:
            return jsonify({"error": "Generated image URL not found in the response."}), 500
    else:
        return jsonify({"error": "Failed to generate image"}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)  # Run on port 5000
