# VHDL UART project

This project is part of the Digital Electronics course (BPC-DE1 22/23L) at Brno University of Technology, Czechia. In this project, we aim to implement a UART (Universal Asynchronous Receiver-Transmitter) communication protocol using VHDL.

### Team members

* Josef Caha    (responsible for ...)
* Jakub Lepík   (responsible for ...)

## Theoretical description and explanation

UART is a widely-used hardware communication protocol for establishing communication between devices that require low-speed data transfer. The protocol is simple, reliable and commonly used in microcontroller, sensor, and other device applications. The UART interface consists of two lines, a transmit line (TX) and receive line (RX), and data is transmitted serially over these lines, one bit at a time.

The frame of the UART protocol comprises a start bit, 5-9 data bits, optional parity bit, and one or more stop bits. The start bit indicates the beginning of a data transmission, while the stop bit(s) signal the end. The start bit is always a logic low (0), and the stop bit(s) is a logic high (1). The data bits are transmitted in order from the least significant bit to the most significant bit. The parity bit is used for error checking, with its value being set to ensure that the total number of logic high bits transmitted is either odd or even.

The baud rate is an important parameter of UART communication and refers to the number of bits transmitted per second. To establish successful communication, the baud rate must be the same for both the transmitting and receiving devices. Common baud rates for serial communication include 9600 bps, 19200 bps, and 115200 bps.

### Transmitter

A transmitter takes a parallel signal with specific configuration settings and converts it into a serial signal. The transmitter then sends the serial signal which includes a start bit, data frame, optional parity bits, and one or two end bits.

### Receiver

To receive data, a receiver takes a serial signal transmitted one bit at a time with specific configuration settings, including a start bit, data frame, optional parity bits, and one or two end bits. The receiver then converts the serial signal into a parallel signal with the original configuration settings, checking for any errors in the received signal using the parity bits (if present), and outputs the resulting parallel signal.

## Hardware description of demo application

The demo application is implemented on a Nexys A7 development board with the following hardware components:

- 15 switches: These switches are used to set the data frame and its parameters. Nine switches are used to set the data frame, three switches are used to set the data frame length, one switch is used to enable or disable parity, one switch is used to select parity odd/even, one switch is used to select one or two stop bits, and one switch is used to switch between TX and RX mode.
- 8 digit seven-segment display: This display is used to show the data being transmitted or received.
- 15 LED indicators: These LEDs are used to indicate the state of the UART communication.
- BTNC, BTNL, BTNR, BTNU, BTND buttons: These buttons are used to control the demo application.
- Pmod connector: This connector can be used to connect other peripherals or devices to the board. Only two pins (RX and TX) are used from the PMOD connector.

## Software description

Put flowchats/state diagrams of your algorithm(s) and direct links to source/testbench files in `src` and `sim` folders. 

### Component(s) simulation

Write descriptive text and simulation screenshots of your components.

## Instructions

Write an instruction manual for your application, including photos or a link to a video.

## References

- https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter
- https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual
- https://digilent.com/reference/_media/programmable-logic/nexys-a7/nexys-a7-d3-sch.pdf
