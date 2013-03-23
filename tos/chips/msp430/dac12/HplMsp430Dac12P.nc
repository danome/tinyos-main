/*
 * Copyright (c) 2013, Ayer and Kuris Research Engineering, Inc.
 * All rights reserved
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials provided
 *       with the distribution.
 *     * Neither the name of Ayer and Kuris Research Engineering, Inc.
 *       nor the names of its contributors may be used to endorse or 
 *	 promote products derived from this software without specific 
 *	 prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @author Steve Ayer
 * @date March, 2013
 * 
 * pulled in from -contrib/rincon for mass consumption; a fair amount of this 
 * was used intact.  thanks to david moss.
 */

/**
 * DAC12 Hardware Presentation Layer
 * @author David Moss
 */
generic module HplMsp430Dac12P(uint16_t DAC12_CTL_addr, uint16_t DAC12_DAT_addr) {
  provides interface HplMsp430Dac12;

  uses interface HplMsp430Dac12Interrupt;
}

implementation {
  #define DAC12_CTL (*(volatile uint16_t *) DAC12_CTL_addr)
  #define DAC12_DAT (*(volatile uint16_t *) DAC12_DAT_addr)
  
  /***************** HplMsp430Dac12 Commands ****************/

  /**
   * zero out the control register
   */
  command void HplMsp430Dac12.clear() {
    DAC12_CTL = 0;
  }

  /**
  * Set the resolution of the DAC.
   * @param eightBit TRUE for 8-bit resolution, FALSE for 12-bit resolution
   */
  command void HplMsp430Dac12.useEightBitResolution(bool eightBit) {
    if(eightBit)
      DAC12_CTL |= DAC12RES;
    else
      DAC12_CTL &= ~DAC12RES;
  }
  
  /**
   * Sets the reference voltage source.  If you select FALSE for Vref+, the
   * ADC reference voltage generator must be enabled and configured.
   * 
   * @param veRefPlus TRUE for VeRef+, FALSE for Vref+. 
   */
  command void HplMsp430Dac12.useVeRefVoltageSource(bool veRefPlus) { 
    if(veRefPlus)
      DAC12_CTL |= DAC12SREF_2;
    else
      DAC12_CTL &= ~DAC12SREF_2;
  }
  
  /**
   * Set the reference input and full-scale output voltage range. Options
   * are TRUE to set the full-scale output voltage to 1x the input
   * reference voltage. FALSE to set the full-scale output voltage to 3x the
   * input reference voltage.
   * 
   * @param oneTimesRefVoltage TRUE for 1x Reference Voltage, FALSE for 3x.
   */
  command void HplMsp430Dac12.use1xInputRange(bool oneTimesRefVoltage) {
    if(oneTimesRefVoltage)
      DAC12_CTL |= DAC12IR;
    else
      DAC12_CTL &= ~DAC12IR;
  }
  
  /**
   * DAC12 Amplifier setting. These bits select settling time vs. current
   * consumption for the DAC12 input and output amplifiers.
   * 
   *    DAC12AMPx   | Input Buffer         | Output Buffer
   *  ______________|______________________|_______________________________
   *       0        | Off                  | DAC12 off, output high Z
   *       1        | Off                  | DAC12 off, output 0V
   *       2        | Low speed/current    | Low speed/current
   *       3        | Low speed/current    | Medium speed/current
   *       4        | Low speed/current    | High speed/current
   *       5        | Medium speed/current | Medium speed/current
   *       6        | Medium speed/current | High speed/current
   *       7        | High speed/current   | High speed/current
   *
   * Any setting > 0 automatically selects the DAC12 pin, regardless of the 
   * associated P6SELx and P6DIRx bits.
   *
   * The reference input and voltage output buffers of the DAC12 can be 
   * configured for optimized settling time vs. power consumption. In the
   * low/low setting, the settling time is the slowest and the current
   * connsumption of both buffers is the lowest.  The medium and high settings 
   * have faster settling times, but the current consumption increases.
   * 
   * @param dac12Amp The DAC12AMPx register setting.
   */
  command void HplMsp430Dac12.setDac12Amp(uint8_t dac12Amp) { 
    DAC12_CTL = (DAC12_CTL & ~(0x7 << 5)) | (dac12Amp << 5);
  }

  /** 
   * DAC12 Load Select. Selects the load trigger for the DAC12 latch.
   * DAC12ENC must be set for the DAC to update, except when DAC12LSELx = 0.
   *   0 = DAC12 latch loads when DAC12_xDAT written (DAC12ENC is ignored)
   *   1 = DAC12 latch loads when DAC12_xDAT written, or, when grouped,
   *       when all DAC12_xDAT registers in the group have been written.
   *   2 = Rising edge of Timer_A.OUT1 (TA1)
   *   3 = Rising edge of Timer_B.OUT2 (TB2)
   * 
   * @param load Defines the point at which data gets loaded into the DAC.
   */
  command void HplMsp430Dac12.selectLoad(uint8_t load) { 
    DAC12_CTL = (DAC12_CTL & ~(0x3 << 10)) | (load << 10);
  }
  
  /**
   * Sets the data format.
   * @param twosComplement TRUE for 2's complement, FALSE for straight binary
   */
  command void HplMsp430Dac12.useTwosComplementDataFormat(bool twosComplement) { 
    if(twosComplement)
      DAC12_CTL |= DAC12DF;
    else 
      DAC12_CTL &= ~DAC12DF;
  }
  
  /**
   * @param on TRUE to activate DAC12 interrupts, FALSE to deactivate
   */
  command void HplMsp430Dac12.enableInterrupt(bool on) { 
    if(on)
      DAC12_CTL |= DAC12IE;
    else
      DAC12_CTL &= ~DAC12IE;
  }
  
  
  /** 
   * Group this DAC12_x with the next higher DAC12_x
   * @param grouped TRUE to group two DAC12's together so they update simultaneously
   */
  command void HplMsp430Dac12.group(bool grouped) { 
    if(grouped)
      DAC12_CTL |= DAC12GRP;
    else
      DAC12_CTL &= ~DAC12GRP;
  }
  
  /**
   * Calibrates the DAC. This must be run at least once when the DAC turns on.
   * The DAC12AMPx should be configured before calibration. For best calibration
   * results, port and CPU activity should be minimized during calibration.
   */
  command void HplMsp430Dac12.calibrate() { 
    DAC12_CTL |= DAC12CALON;
    while(DAC12_CTL & DAC12CALON);
  }
  
  /**
   * This enables the DAC12 module when the load select > 0. When the load 
   * select == 0, enableConversion() is ignored.
   * @param active TRUE when the DAC12 is enabled. FALSE to disable.
   */
  command void HplMsp430Dac12.enableConversion(bool active) { 
    if(active)
      DAC12_CTL |= DAC12ENC;
    else
      DAC12_CTL &= ~DAC12ENC;
  }
  
  /**
   * Write data to the DAC
   * @param data The data to convert into a voltage.
   */
  command void HplMsp430Dac12.setData(uint16_t data) { 
    DAC12_DAT = data;
  }

  async event void HplMsp430Dac12Interrupt.fired() {
    volatile uint16_t v  = DAC12_CTL;
	
    if(v & DAC12IFG) { 
      DAC12_CTL &= ~DAC12IFG;
      signal HplMsp430Dac12.conversionComplete();
    }
  }

}
