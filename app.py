from flask import Flask, jsonify
import requests
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from apscheduler.schedulers.background import BackgroundScheduler
import logging

app = Flask(__name__)

# Configuring the database
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///health_data.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize the database
db = SQLAlchemy(app)

# Define the database model
class HealthData(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    bpm = db.Column(db.Float, nullable=False)  # Heart rate
    spo2 = db.Column(db.Float, nullable=False)  # Oxygen saturation
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

    def repr(self):
        return f'<HealthData {self.bpm} bpm, {self.spo2} %>'

# Function to request sensor data from ESP8266
def request_data_from_arduino():
    try:
        # Replace with the IP address of the ESP8266
        esp8266_ip = 'http://192.168.137.217'  # Ensure this is the correct IP of your ESP8266
        esp8266_port = 80  # Port for the ESP8266 server

        # Sending the GET request to ESP8266 at the root ("/") endpoint
        url = f'{esp8266_ip}:{esp8266_port}/'
        response = requests.get(url, timeout=2)  # Reduce the timeout to 2 seconds

        if response.status_code == 200:
            data = response.json()  # Get the JSON response from the Arduino
            bpm = data['heart_rate']
            spo2 = data['SpO2']

            # Use app context when interacting with the database
            with app.app_context():
                # Create new record in the database
                new_data = HealthData(bpm=bpm, spo2=spo2)
                db.session.add(new_data)
                db.session.commit()

            print("Data retrieved and stored:", bpm, spo2)  # Print to console for debugging

        else:
            print("Failed to retrieve data from Arduino", response.status_code)

    except requests.exceptions.Timeout:
        print("Request to ESP8266 timed out")
    except requests.exceptions.ConnectionError:
        print("Connection error to ESP8266")
    except Exception as e:
        print("Error:", str(e))

# Route to retrieve all stored data
@app.route('/data', methods=['GET'])
def get_data():
    data = HealthData.query.all()
    result = []
    for entry in data:
        result.append({
            "id": entry.id,
            "bpm": entry.bpm,
            "spo2": entry.spo2,
            "timestamp": entry.timestamp
        })
    return jsonify(result), 200

# Start the background scheduler
if __name__ == '__main__':
    with app.app_context():  # Wrap db.create_all() in app context
        db.create_all()  # Create the database tables

    # Add job to scheduler with increased max_instances
    scheduler = BackgroundScheduler()
    scheduler.add_job(request_data_from_arduino, 'interval', seconds=1, max_instances=2)  # Increase max_instances
    scheduler.start()
    app.run(debug=True)
