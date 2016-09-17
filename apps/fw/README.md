# Fw

Master app from which Firmware images are build. Also

* sets up WiFi using [Nerves Interim Wifi](https://github.com/nerves-project/nerves_interim_wifi)
* the time with [NTP](lib/fw/ntp.ex)
* Registers as a named node, with the name CultivatarMobile@[Assigned IPv4 IP address]


## Configuration

```
cp config/secret.exs.example config/secret.exs
```

Replace the placeholders with your WiFi details.


## Building the firmware image and burning

See the [Umbrella project README](../../README.md). Note that this must all be done with `MIX_ENV=prod`

## Note about being insecure

The distributed node is great for remote shelling with iEX and looking at the process with Obseerver, but it is very insecure. Be aware of this

Todo: more about its insecurity, how to disable, and how to remsh.
