# FPGA UART Transceiver
A SystemVerilog project of a parameterized UART transmitter and receiver, designed and tested in Xilinx Vivado.

This project converts 8-bit parallel data (default in SystemVerilog) into a serial UART frame using the transmitter, the reconstructs the original signal using the reciever.

## Overview

This project implements a basic UART communication system using:

- 8 data bits
- No parity
- 1 stop bit
- LSB-first transmission
- 9600 baud
- 100 MHz FPGA Clock
- Finite-state machines for TX and RX
- Parameterized baud-rate timing

The Transmitter and Receiver were verified together using a loopback simulation.

## System Architecture

8 - bit parallel data -> UART TX -> Serial UART Data -> UART RX -> 8-bit Parallel Data

## UART Transmitter 

The transmitter accepts an 8-bit input byte and sends it as a standard UART frame.

The TX State Machine uses four states:
  - IDLE -> START -> DATA -> STOP -> IDLE

A transmitted UART Frame looks like:
  - IDLE  |  START  |  D0  D1  D2  D3  D4  D5  D6  D7  |  STOP  |
  -  1   |    0    |            LSB FIRST             |    1   |

The transmitter uses a baud counter to hold each output bit for the correct amount of time. 

For a 100 MHz FPGA clock and 9600 baud:
  - CLKS_PER_BIT = 100,000,000 / 9600 = 10,416 clocks

The input bye is stored internally before transmission so that changes to the external input do not affect an active UART frame.

## UART Reciever

The receiver monitors the serial RX line and reconstructs the original 8-bit byte

The RX State Machine also uses:
  - IDLE -> START -> DATA -> STOP -> IDLE

When the RX line transitions low, the receiver detects a possible start bit. 

The receiver waits approximately half of one UART bit period before checking the start bit. This allows the sampling bit near the center of the bit for maximum accuracy 

After validating the start bit, the receiver samples each data bit once per UART bit period and stores the result internally

After receiving all eight bits and validating the stop bit:
  - rx_data = received byte
  - rx_valid = 1 for one clock cycle

## Tools

- SystemVerilog
- Xilinx Vivado
- Vivado Behavioral Simulation
