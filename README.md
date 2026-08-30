# Balena Sense HAT

A [balenaCloud](https://www.balena.io/) project using a Raspberry Pi 4 together with a [Sense Hat](https://www.raspberrypi.org/products/sense-hat/).

## Components

- messenger - The messenger container offers a REST API to display messages on the Sense Hat display, for example:

    ```sh
    uuid=$(balena devices | grep <app-name> | awk '{print $2}')
    ip=$(balena device $uuid | grep "IP ADDRESS" | awk -F ':' '{print $2}' | xargs)
    curl -X POST -H "Content-Type: application/json" -d '{"message": "hello world"}' $ip:5000/display
    ```

- sensor - the sensor component reads the sensors of the SenseHat and writes it into a [InfluxDB](https://www.influxdata.com/) database.
- dashboard - [Grafana](https://grafana.com/) dashboard displaying the sensor data.

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

### Executing code in container

In order to test the code easily, the container uses a trick to allow using [PyCharm](https://www.jetbrains.com/pycharm/) locally and execute the code in the remote container.
For that the container needs to open an SSH port.
This can be achieved setting the device service variable `START_SSHD=1`.
This will start sshd and allow PyCharm to use the container as a remote execution environment.
