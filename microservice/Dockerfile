FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app
COPY app/requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 8080 to the outside world
EXPOSE 8080

# Define environment variable
ENV FLASK_APP main.py

# Run app.py when the container launches
CMD ["flask", "run", "--host=0.0.0.0", "--port=8080"]