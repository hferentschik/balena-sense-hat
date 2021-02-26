import time
from sense_hat import SenseHat
from influxdb import InfluxDBClient

influx_client = InfluxDBClient('influxdb', 8086, database='balena-sense')
influx_client.create_database('balena-sense')

sense = SenseHat()

while 1:
    measurements = [
        {
            'measurement': 'temperature',
            'fields': {
                'value': float(sense.temperature)
            }
        }
    ]

    measurements.extend([
        {
            'measurement': 'humidity',
            'fields': {
                'value': float(sense.humidity)
            }
        }
    ])

    measurements.extend([
        {
            'measurement': 'pressure',
            'fields': {
                'value': float(sense.pressure)
            }
        }
    ])

    influx_client.write_points(measurements)
    time.sleep(10)
