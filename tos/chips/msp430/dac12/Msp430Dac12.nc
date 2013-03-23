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

#include "Msp430Dac12.h"

/**
 * HAL Interface for using the DAC on MSP430 microcontrollers.
 * <p>
 * <b>Typical procedure of operation:</b>
 * <p>
 * Intended process for single output:
 * <ol>
 * <li> bind, specifically ref volt
 * <li> enable
 * <li> wait for enableDone
 * <li> enableOutput
 * <li> set
 * <li> <em> do whatever </em>
 * <li> disable
 * </ol>
 *
 * Intended process for multiple sequential outputs:
 * <ol>
 * <li> bind, specifically ref volt -- load select bits ignored (reset later)
 * <li> enable
 * <li> wait for enableDone
 * <li> enableOutput
 * <li> setSequence / Repeat -- use the DMA and TimerA
 * <li> <em> do whatever </em>
 * <li> disable
 * </ol>
 *
 * @author Joe Polastre, Moteiv Corporation <info@moteiv.com
 */
interface Msp430Dac12 {

  /**
   * Bind settings to the DAC.  See Msp430Dac12.h for a full description
   * of possible settings for each of the parameters.
   */
  command error_t configure(dac12ref_t reference,
			    dac12res_t resolution,
			    dac12load_t loadselect,
			    dac12range_t range,
			    dac12amp_t amp,
			    dac12df_t twoscomplement,
			    dac12group_t group, 
			    bool enableInterrupt);
  
  /**
   * Enable/Turn on the DAC.  Starts the process of acquiring the
   * correct reference voltage and calibrating the DAC output if
   * necessary.
   *
   * @return SUCCESS if the DAC can start now.
   */
  command error_t enable();

  command error_t disable();

  /**
   * Set the value, fails if sequence or repeat in progress.
   */
  command error_t write(uint16_t dacunits);

  async event void conversionComplete();
}
