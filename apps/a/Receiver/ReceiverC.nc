#include "Message.h"
#define DESTINATION_ADDR 2  

module ReceiverC{
  uses {
    interface Boot;
    interface Leds;
    interface Packet;
    interface AMSend;
    interface Receive;
    interface SplitControl as RadioControl;
    interface SplitControl as SerialControl;
    interface CC2420Register as MANOR;
    interface CC2420Register as TOPTST;
    interface CC2420Register as MDMCTRL1;
    interface CC2420Register as DACTST;
    interface CC2420Strobe   as STXON;
  }
}

implementation {

  bool busy; 
  message_t pkt;
  uint16_t  sum=0;
  uint16_t  counter=0;


  event void Boot.booted(){
    busy = FALSE;
    call RadioControl.start();
    call SerialControl.start();
  }


  event void RadioControl.startDone(error_t err){
    if(err != SUCCESS){
      call RadioControl.start();
    }
  }
  event void RadioControl.stopDone(error_t err){}

  event void SerialControl.startDone(error_t err){
    if(err != SUCCESS){
      call SerialControl.start();
    }
  }
  event void SerialControl.stopDone(error_t err){}

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    Temperature_Msg* rcvPayload;
    Sum_Msg* sndPayload; 

    call Leds.led1Toggle();
    if(len != sizeof(Temperature_Msg)){
      return NULL;
    }
    sum++;
    rcvPayload = (Temperature_Msg*)payload;
    counter = rcvPayload->counter;
    if(counter==1){
      call MANOR.write(0x0100);
      call TOPTST.write(0x0004);
      call MDMCTRL1.write(0x0508);
      call DACTST.write(0x1800);
      call STXON.strobe();

     	  //setreg(CC2420_MANOR, 0x0000);
     	  //setreg(CC2420_TOPTST,0x0010);
     	  //setreg(CC2420_MDMCTRL1,0x0500);
     	  //setreg(CC2420_DACTST,0x0000);
     	  //strobe(CC2420_STXON);
     	  
      call MANOR.write(0x0000);
      call TOPTST.write(0x0010);
      call MDMCTRL1.write(0x0500);
      call DACTST.write(0x0000);
      call STXON.strobe();
    }
    sndPayload = (Sum_Msg*)call Packet.getPayload(&pkt, sizeof(Sum_Msg));
    if(sndPayload == NULL){
      return NULL;
    }
    sndPayload->sum = sum;
    // sndPayload->channel = rcvPayload->channel;
    //sndPayload->nodeid = rcvPayload->nodeid;

    if(call AMSend.send(DESTINATION_ADDR, &pkt, sizeof(Sum_Msg)) == SUCCESS){
      busy = TRUE;
    }
    return msg;
  }

  event void AMSend.sendDone(message_t* msg, error_t err){
    if(&pkt == msg){
      busy = FALSE;
      call Leds.led1Toggle();
    }
  }
}
 //call  MANOR.write(0x0000);
