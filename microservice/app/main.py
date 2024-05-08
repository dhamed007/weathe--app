from flask import Flask, jsonify, request
import requests
import pandas as pd
import openmeteo_requests
import requests_cache
from retry_requests import retry

app = Flask(__name__)

# Open-Meteo API client setup
openmeteo = openmeteo_requests.Client(session=requests.Session())

@app.route('/weather')
def get_weather():
    location = request.args.get('location')
    if not location:
        return jsonify({'error': 'Location parameter is required'}), 400

    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "location": location,
        "hourly": "temperature_2m"
    }

    try:
        responses = openmeteo.weather_api(url, params=params)
        response = responses[0]  # Assuming you want the first response
        hourly = response.Hourly()
        hourly_temperature_2m = hourly.Variables(0).ValuesAsNumpy()

        hourly_data = {
            "date": pd.date_range(
                start=pd.to_datetime(hourly.Time(), unit="s", utc=True),
                end=pd.to_datetime(hourly.TimeEnd(), unit="s", utc=True),
                freq=pd.Timedelta(seconds=hourly.Interval()),
                inclusive="left"
            ).tolist(),
            "temperature_2m": hourly_temperature_2m.tolist()
        }

        return jsonify(hourly_data)

    except Exception as e:
        return jsonify({'error': f'Failed to fetch weather data: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)