"""
Arduino -> Godot bridge for Microscape (wave-escape).

Reads continuous "<move>,<turn>" values (each in [-1, 1]) streamed every
~20ms by the UNO Q sketch (CountdownTimer.ino, Modulino Movement) and
forwards them as UDP packets to the running Godot game, which reads them
directly in ModulinoInput.gd and applies proportional movement/turning
each physics frame - like a real analog stick, no keyboard/mouse
emulation involved.

Usage:
    python arduino_bridge.py [COM_PORT]

Defaults to COM7 if no port is given. Close the Arduino IDE's Serial
Monitor first - only one program can hold the port open at a time.
"""

import socket
import sys

import serial

DEFAULT_PORT = "COM7"
BAUD_RATE = 9600
UDP_ADDR = ("127.0.0.1", 4243)


def main():
    port = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_PORT
    print(f"Connecting to {port} at {BAUD_RATE} baud...")

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    with serial.Serial(port, BAUD_RATE, timeout=1) as ser:
        print(f"Connected. Forwarding to Godot over UDP at {UDP_ADDR}.")
        print("Press Ctrl+C to stop.")

        try:
            while True:
                line = ser.readline().decode("utf-8", errors="ignore").strip()
                if not line:
                    continue
                sock.sendto(line.encode("utf-8"), UDP_ADDR)
        except KeyboardInterrupt:
            pass
        finally:
            sock.close()
            print("Stopped.")


if __name__ == "__main__":
    main()
