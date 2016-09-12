# Cultivatarmobile

_The Cultivate Robot_, aka _The Cultivtormobile_, is a fun project to get started in developing hardware applications using [Nerves](https://github.com/nerves-project/nerves) - the embedded Elixir project. The project gives you a small buggy, powered by two (admittedly slow) Stepper motors which can be controlled directly over a web interface or via [Slack](https://slack.com).

Kits are to be given as prizes at [Elixir London 2016](http://www.elixir.london), but you can fairly easily build your own.

## Parts

A pictorial representation of the parts is [here](docs/robot_parts_sheet.pdf) Here are the electronic parts with some UK sources, though bear in mind that stock can vary per supplier and URLs can change.

| Part | Available from |
|------|----------------|
| Pi Zero (only) | PI Hut: https://thepihut.com/products/raspberry-pi-zero?variant=14062715972, or Pimoroni: https://shop.pimoroni.com/products/raspberry-pi-zero/ Note that stocks are limited to one per customer. |
| WiFi dongle | eg https://thepihut.com/products/usb-wifi-adapter-for-the-raspberry-pi or https://thepihut.com/products/coloured-male-40-pin-2x20-hat-headers |
| 40-pin 2x20 male headers for the Gpio | https://shop.pimoroni.com/products/male-40-pin-2x20-hat-header |
| USB to micro USB adaptor | This USB to microUSB OTG Converter Shim from The PI Hut is great: https://thepihut.com/products/usb-to-microusb-otg-converter-shim |
| Female / Female jumper cables | At least 10, eg from https://www.amazon.co.uk/gp/product/B00OL6JZ3C/ |
| 5v power bank (portable phone charger) | Something like https://www.amazon.co.uk/gp/product/B00VJS9R4C. They should come with a USB to micro USB cable to connect to the PI | 
| Micro SD card, at least 4GB | Bigger is ok. eg https://www.amazon.co.uk/Kingston-8GB-Micro-SD-HC/dp/B001CQT0X4/ |
| 2 x 28Byj steppe motors with ULN2003 controllers | eg 5 pieces from here https://www.amazon.co.uk/gp/product/B00SSQAITQ | 
| Battery for stepper motors | For the giveaway we a used battery holder for 4 AA batteries, https://www.amazon.co.uk/gp/product/B00XHQ18DW. You need to provide between 5v and 12v to the steppers |

## Soldering

Yeah, there's no way round it. This requires a bit of soldering.
