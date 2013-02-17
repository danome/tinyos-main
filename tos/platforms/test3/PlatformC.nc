#include "hardware.h"
 
configuration PlatformC {
  provides interface Init;
}

implementation{
  //components PlatformP, MotePlatformC, Msp430ClockC; 
  components PlatformP, Msp430ClockC; 
  Init = PlatformP;
  PlatformP.Msp430ClockInit -> Msp430ClockC.Init;
  //PlatformP.MoteInit -> MotePlatformC;
}
