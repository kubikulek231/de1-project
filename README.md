# de1-project
### Team members

* Josef Caha 1 (responsible for ...)
* Jakub Lepík 2 (responsible for ...)

## Theoretical description and explanation

UART (Universal Asynchronous Receiver/Transmitter) is a popular form of serial communication that is used to establish communication between devices. It is a hardware communication protocol used for transmitting data between microcontrollers, sensors, and other devices in a system. 
It is simple and reliable communication protocol widely used in applications that require low-speed data transfer. 
The UART interface consists of two lines: a transmit line (TX) and a receive line (RX). The data is transmitted in a serial format over these lines, with each bit transmitted one after the other.

The frame of the UART protocol consists of a start bit, data bits (typically between 5 and 9 bits), an optional parity bit for error checking, and one or more stop bits. The start bit signals the beginning of a data transmission, and the stop bit(s) signal the end.

##Transmitter

converts paralel signal with given configuration settings to serial one, then transmits:
Start bit, data frame, optional parity bits, end bit

configuration: 8N1 - 1start bit, 8 data bits, 0 parity bits, 1 end bit
## Hardware description of demo application

Insert descriptive text and schematic(s) of your implementation.

## Software description

Put flowchats/state diagrams of your algorithm(s) and direct links to source/testbench files in `src` and `sim` folders. 

### Component(s) simulation

Write descriptive text and simulation screenshots of your components.

## Instructions

Write an instruction manual for your application, including photos or a link to a video.

## References

1. Put here the literature references you used.
2. ...
