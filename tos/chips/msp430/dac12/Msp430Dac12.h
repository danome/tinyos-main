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

/*
 * Copyright (c) 2005 Moteiv Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached MOTEIV-LICENSE     
 * file. If you do not find these files, copies can be found at
 * http://www.moteiv.com/MOTEIV-LICENSE.txt and by emailing info@moteiv.com.
 */

#ifndef MSP430DAC12_H
#define MSP430DAC12_H

#include "msp430hardware.h"

typedef enum {
  DAC12_AMP_OFFZ = 0,
  DAC12_AMP_OFF0 = 1,
  DAC12_AMP_LOW_LOW = 2,
  DAC12_AMP_LOW_MED = 3,
  DAC12_AMP_LOW_HIGH = 4,
  DAC12_AMP_MED_MED = 5,
  DAC12_AMP_MED_HIGH = 6,
  DAC12_AMP_HIGH_HIGH = 7
} dac12amp_t;

typedef enum {
  DAC12_LOAD_WRITE = 0,
  DAC12_LOAD_WRITEGROUP = 1,
  DAC12_LOAD_TAOUT1 = 2,
  DAC12_LOAD_TBOUT2 = 3
} dac12load_t;

typedef enum {
  DAC12_REF_VREF = 0,
  DAC12_REF_VEREF = 2
} dac12ref_t;

typedef enum {
  DAC12_RES_12BIT = 0,
  DAC12_RES_8BIT = 1
} dac12res_t;

typedef enum {
  DAC12_OUTPUTRANGE_3X = 0,
  DAC12_OUTPUTRANGE_1X = 1
} dac12range_t;

typedef enum {
  DAC12_DF_STRAIGHT = 0,
  DAC12_DF_2COMP = 1
} dac12df_t;

typedef enum {
  DAC12_GROUP_OFF = 0,
  DAC12_GROUP_ON = 1
} dac12group_t;

#endif
