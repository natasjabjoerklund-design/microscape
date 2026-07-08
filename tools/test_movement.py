"""
Standalone move/strafe/look diagnostic - bypasses Godot/UDP entirely.

Prints the raw "<move>,<strafe>,<look>" values straight from the board,
so we can see exactly what sign the sketch is sending when you tilt/spin
it, independent of anything Godot does with that value.

Usage:
    python test_movement.py [COM_PORT]

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
        print("Connected. Tilt/spin the board - watch the values below.")
        print("Press Ctrl+C to stop.\n")

        try:
            while True:
                line = ser.readline().decode("utf-8", errors="ignore").strip()
                if not line:
                    continue

                parts = line.split(",")
                if len(parts) == 3:
                    move, strafe, look = (float(p) for p in parts)
                    if abs(move) > 0.02 or abs(strafe) > 0.02 or abs(look) > 0.02:
                        print(f"move={move:+.3f}  strafe={strafe:+.3f}  look={look:+.3f}")
                else:
                    print(f"(unexpected line): {line}")
        except KeyboardInterrupt:
            print("\nStopped.")


if __name__ == "__main__":
    main()
