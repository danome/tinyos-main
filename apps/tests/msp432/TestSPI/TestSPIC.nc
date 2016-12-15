/*
 * Copyright (c) 2016 Eric B. Decker
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 *
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @author: Eric B. Decker <cire831@gmail.com>
 */

/* DriverLib Includes */
#include "driverlib.h"

/* Standard Includes */
#include <stdint.h>
#include <string.h>
#include <stdbool.h>


norace uint32_t Fire0_count;
 
module TestSPIC {
  uses {
    interface Boot;
    interface HplMsp432Gpio as Pin;
    interface HplMsp432PortInt as PinInt;
  }
}
implementation {

  const eUSCI_SPI_MasterConfig spiMasterConfig =
    { EUSCI_B_SPI_CLOCKSOURCE_SMCLK, 12000000, 1000000,
      EUSCI_B_SPI_MSB_FIRST,
      EUSCI_B_SPI_PHASE_DATA_CAPTURED_ONFIRST_CHANGED_ON_NEXT,
      EUSCI_B_SPI_CLOCKPOLARITY_INACTIVITY_HIGH, EUSCI_B_SPI_3PIN };

  const eUSCI_SPI_SlaveConfig spiSlaveConfig =
    { EUSCI_B_SPI_MSB_FIRST,
      EUSCI_B_SPI_PHASE_DATA_CAPTURED_ONFIRST_CHANGED_ON_NEXT,
      EUSCI_B_SPI_CLOCKPOLARITY_INACTIVITY_HIGH,
      EUSCI_B_SPI_3PIN
    };

  /* DMA Control Table */
#if defined(__TI_COMPILER_VERSION__)
#pragma DATA_ALIGN(MSP_EXP432P401RLP_DMAControlTable, 1024)
#elif defined(__IAR_SYSTEMS_ICC__)
#pragma data_alignment=1024
#elif defined(__GNUC__)
  __attribute__ ((aligned (1024)))
#elif defined(__CC_ARM)
    __align(1024)
#endif
    static DMA_ControlTable MSP_EXP432P401RLP_DMAControlTable[32];

#define MSG_LENGTH    26

  uint32_t isrCounter = 0;
  uint8_t masterTxData[26] = "Hello, this is master SPI";
  uint8_t masterRxData[26] = { 0 };
  uint8_t slaveTxData[26] = "Hello, this is slave SPI";
  uint8_t slaveRxData[26] = { 0 };

  
  void run_dma() {
    volatile uint32_t ii;

    /* Halting Watchdog */
    WDT_A_holdTimer();

    bkpt();
    
    /* Configure CLK, MOSI & MISO for SPI0 (EUSCI_B0) */
    GPIO_setAsPeripheralModuleFunctionOutputPin(GPIO_PORT_P1,
						    GPIO_PIN5 | GPIO_PIN6, GPIO_PRIMARY_MODULE_FUNCTION);
    GPIO_setAsPeripheralModuleFunctionInputPin(GPIO_PORT_P1,
						   GPIO_PIN7, GPIO_PRIMARY_MODULE_FUNCTION);

    /* Configure SLAVE CLK, MOSI and SPMI (EUSCI_B2) */
    GPIO_setAsPeripheralModuleFunctionInputPin(GPIO_PORT_P3,
						   GPIO_PIN5 | GPIO_PIN6 | GPIO_PIN7,
						   GPIO_PRIMARY_MODULE_FUNCTION);

    /* Configuring SPI module */
    SPI_initSlave(EUSCI_B2_BASE, &spiSlaveConfig);
    SPI_initMaster(EUSCI_B0_BASE, &spiMasterConfig);

    /* Enable the SPI module */
    SPI_enableModule(EUSCI_B2_BASE);
    SPI_enableModule(EUSCI_B0_BASE);

    /* Configuring DMA module */
    DMA_enableModule();
    DMA_setControlBase(MSP_EXP432P401RLP_DMAControlTable);

    /* Assign DMA channel 0 to EUSCI_B0_TX0, channel 1 to EUSCI_B0_RX0 */
    DMA_assignChannel(DMA_CH0_EUSCIB0TX0);
    DMA_assignChannel(DMA_CH1_EUSCIB0RX0);
    DMA_assignChannel(DMA_CH4_EUSCIB2TX0);
    DMA_assignChannel(DMA_CH5_EUSCIB2RX0);

    /* Setup the TX transfer characteristics & buffers */
    DMA_setChannelControl(DMA_CH0_EUSCIB0TX0 | UDMA_PRI_SELECT,
			      UDMA_SIZE_8 | UDMA_SRC_INC_8 | UDMA_DST_INC_NONE | UDMA_ARB_1);
    DMA_setChannelTransfer(DMA_CH0_EUSCIB0TX0 | UDMA_PRI_SELECT,
                               UDMA_MODE_BASIC,
                               masterTxData,
                               (void *) SPI_getTransmitBufferAddressForDMA(EUSCI_B0_BASE),
                               MSG_LENGTH);

    /* Setup the RX transfer characteristics & buffers */
    DMA_setChannelControl(DMA_CH1_EUSCIB0RX0 | UDMA_PRI_SELECT,
                              UDMA_SIZE_8 | UDMA_SRC_INC_NONE | UDMA_DST_INC_8 | UDMA_ARB_1);
    DMA_setChannelTransfer(DMA_CH1_EUSCIB0RX0 | UDMA_PRI_SELECT,
			       UDMA_MODE_BASIC,
			       (void *) SPI_getReceiveBufferAddressForDMA(EUSCI_B0_BASE),
			       masterRxData,
			       MSG_LENGTH);

    /* Slave Settings */
    DMA_setChannelControl(DMA_CH4_EUSCIB2TX0 | UDMA_PRI_SELECT,
                              UDMA_SIZE_8 | UDMA_SRC_INC_8 | UDMA_DST_INC_NONE | UDMA_ARB_1);
    DMA_setChannelTransfer(DMA_CH4_EUSCIB2TX0 | UDMA_PRI_SELECT,
			       UDMA_MODE_BASIC, slaveTxData,
			       (void *) SPI_getTransmitBufferAddressForDMA(EUSCI_B2_BASE),
			       MSG_LENGTH);

    /* Setup the RX transfer characteristics & buffers */
    DMA_setChannelControl(DMA_CH5_EUSCIB2RX0 | UDMA_PRI_SELECT,
                              UDMA_SIZE_8 | UDMA_SRC_INC_NONE | UDMA_DST_INC_8 | UDMA_ARB_1);
    DMA_setChannelTransfer(DMA_CH5_EUSCIB2RX0 | UDMA_PRI_SELECT,
			       UDMA_MODE_BASIC,
			       (void *) SPI_getReceiveBufferAddressForDMA(EUSCI_B2_BASE),
			       slaveRxData,
			       MSG_LENGTH);

    /* Enable DMA interrupt */
    DMA_assignInterrupt(INT_DMA_INT1, 1);
    DMA_clearInterruptFlag(DMA_CH1_EUSCIB0RX0 & 0x0F);

    /* Assigning/Enabling Interrupts */
    Interrupt_enableInterrupt(INT_DMA_INT1);
    DMA_enableInterrupt(INT_DMA_INT1);
    DMA_enableChannel(5);
    DMA_enableChannel(4);

    /* Delaying for forty cycles to let the master catch up with the slave */
    for(ii=0;ii<50;ii++);

    DMA_enableChannel(1);
    DMA_enableChannel(0);
    __NOP();
    __NOP();

    /* Polling to see if the master receive is finished */
    while (1) {
        if (isrCounter > 0) {
            __no_operation();
	  }
      }
}

  uint8_t state;

  event void Boot.booted() {
    call Pin.setFunction(MSP432_GPIO_IO);
    call Pin.setResistorMode(MSP432_GPIO_RESISTOR_OFF);
    call Pin.makeOutput();
    call Pin.clr();
    call Pin.set();

    Fire0_count = 0;

    run_dma();
  }

  
  async event void PinInt.fired() {
    Fire0_count++;
    call Pin.toggle();
  }
}

  void DMA_INT0_Handler() @C() @spontaneous() __attribute__((interrupt)) {
  }
