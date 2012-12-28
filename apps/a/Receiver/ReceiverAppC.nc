#include "IEEE802154.h"


configuration ReceiverAppC{}
implementation{
  components MainC, LedsC;
  components ReceiverC as App;
  components ActiveMessageC;
  components SerialActiveMessageC;

  App.Boot -> MainC.Boot;
  App.Leds ->LedsC.Leds;
  App.Packet -> SerialActiveMessageC;
  App.AMSend -> SerialActiveMessageC.AMSend[AM_SUM_MSG];
  App.Receive -> ActiveMessageC.Receive[AM_TEMPERATURE_MSG];
  App.RadioControl -> ActiveMessageC;
  App.SerialControl -> SerialActiveMessageC;

  components new CC2420SpiC() as Spi;
  App.CC2420Register -> Spi.CC2420Register;
  App.CC2420Strobe -> Spi.CC2420Strobe;
}
