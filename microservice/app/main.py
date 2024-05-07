from flask import Flask, jsonify
import requests

app = Flask(__name__)

@app.route('/weather/<location>')
def get_weather(location):
    api_key = 'your_open_meteo_api_key'
    url = f'https://api.open-meteo.com/v1/forecast?location={location}&key={api_key}'
    response = requests.get(url)
    data = response.json()
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)