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
 * pulled in from -contrib/rincon for mass consumption; most of this 
 * was used intact.  thanks to david moss.
 */

/**
 * DAC12 hardware presentation layer
 * @author David Moss
 */
configuration HplMsp430Dac12C {
  provides {
    interface HplMsp430Dac12 as HplDac0;
    interface HplMsp430Dac12 as HplDac1;
  }
}

implementation {
  components new HplMsp430Dac12P(DAC12_0CTL_, DAC12_0DAT_) as HplDac0P;
  components new HplMsp430Dac12P(DAC12_1CTL_, DAC12_1DAT_) as HplDac1P;
  
  HplDac0 = HplDac0P;
  HplDac1 = HplDac1P;
  
  components HplMsp430Dac12InterruptP;
  HplDac0P.HplMsp430Dac12Interrupt -> HplMsp430Dac12InterruptP.HplMsp430Dac12Interrupt;
  HplDac1P.HplMsp430Dac12Interrupt -> HplMsp430Dac12InterruptP.HplMsp430Dac12Interrupt;

}
