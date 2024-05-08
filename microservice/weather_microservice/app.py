import requests
from geopy.geocoders import Nominatim
import geocoder
import openmeteo_requests

import requests_cache
import pandas as pd
from retry_requests import retry



def get_coordinates(location):

    #geolocator = Nominatim(user_agent="MyApp")
    coordinates = geolocator.geocode(location)
    return coordinates


def get_weather(coordinates):
    # Setup the Open-Meteo API client with cache and retry on error
    cache_session = requests_cache.CachedSession('.cache', expire_after = 3600)
    retry_session = retry(cache_session, retries = 5, backoff_factor = 0.2)
    openmeteo = openmeteo_requests.Client(session = retry_session)

    # Make sure all required weather variables are listed here
    # The order of variables in hourly or daily is important to assign them correctly below
    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "latitude": coordinates.latitude,
        "longitude": coordinates.longitude,
        
    "current": ["temperature_2m", "relative_humidity_2m", "apparent_temperature", "is_day", "precipitation", "rain", "showers", "snowfall", "cloud_cover", "surface_pressure", "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m"],
    "forecast_days": 1
    }
    responses = openmeteo.weather_api(url, params=params)

    # Process first location. Add a for-loop for multiple locations or weather models
    response = responses[0]
    print(f"Coordinates {response.Latitude()}°N {response.Longitude()}°E")
    print(f"Elevation {response.Elevation()} m asl")
    print(f"Timezone {response.Timezone()} {response.TimezoneAbbreviation()}")
    print(f"Timezone difference to GMT+0 {response.UtcOffsetSeconds()} s")

    # Current values. The order of variables needs to be the same as requested.
    current = response.Current()
    current_temperature_2m = current.Variables(0).Value()
    current_relative_humidity_2m = current.Variables(1).Value()
    current_apparent_temperature = current.Variables(2).Value()
    current_is_day = current.Variables(3).Value()
    current_precipitation = current.Variables(4).Value()
    current_rain = current.Variables(5).Value()
    current_showers = current.Variables(6).Value()
    current_snowfall = current.Variables(7).Value()
    current_cloud_cover = current.Variables(8).Value()
    current_surface_pressure = current.Variables(9).Value()
    current_wind_speed_10m = current.Variables(10).Value()
    current_wind_direction_10m = current.Variables(11).Value()
    current_wind_gusts_10m = current.Variables(12).Value()

    print(f"Current time {current.Time()}")
    print(f"Current temperature_2m {current_temperature_2m}")
    print(f"Current relative_humidity_2m {current_relative_humidity_2m}")
    print(f"Current apparent_temperature {current_apparent_temperature}")
    print(f"Current is_day {current_is_day}")
    print(f"Current precipitation {current_precipitation}")
    print(f"Current rain {current_rain}")
    print(f"Current showers {current_showers}")
    print(f"Current snowfall {current_snowfall}")
    print(f"Current cloud_cover {current_cloud_cover}")
    print(f"Current surface_pressure {current_surface_pressure}")
    print(f"Current wind_speed_10m {current_wind_speed_10m}")
    print(f"Current wind_direction_10m {current_wind_direction_10m}")
    print(f"Current wind_gusts_10m {current_wind_gusts_10m}")




if __name__ == "__main__":
    location = input("Enter the location: ")
    coordinates = get_coordinates(location)
    get_weather(coordinates)