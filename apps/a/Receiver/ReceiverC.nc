#include "Message.h"
#define DESTINATION_ADDR 2  

module ReceiverC{
  uses{
    interface Boot;
    interface Leds;
    interface Packet;
    interface AMSend;
    interface Receive;
    interface SplitControl as RadioControl;
    interface SplitControl as SerialControl;
    interface CC2420Register as Reg[ uint8_t id ];
    interface CC2420Strobe as Strobe[ uint8_t id ]; 
  }
}



implementation{

  bool busy; 
  message_t pkt;
  uint16_t  sum=0;       //接收端接受到的包的数目 
  uint16_t  counter=0;   //用于当接收到counter=1时，广播一个未调制的噪声


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

    call Leds.led1Toggle();          //当接收端收到无线消息时，led1灯亮
    if(len != sizeof(Temperature_Msg)){
      return NULL;
    }
    sum++;                            //用于统计收到的包的数目 sum从1开始
    rcvPayload = (Temperature_Msg*)payload;                                //表示无线通信接受到的数据
    counter = rcvPayload->counter;   						    // 显示包的编号
    if(counter==1){
    	  //接收端接收到第一个包时，广播一个大的干扰噪声（未调制的信号），屏蔽周围的其他节点
        
         call Reg.write[ CC2420_MANOR ]( 0x0100 );
         call Reg.write[ CC2420_TOPTST ]( 0x0004 );
         call Reg.write[ CC2420_MDMCTRL1 ]( 0x0508 );
         call Reg.write[ CC2420_DACTST ]( 0x1800 );
         call Strobe.strobe[ CC2420_STXON ]();
       

     	  //广播完成后，恢复到正常模式
     	  //setreg(CC2420_MANOR, 0x0000);
     	  //setreg(CC2420_TOPTST,0x0010);
     	  //setreg(CC2420_MDMCTRL1,0x0500);
     	  //setreg(CC2420_DACTST,0x0000);
     	  //strobe(CC2420_STXON);
     	  
     	   call Reg.write[ CC2420_MANOR ]( 0x0000 );
         call Reg.write[ CC2420_TOPTST ]( 0x0010 );
         call Reg.write[ CC2420_MDMCTRL1 ]( 0x0500 );
         call Reg.write[ CC2420_DACTST ]( 0x0000 );
         call Strobe.strobe[ CC2420_STXON ]();
     	  
     	 
     }
    sndPayload = (Sum_Msg*)call Packet.getPayload(&pkt, sizeof(Sum_Msg));  //表示串口通信发送的数据
    if(sndPayload == NULL){
      return NULL;
    }
    sndPayload->sum = sum;
    // sndPayload->channel = rcvPayload->channel;   //显示当前使用的信道
    //sndPayload->nodeid = rcvPayload->nodeid;     //nodeid 是发送端的ID

    if(call AMSend.send(DESTINATION_ADDR, &pkt, sizeof(Sum_Msg)) == SUCCESS){
      busy = TRUE;
    }
    return msg;
  }

  event void AMSend.sendDone(message_t* msg, error_t err){
    if(&pkt == msg){
      busy = FALSE;
      call Leds.led1Toggle();          //当接收端将串口消息发送出去时，led1灯才熄灭
    }
  }
}
 //call  MANOR.write(0x0000);
       
