# Balena Sense

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

### Executing code in container

In order to test the code easily, the container uses a trick to allow using [PyCharm](https://www.jetbrains.com/pycharm/) locally and execute the code in the remote container.
For that the container needs to open an SSH port.
This can be achieved setting the device service variable `START_SSHD=1`.
This will start sshd and allow PyCharm to use the container as a remote execution environment.

*NOTE*: This is a development trick/hack.
In a production environment the sshd config should be removed.
