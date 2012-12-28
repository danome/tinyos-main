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
  App.AMSend -> SerialActiveMessageC.AMSend[AM_SUM_MSG];   //串口发送数据
  App.Receive -> ActiveMessageC.Receive[AM_TEMPERATURE_MSG];       //无线接受数据
  App.RadioControl -> ActiveMessageC;       //开启无线电通信
  App.SerialControl -> SerialActiveMessageC;   //开启串口通信
   

  components new CC2420SpiC() as Spi;
  App.CC2420Register -> Spi.CC2420Register;
  App.CC2420Strobe -> Spi.CC2420Strobe;
}
