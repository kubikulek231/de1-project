# de1-project
### Team members

* Josef Caha 1 (responsible for ...)
* Jakub Lepík 2 (responsible for ...)

## Theoretical description and explanation

UART is a hardware communication protocol that is widely used to establish communication between devices. It is a simple and reliable communication protocol used in applications that require low-speed data transfer. The protocol is commonly used for transmitting data between microcontrollers, sensors, and other devices in a system.

The UART interface comprises of two lines, a transmit line (TX) and a receive line (RX). The data is transmitted serially over these lines, with each bit transmitted one after the other. The frame of the UART protocol consists of a start bit, data bits, an optional parity bit, and one or more stop bits. Typically, there are between 5 and 9 data bits, with the parity bit used for error checking.

The start bit signals the beginning of a data transmission, and the stop bit(s) signal the end. The start bit is always a logic low (0), and the stop bit(s) is a logic high (1). The data bits are transmitted in order from the least significant bit to the most significant bit. The parity bit is used to check for errors in the data transmission, with its value being set to ensure that the total number of logic high bits transmitted is either odd or even.

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
