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
 * @date   March, 2013
 *
 * this is used in support of the dac interrupt vector, which can't
 * be directly services in the generic hpl module
 */

module HplMsp430Dac12InterruptP {
  provides interface HplMsp430Dac12Interrupt;
}

implementation {
  #if defined(DACDMA_VECTOR)
    #define XX_DAC_VECTOR_XX DACDMA_VECTOR
  #elif defined(DAC12_DMA_VECTOR)
    #define XX_DAC_VECTOR_XX DAC12_DMA_VECTOR
  #elif defined(DAC12_VECTOR)
    #define XX_DAC_VECTOR_XX DAC12_VECTOR
  #else
    #error "DAC VECTOR not defined for cpu selected"
  #endif

  TOSH_SIGNAL(XX_DAC_VECTOR_XX) {
    signal HplMsp430Dac12Interrupt.fired();
  }
  async default event void HplMsp430Dac12Interrupt.fired(){}
}
