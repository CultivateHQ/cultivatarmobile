# Cultivatarmobile

_The Cultivate Robot_, aka _The Cultivatarmobile_, is a fun project to get started in developing hardware applications using [Nerves](https://github.com/nerves-project/nerves) - the embedded Elixir project. The project gives you a small buggy, powered by two (admittedly slow) Stepper motors which can be controlled directly over a web interface or via [Slack](https://slack.com).

Kits are to be given as prizes at [Elixir London 2016](http://www.elixir.london), but you can fairly easily build your own.

## Parts

A pictorial representation of the parts is [here](docs/robot_parts_sheet.pdf). Here are the electronic parts with some UK sources, though bear in mind that stock can vary per supplier and URLs can change.

| Part | Available from |
|------|----------------|
| Pi Zero (only) | PI Hut: https://thepihut.com/products/raspberry-pi-zero?variant=14062715972, or Pimoroni: https://shop.pimoroni.com/products/raspberry-pi-zero/ Note that stocks are limited to one per customer. |
| WiFi dongle | eg https://thepihut.com/products/usb-wifi-adapter-for-the-raspberry-pi, https://shop.pimoroni.com/products/official-raspberry-pi-wifi-dongle |
| 40-pin 2x20 male headers for the Gpio | https://shop.pimoroni.com/products/male-40-pin-2x20-hat-header |
| USB to micro USB adaptor | This USB to microUSB OTG Converter Shim from The PI Hut is great: https://thepihut.com/products/usb-to-microusb-otg-converter-shim |
| Female / Female jumper cables | At least 10, eg from https://www.amazon.co.uk/gp/product/B00OL6JZ3C/ |
| 5v power bank (portable phone charger) | Something like https://www.amazon.co.uk/gp/product/B00VJS9R4C. They should come with a USB to micro USB cable to connect to the PI | 
| Micro SD card, at least 4GB | Bigger is ok. eg https://www.amazon.co.uk/Kingston-8GB-Micro-SD-HC/dp/B001CQT0X4/ |
| 2 x 28Byj stepper motors with ULN2003 controllers | eg 5 pieces from here https://www.amazon.co.uk/gp/product/B00SSQAITQ | 
| Battery for stepper motors | For the giveaway we a used battery holder for 4 AA batteries, https://www.amazon.co.uk/gp/product/B00XHQ18DW. You need to provide between 5v and 12v to the steppers |

Of course you do not have to use a PI Zero. Any PI (or other supported Nerves target) should work. You may need to slightly modify `apps/fw/mix.exs`for other targets.


## Soldering

PI Zeros come without a means of securely attaching wires to the [GPIO](https://en.wikipedia.org/wiki/General-purpose_input/output) which is used to control the motors. If you use a PI Zero, then you'll want to solder on some GPIO headers. Here is one video on how to do it: https://www.youtube.com/watch?v=MSGIrtGMYRM

Another thing you will probably need to solder is the connection from the batteries to the power input of the ULN2003 stepper motor controller. We suggest connecting each the positive and ground to two female-ended jumper cables. See the illustration of the battery case in [the parts illustration](docs/robot_parts_sheet.pdf).

## Chassis

We used Lego to build the chassis, connecting the power bank and PI by attaching Lego to them with [Sugru](https://sugru.com). We will publish a list of bricks at some point. All you need is a container to which you can attach the two wheels and to hold the rest of the parts. Something low friction for the back is useful too.

## Connecting the drive together

1. Connect each of the stepper motors to the ULN2003 controllers; the connection is obvious and will only be connectable in one direction. Depending on your chassis, you may want to cable tie the motors back to back.
1. Connect the ULN2003 controllers to the raspberry PI. Refer to a pin map such as [this from Element 14](https://www.element14.com/community/docs/DOC-73950/l/raspberry-pi-3-model-b-gpio-40-pin-block-pinout); the SD card on the PI zero is at the top of the map. The actual pin mapping is changeable in [the configuration](master/apps/cb_locomotion/config/config.exs), but the default configured mapping is
    * GPIO  6 to IN1 on the left ULN2003 controller
    * GPIO 13 to IN2 on the left ULN2003 controller
    * GPIO 19 to IN3 on the left ULN2003 controller
    * GPIO 26 to IN4 on the left ULN2003 controller
    * GPIO 12 to IN1 on the right ULN2003 controller
    * GPIO 16 to IN1 on the right ULN2003 controller
    * GPIO 20 to IN1 on the right ULN2003 controller
    * GPIO 21 to IN1 on the right ULN2003 controller
1. Connect the positive (marked '+') pins on both ULN2003 controller to the positive terminal of the battery case.
1. Connect the negative (marked '-') pins on both ULN2003 controller to the negative terminal of the battery case.

Note that some motors appear to be wired in reverse; if you find one (or two) going the opposite way to expected then simply reverse the wiring to the controller.

## Configuration

You will need to add a Slack token for your Slackbot, and set the SSID and password for your WiFi network.

```
cp apps/cb_slack/config/secret.example.exs apps/cb_slack/config/secret.exs 
cp apps/fw/config/secret.example.exs apps/fw/config/secret.exs 
```

Create a Slack [Bot User](https://api.slack.com/bot-users) and replace the placeholder in`apps/cb_slack/config/secret` with the bot user's token.

Replace the placeholders in `apps/fw/config/secret.exs` with the details of your Wifi network.

## Building on your machine and testing

In a slight departure from normal [Nerves](https://github.com/nerves-project/nerves) practice, all the applications in the umbrella project are configured to be run on a host machine (such as a Mac) in `dev` and `test` modes. Building for the firmware image must be done with `MIX_ENV` set to `prod`.

From the Umbrella application route you should be able to run.

```
mix test
```

All the tests should pass. You can also run tests for each umbrella application in that applications directory.

You can also run

```
iex -S mix
```

Your Slack Bot User should connect to your slack. You can say "cultivate help" in a channel to which your user has been invited, to receive the help message. Navigating to http://localhost:4000 should bring up the web interface.

## Deploying to your PI Zero

Ensure that you are set up and up to date for Nerves environment by following the instructions [here](https://hexdocs.pm/nerves/installation.html)

```
cd apps/fw
MIX_ENV=prod mix compile
MIX_ENV=prod mix firmware
```
Ensure your SD card is inserted to an attached SD card writer.

```
MIX_ENV=prod mix firmware.burn
```

Insert the SD card to the PI. If all has gone well, then booting the PI should connect to your network and Slack.

## The Code Structure

This is an [Umbrella project](http://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-apps.html) containing the applications below. More details of each project may be in the project's README file.

### [`fw`](apps/fw)

This is the "master application" used to make the firmware releases. At the time of writing, Nerves uses [Exrm](https://github.com/bitwalker/exrm) to produce releases, and the Exrm convention is to have an application from which to build them. It is not an entirely dumb application; it is responsible for:

* networking, ie connecting to WiFi
* setting the time via [NTP](https://en.wikipedia.org/wiki/Network_Time_Protocol)
* somewhat insecurely, making this Cultivatormobile instance a distributed Erlang node, with the name "CultivatarMobile@[IPV4 address]".

### [`cb_locomotion`](apps/cb_locomotion)

Controls the stepper motors, through the named `GenServer` [`CbLocomotion.Locomotion`](apps/cb_locomotion/lib/cb_locomotion/locomotion.ex).

### [`cb_slack`](apps/cb_slack)

Provides the [Slack](https://slack.com) interface to the Cultivtormobile. Remember to set your Slack token in `apps/cb_slack/config/secret.exs` (see configuration instructions above.)

### [`cb_web`](apps/cb_web)

Provides the web interface to the robot. It listens on port 80 in production (on the device) and port 4000 in development mode.

### ['dummy_nerves'](apps/dummy_nerves)

Provides fake versions of hardware specific code in development and test. This allows compilation on non-linux host environments, and (in the case of GPIO) ways of checking value changes in tests.

