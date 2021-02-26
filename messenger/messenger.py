from flask import Flask
from flask import request
from sense_hat import SenseHat

sense = SenseHat()

sense.set_rotation(180)
sense.clear()

app = Flask(__name__)


@app.route('/')
def hello_world():
	return 'Hello, World!'


@app.route('/display', methods=['POST'])
def display():
	data = request.get_json()
	message = data['message']
	app.logger.warn("displaying %s", message)
	sense.show_message(message)
	return 'displayed'
