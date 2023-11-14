/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'cpu' in SOPC Builder design 'nios_sd_loader'
 * SOPC Builder design path: ../../nios_sd_loader.sopcinfo
 *
 * Generated: Tue Nov 14 11:27:49 GMT 2023
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_gen2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x00080820
#define ALT_CPU_CPU_ARCH_NIOS2_R1
#define ALT_CPU_CPU_FREQ 50000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "tiny"
#define ALT_CPU_DATA_ADDR_WIDTH 0x14
#define ALT_CPU_DCACHE_LINE_SIZE 0
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_EXCEPTION_ADDR 0x00040020
#define ALT_CPU_FLASH_ACCELERATOR_LINES 0
#define ALT_CPU_FLASH_ACCELERATOR_LINE_SIZE 0
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 50000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 0
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 0
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_ICACHE_SIZE 0
#define ALT_CPU_INST_ADDR_WIDTH 0x14
#define ALT_CPU_NAME "cpu"
#define ALT_CPU_OCI_VERSION 1
#define ALT_CPU_RESET_ADDR 0x00040000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x00080820
#define NIOS2_CPU_ARCH_NIOS2_R1
#define NIOS2_CPU_FREQ 50000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "tiny"
#define NIOS2_DATA_ADDR_WIDTH 0x14
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x00040020
#define NIOS2_FLASH_ACCELERATOR_LINES 0
#define NIOS2_FLASH_ACCELERATOR_LINE_SIZE 0
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 0
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 0
#define NIOS2_ICACHE_LINE_SIZE_LOG2 0
#define NIOS2_ICACHE_SIZE 0
#define NIOS2_INST_ADDR_WIDTH 0x14
#define NIOS2_OCI_VERSION 1
#define NIOS2_RESET_ADDR 0x00040000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_ONCHIP_MEMORY2
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_TIMER
#define __ALTERA_NIOS2_GEN2


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone IV E"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart"
#define ALT_STDERR_BASE 0x81150
#define ALT_STDERR_DEV jtag_uart
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart"
#define ALT_STDIN_BASE 0x81150
#define ALT_STDIN_DEV jtag_uart
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart"
#define ALT_STDOUT_BASE 0x81150
#define ALT_STDOUT_DEV jtag_uart
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "nios_sd_loader"


/*
 * address configuration
 *
 */

#define ADDRESS_BASE 0x810a0
#define ADDRESS_BIT_CLEARING_EDGE_REGISTER 0
#define ADDRESS_BIT_MODIFYING_OUTPUT_REGISTER 0
#define ADDRESS_CAPTURE 0
#define ADDRESS_DATA_WIDTH 16
#define ADDRESS_DO_TEST_BENCH_WIRING 0
#define ADDRESS_DRIVEN_SIM_VALUE 0
#define ADDRESS_EDGE_TYPE "NONE"
#define ADDRESS_FREQ 50000000
#define ADDRESS_HAS_IN 0
#define ADDRESS_HAS_OUT 1
#define ADDRESS_HAS_TRI 0
#define ADDRESS_IRQ -1
#define ADDRESS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ADDRESS_IRQ_TYPE "NONE"
#define ADDRESS_NAME "/dev/address"
#define ADDRESS_RESET_VALUE 0
#define ADDRESS_SPAN 16
#define ADDRESS_TYPE "altera_avalon_pio"
#define ALT_MODULE_CLASS_address altera_avalon_pio


/*
 * bus_ack_n configuration
 *
 */

#define ALT_MODULE_CLASS_bus_ack_n altera_avalon_pio
#define BUS_ACK_N_BASE 0x81070
#define BUS_ACK_N_BIT_CLEARING_EDGE_REGISTER 0
#define BUS_ACK_N_BIT_MODIFYING_OUTPUT_REGISTER 0
#define BUS_ACK_N_CAPTURE 0
#define BUS_ACK_N_DATA_WIDTH 1
#define BUS_ACK_N_DO_TEST_BENCH_WIRING 0
#define BUS_ACK_N_DRIVEN_SIM_VALUE 0
#define BUS_ACK_N_EDGE_TYPE "NONE"
#define BUS_ACK_N_FREQ 50000000
#define BUS_ACK_N_HAS_IN 1
#define BUS_ACK_N_HAS_OUT 0
#define BUS_ACK_N_HAS_TRI 0
#define BUS_ACK_N_IRQ -1
#define BUS_ACK_N_IRQ_INTERRUPT_CONTROLLER_ID -1
#define BUS_ACK_N_IRQ_TYPE "NONE"
#define BUS_ACK_N_NAME "/dev/bus_ack_n"
#define BUS_ACK_N_RESET_VALUE 0
#define BUS_ACK_N_SPAN 16
#define BUS_ACK_N_TYPE "altera_avalon_pio"


/*
 * bus_req_n configuration
 *
 */

#define ALT_MODULE_CLASS_bus_req_n altera_avalon_pio
#define BUS_REQ_N_BASE 0x81080
#define BUS_REQ_N_BIT_CLEARING_EDGE_REGISTER 0
#define BUS_REQ_N_BIT_MODIFYING_OUTPUT_REGISTER 0
#define BUS_REQ_N_CAPTURE 0
#define BUS_REQ_N_DATA_WIDTH 1
#define BUS_REQ_N_DO_TEST_BENCH_WIRING 0
#define BUS_REQ_N_DRIVEN_SIM_VALUE 0
#define BUS_REQ_N_EDGE_TYPE "NONE"
#define BUS_REQ_N_FREQ 50000000
#define BUS_REQ_N_HAS_IN 0
#define BUS_REQ_N_HAS_OUT 1
#define BUS_REQ_N_HAS_TRI 0
#define BUS_REQ_N_IRQ -1
#define BUS_REQ_N_IRQ_INTERRUPT_CONTROLLER_ID -1
#define BUS_REQ_N_IRQ_TYPE "NONE"
#define BUS_REQ_N_NAME "/dev/bus_req_n"
#define BUS_REQ_N_RESET_VALUE 1
#define BUS_REQ_N_SPAN 16
#define BUS_REQ_N_TYPE "altera_avalon_pio"


/*
 * cpu_address configuration
 *
 */

#define ALT_MODULE_CLASS_cpu_address altera_avalon_pio
#define CPU_ADDRESS_BASE 0x81050
#define CPU_ADDRESS_BIT_CLEARING_EDGE_REGISTER 0
#define CPU_ADDRESS_BIT_MODIFYING_OUTPUT_REGISTER 0
#define CPU_ADDRESS_CAPTURE 0
#define CPU_ADDRESS_DATA_WIDTH 16
#define CPU_ADDRESS_DO_TEST_BENCH_WIRING 0
#define CPU_ADDRESS_DRIVEN_SIM_VALUE 0
#define CPU_ADDRESS_EDGE_TYPE "NONE"
#define CPU_ADDRESS_FREQ 50000000
#define CPU_ADDRESS_HAS_IN 1
#define CPU_ADDRESS_HAS_OUT 0
#define CPU_ADDRESS_HAS_TRI 0
#define CPU_ADDRESS_IRQ -1
#define CPU_ADDRESS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CPU_ADDRESS_IRQ_TYPE "NONE"
#define CPU_ADDRESS_NAME "/dev/cpu_address"
#define CPU_ADDRESS_RESET_VALUE 0
#define CPU_ADDRESS_SPAN 16
#define CPU_ADDRESS_TYPE "altera_avalon_pio"


/*
 * cpu_address_direct configuration
 *
 */

#define ALT_MODULE_CLASS_cpu_address_direct altera_avalon_pio
#define CPU_ADDRESS_DIRECT_BASE 0x81030
#define CPU_ADDRESS_DIRECT_BIT_CLEARING_EDGE_REGISTER 0
#define CPU_ADDRESS_DIRECT_BIT_MODIFYING_OUTPUT_REGISTER 0
#define CPU_ADDRESS_DIRECT_CAPTURE 0
#define CPU_ADDRESS_DIRECT_DATA_WIDTH 16
#define CPU_ADDRESS_DIRECT_DO_TEST_BENCH_WIRING 0
#define CPU_ADDRESS_DIRECT_DRIVEN_SIM_VALUE 0
#define CPU_ADDRESS_DIRECT_EDGE_TYPE "NONE"
#define CPU_ADDRESS_DIRECT_FREQ 50000000
#define CPU_ADDRESS_DIRECT_HAS_IN 1
#define CPU_ADDRESS_DIRECT_HAS_OUT 0
#define CPU_ADDRESS_DIRECT_HAS_TRI 0
#define CPU_ADDRESS_DIRECT_IRQ -1
#define CPU_ADDRESS_DIRECT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CPU_ADDRESS_DIRECT_IRQ_TYPE "NONE"
#define CPU_ADDRESS_DIRECT_NAME "/dev/cpu_address_direct"
#define CPU_ADDRESS_DIRECT_RESET_VALUE 0
#define CPU_ADDRESS_DIRECT_SPAN 16
#define CPU_ADDRESS_DIRECT_TYPE "altera_avalon_pio"


/*
 * cpu_cmd configuration
 *
 */

#define ALT_MODULE_CLASS_cpu_cmd altera_avalon_pio
#define CPU_CMD_BASE 0x810c0
#define CPU_CMD_BIT_CLEARING_EDGE_REGISTER 0
#define CPU_CMD_BIT_MODIFYING_OUTPUT_REGISTER 0
#define CPU_CMD_CAPTURE 0
#define CPU_CMD_DATA_WIDTH 8
#define CPU_CMD_DO_TEST_BENCH_WIRING 0
#define CPU_CMD_DRIVEN_SIM_VALUE 0
#define CPU_CMD_EDGE_TYPE "NONE"
#define CPU_CMD_FREQ 50000000
#define CPU_CMD_HAS_IN 1
#define CPU_CMD_HAS_OUT 0
#define CPU_CMD_HAS_TRI 0
#define CPU_CMD_IRQ -1
#define CPU_CMD_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CPU_CMD_IRQ_TYPE "NONE"
#define CPU_CMD_NAME "/dev/cpu_cmd"
#define CPU_CMD_RESET_VALUE 0
#define CPU_CMD_SPAN 16
#define CPU_CMD_TYPE "altera_avalon_pio"


/*
 * cpu_cmd_ack configuration
 *
 */

#define ALT_MODULE_CLASS_cpu_cmd_ack altera_avalon_pio
#define CPU_CMD_ACK_BASE 0x81040
#define CPU_CMD_ACK_BIT_CLEARING_EDGE_REGISTER 0
#define CPU_CMD_ACK_BIT_MODIFYING_OUTPUT_REGISTER 0
#define CPU_CMD_ACK_CAPTURE 0
#define CPU_CMD_ACK_DATA_WIDTH 1
#define CPU_CMD_ACK_DO_TEST_BENCH_WIRING 0
#define CPU_CMD_ACK_DRIVEN_SIM_VALUE 0
#define CPU_CMD_ACK_EDGE_TYPE "NONE"
#define CPU_CMD_ACK_FREQ 50000000
#define CPU_CMD_ACK_HAS_IN 0
#define CPU_CMD_ACK_HAS_OUT 1
#define CPU_CMD_ACK_HAS_TRI 0
#define CPU_CMD_ACK_IRQ -1
#define CPU_CMD_ACK_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CPU_CMD_ACK_IRQ_TYPE "NONE"
#define CPU_CMD_ACK_NAME "/dev/cpu_cmd_ack"
#define CPU_CMD_ACK_RESET_VALUE 0
#define CPU_CMD_ACK_SPAN 16
#define CPU_CMD_ACK_TYPE "altera_avalon_pio"


/*
 * cpu_cmd_en configuration
 *
 */

#define ALT_MODULE_CLASS_cpu_cmd_en altera_avalon_pio
#define CPU_CMD_EN_BASE 0x810f0
#define CPU_CMD_EN_BIT_CLEARING_EDGE_REGISTER 0
#define CPU_CMD_EN_BIT_MODIFYING_OUTPUT_REGISTER 0
#define CPU_CMD_EN_CAPTURE 0
#define CPU_CMD_EN_DATA_WIDTH 1
#define CPU_CMD_EN_DO_TEST_BENCH_WIRING 0
#define CPU_CMD_EN_DRIVEN_SIM_VALUE 0
#define CPU_CMD_EN_EDGE_TYPE "NONE"
#define CPU_CMD_EN_FREQ 50000000
#define CPU_CMD_EN_HAS_IN 1
#define CPU_CMD_EN_HAS_OUT 0
#define CPU_CMD_EN_HAS_TRI 0
#define CPU_CMD_EN_IRQ -1
#define CPU_CMD_EN_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CPU_CMD_EN_IRQ_TYPE "NONE"
#define CPU_CMD_EN_NAME "/dev/cpu_cmd_en"
#define CPU_CMD_EN_RESET_VALUE 0
#define CPU_CMD_EN_SPAN 16
#define CPU_CMD_EN_TYPE "altera_avalon_pio"


/*
 * cpu_rd_n configuration
 *
 */

#define ALT_MODULE_CLASS_cpu_rd_n altera_avalon_pio
#define CPU_RD_N_BASE 0x810e0
#define CPU_RD_N_BIT_CLEARING_EDGE_REGISTER 0
#define CPU_RD_N_BIT_MODIFYING_OUTPUT_REGISTER 0
#define CPU_RD_N_CAPTURE 0
#define CPU_RD_N_DATA_WIDTH 1
#define CPU_RD_N_DO_TEST_BENCH_WIRING 0
#define CPU_RD_N_DRIVEN_SIM_VALUE 0
#define CPU_RD_N_EDGE_TYPE "NONE"
#define CPU_RD_N_FREQ 50000000
#define CPU_RD_N_HAS_IN 1
#define CPU_RD_N_HAS_OUT 0
#define CPU_RD_N_HAS_TRI 0
#define CPU_RD_N_IRQ -1
#define CPU_RD_N_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CPU_RD_N_IRQ_TYPE "NONE"
#define CPU_RD_N_NAME "/dev/cpu_rd_n"
#define CPU_RD_N_RESET_VALUE 0
#define CPU_RD_N_SPAN 16
#define CPU_RD_N_TYPE "altera_avalon_pio"


/*
 * cpu_wr_n configuration
 *
 */

#define ALT_MODULE_CLASS_cpu_wr_n altera_avalon_pio
#define CPU_WR_N_BASE 0x810d0
#define CPU_WR_N_BIT_CLEARING_EDGE_REGISTER 0
#define CPU_WR_N_BIT_MODIFYING_OUTPUT_REGISTER 0
#define CPU_WR_N_CAPTURE 0
#define CPU_WR_N_DATA_WIDTH 1
#define CPU_WR_N_DO_TEST_BENCH_WIRING 0
#define CPU_WR_N_DRIVEN_SIM_VALUE 0
#define CPU_WR_N_EDGE_TYPE "NONE"
#define CPU_WR_N_FREQ 50000000
#define CPU_WR_N_HAS_IN 1
#define CPU_WR_N_HAS_OUT 0
#define CPU_WR_N_HAS_TRI 0
#define CPU_WR_N_IRQ -1
#define CPU_WR_N_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CPU_WR_N_IRQ_TYPE "NONE"
#define CPU_WR_N_NAME "/dev/cpu_wr_n"
#define CPU_WR_N_RESET_VALUE 0
#define CPU_WR_N_SPAN 16
#define CPU_WR_N_TYPE "altera_avalon_pio"


/*
 * ctrl_bus configuration
 *
 */

#define ALT_MODULE_CLASS_ctrl_bus altera_avalon_pio
#define CTRL_BUS_BASE 0x810b0
#define CTRL_BUS_BIT_CLEARING_EDGE_REGISTER 0
#define CTRL_BUS_BIT_MODIFYING_OUTPUT_REGISTER 0
#define CTRL_BUS_CAPTURE 0
#define CTRL_BUS_DATA_WIDTH 4
#define CTRL_BUS_DO_TEST_BENCH_WIRING 0
#define CTRL_BUS_DRIVEN_SIM_VALUE 0
#define CTRL_BUS_EDGE_TYPE "NONE"
#define CTRL_BUS_FREQ 50000000
#define CTRL_BUS_HAS_IN 0
#define CTRL_BUS_HAS_OUT 1
#define CTRL_BUS_HAS_TRI 0
#define CTRL_BUS_IRQ -1
#define CTRL_BUS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CTRL_BUS_IRQ_TYPE "NONE"
#define CTRL_BUS_NAME "/dev/ctrl_bus"
#define CTRL_BUS_RESET_VALUE 15
#define CTRL_BUS_SPAN 16
#define CTRL_BUS_TYPE "altera_avalon_pio"


/*
 * data configuration
 *
 */

#define ALT_MODULE_CLASS_data altera_avalon_pio
#define DATA_BASE 0x81090
#define DATA_BIT_CLEARING_EDGE_REGISTER 0
#define DATA_BIT_MODIFYING_OUTPUT_REGISTER 0
#define DATA_CAPTURE 0
#define DATA_DATA_WIDTH 8
#define DATA_DO_TEST_BENCH_WIRING 0
#define DATA_DRIVEN_SIM_VALUE 0
#define DATA_EDGE_TYPE "NONE"
#define DATA_FREQ 50000000
#define DATA_HAS_IN 0
#define DATA_HAS_OUT 0
#define DATA_HAS_TRI 1
#define DATA_IRQ -1
#define DATA_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DATA_IRQ_TYPE "NONE"
#define DATA_NAME "/dev/data"
#define DATA_RESET_VALUE 0
#define DATA_SPAN 16
#define DATA_TYPE "altera_avalon_pio"


/*
 * hal configuration
 *
 */

#define ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
#define ALT_MAX_FD 32
#define ALT_SYS_CLK TIMER
#define ALT_TIMESTAMP_CLK none


/*
 * jtag_uart configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart altera_avalon_jtag_uart
#define JTAG_UART_BASE 0x81150
#define JTAG_UART_IRQ 1
#define JTAG_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_NAME "/dev/jtag_uart"
#define JTAG_UART_READ_DEPTH 64
#define JTAG_UART_READ_THRESHOLD 8
#define JTAG_UART_SPAN 8
#define JTAG_UART_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_WRITE_DEPTH 64
#define JTAG_UART_WRITE_THRESHOLD 8


/*
 * ledg_pio configuration
 *
 */

#define ALT_MODULE_CLASS_ledg_pio altera_avalon_pio
#define LEDG_PIO_BASE 0x81140
#define LEDG_PIO_BIT_CLEARING_EDGE_REGISTER 0
#define LEDG_PIO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define LEDG_PIO_CAPTURE 0
#define LEDG_PIO_DATA_WIDTH 8
#define LEDG_PIO_DO_TEST_BENCH_WIRING 0
#define LEDG_PIO_DRIVEN_SIM_VALUE 0
#define LEDG_PIO_EDGE_TYPE "NONE"
#define LEDG_PIO_FREQ 50000000
#define LEDG_PIO_HAS_IN 0
#define LEDG_PIO_HAS_OUT 1
#define LEDG_PIO_HAS_TRI 0
#define LEDG_PIO_IRQ -1
#define LEDG_PIO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define LEDG_PIO_IRQ_TYPE "NONE"
#define LEDG_PIO_NAME "/dev/ledg_pio"
#define LEDG_PIO_RESET_VALUE 0
#define LEDG_PIO_SPAN 16
#define LEDG_PIO_TYPE "altera_avalon_pio"


/*
 * nmi_n configuration
 *
 */

#define ALT_MODULE_CLASS_nmi_n altera_avalon_pio
#define NMI_N_BASE 0x81060
#define NMI_N_BIT_CLEARING_EDGE_REGISTER 0
#define NMI_N_BIT_MODIFYING_OUTPUT_REGISTER 0
#define NMI_N_CAPTURE 0
#define NMI_N_DATA_WIDTH 1
#define NMI_N_DO_TEST_BENCH_WIRING 0
#define NMI_N_DRIVEN_SIM_VALUE 0
#define NMI_N_EDGE_TYPE "NONE"
#define NMI_N_FREQ 50000000
#define NMI_N_HAS_IN 0
#define NMI_N_HAS_OUT 1
#define NMI_N_HAS_TRI 0
#define NMI_N_IRQ -1
#define NMI_N_IRQ_INTERRUPT_CONTROLLER_ID -1
#define NMI_N_IRQ_TYPE "NONE"
#define NMI_N_NAME "/dev/nmi_n"
#define NMI_N_RESET_VALUE 1
#define NMI_N_SPAN 16
#define NMI_N_TYPE "altera_avalon_pio"


/*
 * onchip_memory configuration
 *
 */

#define ALT_MODULE_CLASS_onchip_memory altera_avalon_onchip_memory2
#define ONCHIP_MEMORY_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define ONCHIP_MEMORY_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define ONCHIP_MEMORY_BASE 0x40000
#define ONCHIP_MEMORY_CONTENTS_INFO ""
#define ONCHIP_MEMORY_DUAL_PORT 0
#define ONCHIP_MEMORY_GUI_RAM_BLOCK_TYPE "AUTO"
#define ONCHIP_MEMORY_INIT_CONTENTS_FILE "nios_sd_loader_onchip_memory"
#define ONCHIP_MEMORY_INIT_MEM_CONTENT 1
#define ONCHIP_MEMORY_INSTANCE_ID "NONE"
#define ONCHIP_MEMORY_IRQ -1
#define ONCHIP_MEMORY_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ONCHIP_MEMORY_NAME "/dev/onchip_memory"
#define ONCHIP_MEMORY_NON_DEFAULT_INIT_FILE_ENABLED 0
#define ONCHIP_MEMORY_RAM_BLOCK_TYPE "AUTO"
#define ONCHIP_MEMORY_READ_DURING_WRITE_MODE "DONT_CARE"
#define ONCHIP_MEMORY_SINGLE_CLOCK_OP 0
#define ONCHIP_MEMORY_SIZE_MULTIPLE 1
#define ONCHIP_MEMORY_SIZE_VALUE 262144
#define ONCHIP_MEMORY_SPAN 262144
#define ONCHIP_MEMORY_TYPE "altera_avalon_onchip_memory2"
#define ONCHIP_MEMORY_WRITABLE 1


/*
 * sd_clk configuration
 *
 */

#define ALT_MODULE_CLASS_sd_clk altera_avalon_pio
#define SD_CLK_BASE 0x81120
#define SD_CLK_BIT_CLEARING_EDGE_REGISTER 0
#define SD_CLK_BIT_MODIFYING_OUTPUT_REGISTER 0
#define SD_CLK_CAPTURE 0
#define SD_CLK_DATA_WIDTH 1
#define SD_CLK_DO_TEST_BENCH_WIRING 0
#define SD_CLK_DRIVEN_SIM_VALUE 0
#define SD_CLK_EDGE_TYPE "NONE"
#define SD_CLK_FREQ 50000000
#define SD_CLK_HAS_IN 0
#define SD_CLK_HAS_OUT 1
#define SD_CLK_HAS_TRI 0
#define SD_CLK_IRQ -1
#define SD_CLK_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SD_CLK_IRQ_TYPE "NONE"
#define SD_CLK_NAME "/dev/sd_clk"
#define SD_CLK_RESET_VALUE 0
#define SD_CLK_SPAN 16
#define SD_CLK_TYPE "altera_avalon_pio"


/*
 * sd_cs configuration
 *
 */

#define ALT_MODULE_CLASS_sd_cs altera_avalon_pio
#define SD_CS_BASE 0x81020
#define SD_CS_BIT_CLEARING_EDGE_REGISTER 0
#define SD_CS_BIT_MODIFYING_OUTPUT_REGISTER 0
#define SD_CS_CAPTURE 0
#define SD_CS_DATA_WIDTH 1
#define SD_CS_DO_TEST_BENCH_WIRING 0
#define SD_CS_DRIVEN_SIM_VALUE 0
#define SD_CS_EDGE_TYPE "NONE"
#define SD_CS_FREQ 50000000
#define SD_CS_HAS_IN 0
#define SD_CS_HAS_OUT 1
#define SD_CS_HAS_TRI 0
#define SD_CS_IRQ -1
#define SD_CS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SD_CS_IRQ_TYPE "NONE"
#define SD_CS_NAME "/dev/sd_cs"
#define SD_CS_RESET_VALUE 0
#define SD_CS_SPAN 16
#define SD_CS_TYPE "altera_avalon_pio"


/*
 * sd_miso configuration
 *
 */

#define ALT_MODULE_CLASS_sd_miso altera_avalon_pio
#define SD_MISO_BASE 0x81100
#define SD_MISO_BIT_CLEARING_EDGE_REGISTER 0
#define SD_MISO_BIT_MODIFYING_OUTPUT_REGISTER 0
#define SD_MISO_CAPTURE 0
#define SD_MISO_DATA_WIDTH 1
#define SD_MISO_DO_TEST_BENCH_WIRING 0
#define SD_MISO_DRIVEN_SIM_VALUE 0
#define SD_MISO_EDGE_TYPE "NONE"
#define SD_MISO_FREQ 50000000
#define SD_MISO_HAS_IN 1
#define SD_MISO_HAS_OUT 0
#define SD_MISO_HAS_TRI 0
#define SD_MISO_IRQ -1
#define SD_MISO_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SD_MISO_IRQ_TYPE "NONE"
#define SD_MISO_NAME "/dev/sd_miso"
#define SD_MISO_RESET_VALUE 0
#define SD_MISO_SPAN 16
#define SD_MISO_TYPE "altera_avalon_pio"


/*
 * sd_mosi configuration
 *
 */

#define ALT_MODULE_CLASS_sd_mosi altera_avalon_pio
#define SD_MOSI_BASE 0x81110
#define SD_MOSI_BIT_CLEARING_EDGE_REGISTER 0
#define SD_MOSI_BIT_MODIFYING_OUTPUT_REGISTER 0
#define SD_MOSI_CAPTURE 0
#define SD_MOSI_DATA_WIDTH 1
#define SD_MOSI_DO_TEST_BENCH_WIRING 0
#define SD_MOSI_DRIVEN_SIM_VALUE 0
#define SD_MOSI_EDGE_TYPE "NONE"
#define SD_MOSI_FREQ 50000000
#define SD_MOSI_HAS_IN 0
#define SD_MOSI_HAS_OUT 1
#define SD_MOSI_HAS_TRI 0
#define SD_MOSI_IRQ -1
#define SD_MOSI_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SD_MOSI_IRQ_TYPE "NONE"
#define SD_MOSI_NAME "/dev/sd_mosi"
#define SD_MOSI_RESET_VALUE 0
#define SD_MOSI_SPAN 16
#define SD_MOSI_TYPE "altera_avalon_pio"


/*
 * sd_wp_n configuration
 *
 */

#define ALT_MODULE_CLASS_sd_wp_n altera_avalon_pio
#define SD_WP_N_BASE 0x81130
#define SD_WP_N_BIT_CLEARING_EDGE_REGISTER 0
#define SD_WP_N_BIT_MODIFYING_OUTPUT_REGISTER 0
#define SD_WP_N_CAPTURE 0
#define SD_WP_N_DATA_WIDTH 1
#define SD_WP_N_DO_TEST_BENCH_WIRING 0
#define SD_WP_N_DRIVEN_SIM_VALUE 0
#define SD_WP_N_EDGE_TYPE "NONE"
#define SD_WP_N_FREQ 50000000
#define SD_WP_N_HAS_IN 1
#define SD_WP_N_HAS_OUT 0
#define SD_WP_N_HAS_TRI 0
#define SD_WP_N_IRQ -1
#define SD_WP_N_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SD_WP_N_IRQ_TYPE "NONE"
#define SD_WP_N_NAME "/dev/sd_wp_n"
#define SD_WP_N_RESET_VALUE 0
#define SD_WP_N_SPAN 16
#define SD_WP_N_TYPE "altera_avalon_pio"


/*
 * timer configuration
 *
 */

#define ALT_MODULE_CLASS_timer altera_avalon_timer
#define TIMER_ALWAYS_RUN 0
#define TIMER_BASE 0x81000
#define TIMER_COUNTER_SIZE 32
#define TIMER_FIXED_PERIOD 0
#define TIMER_FREQ 50000000
#define TIMER_IRQ 0
#define TIMER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define TIMER_LOAD_VALUE 49999
#define TIMER_MULT 0.001
#define TIMER_NAME "/dev/timer"
#define TIMER_PERIOD 1
#define TIMER_PERIOD_UNITS "ms"
#define TIMER_RESET_OUTPUT 0
#define TIMER_SNAPSHOT 1
#define TIMER_SPAN 32
#define TIMER_TICKS_PER_SEC 1000
#define TIMER_TIMEOUT_PULSE_OUTPUT 0
#define TIMER_TYPE "altera_avalon_timer"

#endif /* __SYSTEM_H_ */
