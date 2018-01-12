# Device-TPLink
Control TP-Link smart home products using Perl

Device::TPLink is a collection of modules designed to make it easy to control TP-Link's family of smart home products with Perl. They should support all devices that are supported by the Kasa cloud service, but as of now I have only been able to test with the HS200(US) smart light switch and the HS105(US) mini smart plug. If you are on the same LAN as the device (or can reach the device with a TCP connection, you can send commands directly to the device, otherwise you will need to get a token from the Kasa service and interact with the device through the cloud.

This is the first module I've written in many moons and the first that I've thought was worth submitting to CPAN. Before submitting, the module needs to be cleaned up. Right now the POD documentation is largely boilerplate from the module-starter script, and tests need to be written. That said, you can turn lights on and off with this thing right now,

I am not associated with TP-Link in any way, except as a user of their products. The TP-Link protocol information came from several sources, including the "IT Nerd Space" blog, softScheck's "tplink-smartplug" project on GitHub, and GadgetReactor's "pyHS100" project on GitHub.

Feedback is appreciated. I guess that's obvious, since I'm posting here...
