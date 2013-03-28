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
 * ported dac support from joe polastre's tinyos-1.x boomerang contrib
 */
/*
 * Copyright (c) 2005 Moteiv Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached MOTEIV-LICENSE     
 * file. If you do not find these files, copies can be found at
 * http://www.moteiv.com/MOTEIV-LICENSE.txt and by emailing info@moteiv.com.
 */

/**
 * Private implementation of MSP430 DAC functionality.
 *
 * @author Joe Polastre, Moteiv Corporation <info@moteiv.com>
 */

#include <Msp430Dac12.h>

generic module Msp430Dac12P() {
  provides {
    interface Init;
    interface Msp430Dac12 as Dac;
  }
  uses {
    interface HplMsp430Dac12 as HplDac;
  }
}

implementation {
  task void calibDac();

  command error_t Init.init() {
    call HplDac.clear();

    call HplDac.setDac12Amp(DAC12_AMP_LOW_LOW);
    post calibDac();

    return SUCCESS;
  }

  // calibrate the output on DAC
  task void calibDac() {
    call HplDac.calibrate();
  }

  // catch-all command to configure and calibrate
  command error_t Dac.enable() {
    call HplDac.enableConversion(TRUE);

    return SUCCESS;
  }

  command error_t Dac.configure(dac12ref_t reference,
				dac12res_t resolution,
				dac12load_t loadselect,
				dac12range_t range,
				dac12amp_t amp,
				dac12df_t twoscomplement,
				dac12group_t group,
				bool enableInterrupt) {

    call HplDac.enableConversion(FALSE);

    call HplDac.group(group);
    call HplDac.useTwosComplementDataFormat(twoscomplement);
    call HplDac.setDac12Amp(amp);
    call HplDac.use1xInputRange(range);
    call HplDac.selectLoad(loadselect);
    call HplDac.useVeRefVoltageSource(reference);
    call HplDac.enableInterrupt(enableInterrupt);

    return SUCCESS;
  }

  command error_t Dac.disable() {
    call HplDac.enableConversion(FALSE);
  }

  command error_t Dac.write(uint16_t dacunits) { 
    call HplDac.setData(dacunits);

    return SUCCESS;
  }

  async event void HplDac.conversionComplete() {
    signal Dac.conversionComplete();
  }

 default async event void Dac.conversionComplete() {}

}
