#!/usr/bin/env python3
# ./uart_loopback_test.py /dev/tty.usbserial-K00027 --baudrate 9600

import argparse
import os
import random
import serial
import signal
import sys
import time
from typing import Optional

# ----------------------------------------------------------------------
# UART Loopback Tester
# ----------------------------------------------------------------------
# Sends random 32-byte chunks to a UART device in loopback mode,
# verifies echo, reports throughput and stops on first mismatch or CTRL+C.
#
# Example usage:
#   ./uart_loopback_test.py /dev/tty.usbserial-K00027 --baudrate 115200
# ----------------------------------------------------------------------


class GracefulExit(Exception):
    """Raised on SIGINT to exit cleanly."""

    pass


def signal_handler(signum, frame):
    raise GracefulExit()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="UART loopback tester: send random data, verify echo, report stats."
    )
    parser.add_argument(
        "device",
        help="Serial device path, e.g. /dev/tty.usbserial-K00027",
    )
    parser.add_argument(
        "--baudrate",
        type=int,
        default=115200,
        help="Baud rate (default: 115200)",
    )
    parser.add_argument(
        "--chunk-size",
        type=int,
        default=32,
        help="Number of random bytes per transaction (default: 32)",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=1.0,
        help="Serial read timeout in seconds (default: 1.0)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    # Register CTRL+C handler
    signal.signal(signal.SIGINT, signal_handler)

    ser = serial.Serial(
        port=args.device,
        baudrate=args.baudrate,
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        timeout=args.timeout,
        xonxoff=False,
        rtscts=False,
        dsrdtr=False,
    )

    print(f"Opened {args.device} @ {args.baudrate} baud")
    print(f"Sending {args.chunk_size}-byte random chunks (CTRL+C to stop)...")
    print("-" * 60)

    total_bytes_sent: int = 0
    total_chunks: int = 0
    start_time: float = time.monotonic()
    error: Optional[str] = None

    try:
        while True:
            # Generate random payload
            payload = bytes(random.randint(0, 255) for _ in range(args.chunk_size))

            # Transmit
            ser.write(payload)
            total_bytes_sent += len(payload)
            total_chunks += 1

            # Receive echo
            echo = ser.read(args.chunk_size)

            if len(echo) != args.chunk_size:
                error = f"Short read: expected {args.chunk_size}, got {len(echo)}"
                break

            if echo != payload:
                # Find first mismatch for nice reporting
                mismatch_idx = next(
                    (i for i, (a, b) in enumerate(zip(payload, echo)) if a != b), None
                )
                error = f"Mismatch at byte {mismatch_idx}: sent 0x{payload[mismatch_idx]:02X}, got 0x{echo[mismatch_idx]:02X}"
                break

    except GracefulExit:
        print("\nInterrupted by user.")
    except serial.SerialException as e:
        print(f"\nSerial error: {e}", file=sys.stderr)
        sys.exit(1)
    finally:
        ser.close()

    # ------------------------------------------------------------------
    # Statistics
    # ------------------------------------------------------------------
    elapsed = time.monotonic() - start_time
    if elapsed <= 0:
        elapsed = 1e-9  # avoid division by zero

    avg_bps = total_bytes_sent / elapsed

    print("-" * 60)
    if error:
        print(f"FAIL: {error}")
        print(f"Successful bytes before error: {total_bytes_sent}")
    else:
        print("Stopped cleanly (CTRL+C).")
        print(f"Total bytes sent: {total_bytes_sent}")

    print(f"Elapsed time: {elapsed:.3f} s")
    print(f"Average throughput: {avg_bps:,.0f} bytes/sec ({avg_bps * 8:,.0f} bps)")


if __name__ == "__main__":
    main()
