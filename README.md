# VHDL UART project

This project is part of the Digital Electronics course (BPC-DE1 22/23L) at Brno University of Technology, Czechia. The course provides an introduction to digital technology and covers topics such as digital circuits and Boolean algebra. In this project, we aim to implement a UART (Universal Asynchronous Receiver-Transmitter) communication protocol using VHDL.

### Team members

* Josef Caha    (responsible for ...)
* Jakub Lepík   (responsible for ...)

## Theoretical description and explanation

UART is a hardware communication protocol that is widely used to establish communication between devices. It is a simple and reliable communication protocol used in applications that require low-speed data transfer. The protocol is commonly used for transmitting data between microcontrollers, sensors, and other devices in a system.

The UART interface comprises of two lines, a transmit line (TX) and a receive line (RX). The data is transmitted serially over these lines, with each bit transmitted one after the other. The frame of the UART protocol consists of a start bit, data bits, an optional parity bit, and one or more stop bits. Typically, there are between 5 and 9 data bits, with the parity bit used for error checking.

The start bit signals the beginning of a data transmission, and the stop bit(s) signal the end. The start bit is always a logic low (0), and the stop bit(s) is a logic high (1). The data bits are transmitted in order from the least significant bit to the most significant bit. The parity bit is used to check for errors in the data transmission, with its value being set to ensure that the total number of logic high bits transmitted is either odd or even.

### Transmitter

A transmitter takes a parallel signal with specific configuration settings and converts it into a serial signal. The transmitter then sends the serial signal which includes a start bit, data frame, optional parity bits, and one or two end bits.

### Receiver

To receive data, a receiver takes a serial signal transmitted one bit at a time with specific configuration settings, including a start bit, data frame, optional parity bits, and one or two end bits. The receiver then converts the serial signal into a parallel signal with the original configuration settings, checking for any errors in the received signal using the parity bits (if present), and outputs the resulting parallel signal.

## Hardware description of demo application

Insert descriptive text and schematic(s) of your implementation.

## Software description

Put flowchats/state diagrams of your algorithm(s) and direct links to source/testbench files in `src` and `sim` folders. 

### Component(s) simulation

Write descriptive text and simulation screenshots of your components.

## Instructions

Write an instruction manual for your application, including photos or a link to a video.

## References

https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter
