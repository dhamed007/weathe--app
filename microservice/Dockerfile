FROM python:3.10-slim-buster

WORKDIR /app
COPY weather_microservice/requirements.txt .
RUN pip3 install -r requirements.txt

COPY . .

EXPOSE 8080

CMD [ "python3", "weather_microservice/app.py"]
