
#ifndef MESSAGE_H
#define MESSAGE_H

typedef nx_struct Sum_Msg{
  nx_uint16_t sum;
} Sum_Msg;

typedef nx_struct Temperature_Msg{
  nx_uint16_t temp1;
  nx_uint16_t temp2;
  nx_uint16_t temp3;
  nx_uint16_t temp4;
  nx_uint16_t temp5;
  nx_uint16_t temp6;
  nx_uint16_t temp7;
  nx_uint16_t temp8;
  nx_uint16_t temp9;
  nx_uint16_t temp10;
  nx_uint16_t temp11;
  nx_uint16_t temp12;
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} Temperature_Msg;

enum {AM_TEMPERATURE_MSG = 6};
enum { AM_SUM_MSG = 6};

#endif
