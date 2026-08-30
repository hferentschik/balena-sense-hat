# Balena Sense HAT

A [balenaCloud](https://www.balena.io/) project using a Raspberry Pi 4 together with a [Sense Hat](https://www.raspberrypi.org/products/sense-hat/).

## Components

- messenger - The messenger container offers a REST API to display messages on the Sense Hat display, for example:

    ```sh
    uuid=$(balena devices | grep <app-name> | awk '{print $2}')
    ip=$(balena device $uuid | grep "IP ADDRESS" | awk -F ':' '{print $2}' | xargs)
    curl -X POST -H "Content-Type: application/json" -d '{"message": "hello world"}' $ip:5000/display
    ```

- sensor - the sensor component reads the sensors of the SenseHat and writes it into an [InfluxDB](https://www.influxdata.com/) database (`balena-sense`).
- dashboard - [Grafana](https://grafana.com/) dashboard displaying the sensor data, reachable at `http://<device-ip>/dash/`.
- influxdb - time-series database backing the dashboard.
- mqtt - [Mosquitto](https://mosquitto.org/) broker (plain `1883` and websockets `9001`) for publishing sensor readings over MQTT. Currently no service in this repo publishes to it.
- telegraf - subscribes to MQTT topics `sensors`/`sensors/#` and would write readings into InfluxDB (`weather` database), independent of the `sensor` -> `balena-sense` path. Idle until something publishes to MQTT.
- nginx - reverse proxy in front of the fleet; routes `/dash/` to the dashboard and everything else to the MQTT websocket listener.

### Deployment

```sh
balena push <app-name>
```

## Development

### Operations

```sh
$ balena fleet sense-hat
== sense-hat
ID:          1796315
DEVICE TYPE: raspberrypi4-64
SLUG:        hardy_ferentschik_balena/sense-hat
COMMIT:      a27e914bdfb5e86132ea9c65eb6f97d3

$ balena device list --fleet sense-hat
balena device list --fleet sense-hat
ID       UUID    DEVICE NAME  DEVICE TYPE     FLEET                              STATUS IS ONLINE SUPERVISOR VERSION OS VERSION           DASHBOARD URL
13656543 a98625b average-bush raspberrypi4-64 hardy_ferentschik_balena/sense-hat Idle   true      17.8.2             balenaOS 7.4.0+rev10 https://dashboard.balena-cloud.com/devices/a98625b1680f74a5fdc697fd9de047c8/summary

device=a98625b
balena device logs $device 
balena device logs $device --service messenger
balena device logs $device --service messenger --tail
balena device ssh $device messenger
balena push sense-hat

# Inspect device-specific host config variables (e.g. dtoverlay, dtparam)
balena env list --device $device --config
```

`balena device ssh` targeting a device by UUID only works for the host OS shell, not individual service
containers. To SSH into a specific service (e.g. to inspect files live), target the device by local
IP or `.local` address instead, and pipe the command through stdin rather than passing it as a trailing
argument:

```sh
echo "cat /etc/some-file" | balena device ssh 192.168.86.212 messenger
```

### Testing the messenger API

```sh
curl -X POST -H "Content-Type: application/json" -d '{"message": "hello"}' http://<device-ip>:5000/display
```

If nothing appears on the LED matrix, see [Troubleshooting](#troubleshooting) below.

### Troubleshooting

- **LED matrix stuck on / `sensor` and `messenger` crash-looping with `OSError: Cannot detect RPi-Sense FB device`**
  The Raspberry Pi kernel needs the `rpi-sense` device-tree overlay to expose the Sense HAT's LED matrix as a
  framebuffer device. Check the device's `dtoverlay` host config variable and make sure `rpi-sense` is included
  alongside any other overlays (e.g. `vc4-kms-v3d,cma-320`), then reboot the device:

    ```sh
    balena env list --device $device --config
    balena env rename <VAR_ID> '"vc4-kms-v3d,cma-320","rpi-sense"' --device --config
    balena device reboot $device
    ```

- **Dashboard panels are empty**
  The Grafana `InfluxDB` datasource must point at the `balena-sense` database (the one `sensor` actually writes
  to — not `balena`, which is only created empty via the `influxdb` container's `INFLUXDB_DB` env var). Each
  panel in `dashboard.json` must also reference the datasource by its exact configured name (`InfluxDB`).

### Executing code in container

In order to test the code easily, the container uses a trick to allow using [PyCharm](https://www.jetbrains.com/pycharm/) locally and execute the code in the remote container.
For that the container needs to open an SSH port.
This can be achieved setting the device service variable `START_SSHD=1`.
This will start sshd and allow PyCharm to use the container as a remote execution environment.
