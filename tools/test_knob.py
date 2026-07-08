"""
Standalone knob diagnostic - bypasses Godot/UDP entirely.

Opens the UNO Q's serial port directly and prints exactly what the board
sends, so we can see the raw move/turn/knob values with nothing else in
the way. Turn the Modulino Knob and watch the "knob" number: it should
swing smoothly from 0 towards +1.000 one way and -1.000 the other way,
the same shape as pressing "+" or "-" repeatedly.

If the knob module isn't wired/detected, you'll see KNOB_NOT_FOUND once
at startup and the knob value will stay frozen at 0.000 no matter how
much you turn it - that tells us it's a wiring/connection issue, not
a software one.

Usage:
    python test_knob.py [COM_PORT]

Close the Arduino IDE's Serial Monitor and stop arduino_bridge.py first -
only one program can hold the port open at a time.
"""

import sys

import serial

DEFAULT_PORT = "COM7"
BAUD_RATE = 9600


def main():
    port = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_PORT
    print(f"Connecting to {port} at {BAUD_RATE} baud...")

    with serial.Serial(port, BAUD_RATE, timeout=1) as ser:
        print("Connected. Turn the knob - watch the 'knob' value below.")
        print("Press Ctrl+C to stop.\n")

        try:
            while True:
                line = ser.readline().decode("utf-8", errors="ignore").strip()
                if not line:
                    continue

                if line == "KNOB_NOT_FOUND":
                    print("!!! KNOB_NOT_FOUND - the board can't see a Knob module on the bus !!!")
                    continue

                parts = line.split(",")
                if len(parts) == 3:
                    move, turn, knob = parts
                    knob_val = float(knob)
                    sign = "+" if knob_val >= 0 else "-"
                    bar_len = round(abs(knob_val) * 20)
                    bar = "#" * bar_len + "." * (20 - bar_len)
                    print(f"knob: {sign}{abs(knob_val):.3f}  [{bar}]  (move={move}, turn={turn})")
                else:
                    print(f"(unexpected line, only 2 values - is the sketch's knob code live?): {line}")
        except KeyboardInterrupt:
            print("\nStopped.")


if __name__ == "__main__":
    main()
