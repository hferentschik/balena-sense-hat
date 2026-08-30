# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

A Balena Cloud IoT application running on a Raspberry Pi with a SenseHat extension.

See README.md for the general project/component overview and human-facing dev/ops instructions. This file
only covers additional context useful for an agent working on this repo.

## Architecture notes

- There are two independent paths from sensor to storage:
  - `sensor` (measure.py) writes directly to InfluxDB database `balena-sense` via the Python InfluxDB client.
  - `telegraf` subscribes to MQTT topics published by... (nothing currently publishes to MQTT in this repo —
    `mqtt`/`telegraf` are wired up and running but there is no producer service publishing sensor readings to
    MQTT topics `sensors`/`sensors/#`) and writes to InfluxDB database `weather`.
  - The `influxdb` container's `INFLUXDB_DB=balena` env var creates a third, empty `balena` database at init
    time — this is a decoy database name that doesn't get any real data. Don't assume it's the one to query.
- The Grafana `dashboard.json` panels reference their datasource by name (`"datasource": "InfluxDB"`). This
  must exactly match the name of a datasource configured in Grafana (via the API or provisioning) — a mismatch
  produces panels that render with no error message, just no data. Similarly, a datasource pointed at the wrong
  InfluxDB database produces the same silent-empty-panel symptom.
- `dashboard/dashboards.yml` sets `updateIntervalSeconds: 10` — Grafana re-applies the on-disk provisioned
  `dashboard.json` every 10s, overwriting any in-place API edits. When live-patching a running container for a
  quick fix, also patch the file on disk (or the fix reverts within 10 seconds).
- The Sense HAT LED matrix only appears as a framebuffer device (`/dev/fb1`, "RPi-Sense FB") if the device's
  `dtoverlay` host config variable includes `rpi-sense`. Without it, `SenseHat()` raises
  `OSError: Cannot detect RPi-Sense FB device` at import time in both `sensor` and `messenger` — since this
  happens before `sense.clear()` runs, the LED matrix gets stuck showing whatever was last rendered (often
  fully lit), and both containers crash-loop. This is a device-level config var
  (`RESIN_HOST_CONFIG_dtoverlay` / `BALENA_HOST_CONFIG_dtoverlay`), not an application env var — check with
  `balena env list --device <device> --config`.

## balena CLI quirks

- `balena device ssh <uuid> <service>` does not work reliably for per-service shells when targeting by UUID.
  Target by the device's local IP (or `.local` address) instead, and pipe commands through stdin rather than
  passing them as a trailing argument (trailing-argument invocation is unreliable for service containers):
  `echo "<command>" | balena device ssh <local-ip> <service>`.
- `balena device logs` without `--tail` prints a snapshot of recent logs and exits; it does not stream. For
  streaming use `--tail`, but avoid backgrounding it with manual sleep/kill loops — prefer a bounded
  `timeout <n> balena device logs <uuid> --tail`.
- `balena push` does not deploy a release if any service fails to build — a failed push leaves the
  previously-deployed release running untouched on the device. Always check the push output for
  `Some services failed to build` / `Not deploying release` rather than assuming a non-crashing CLI invocation
  means the new release is live.

## Base image / dependency gotchas

- Base images for `sensor`/`messenger` were bumped from `balenalib/raspberrypi4-64:buster` (EOL) to
  `:bookworm`. Bookworm's `pip3` enforces PEP 668 ("externally-managed-environment") and refuses a plain
  `pip3 install` outside a virtualenv — both Dockerfiles' `pip3 install -r requirements.txt` needed
  `--break-system-packages` added after the base image bump.
- RTIMULib (built from source via `setup.py build`/`install` in both Dockerfiles) still works on bookworm's
  Python 3.11, which retains (deprecated) `distutils`. Re-verify if bumping to a Python version that drops it.
- The Grafana base image (`balenablocks/dashboard:raspberrypi4-64`, Grafana 7.1.3) has intentionally **not**
  been upgraded — a major-version bump would require rewriting `dashboard.json`'s legacy Angular "graph" panel
  types to the modern "timeseries" panel, risking the dashboard-data regression that was just fixed. Treat this
  as a deliberately deferred, separate task, not an oversight.
