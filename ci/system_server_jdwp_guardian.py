#!/usr/bin/env python3
"""Keep a passive JDWP connection to every current system_server generation.

Only the JDWP handshake is exchanged: no suspend, event, or method requests are
sent. Android's Watchdog uses Debug.isDebuggerConnected() to avoid killing a
system process while it is being inspected. This is an OS-test safeguard; it
never attaches to or modifies the game.
"""
import argparse
import select
import socket
import subprocess
import time


def log(message):
    print(f"{time.strftime('%Y-%m-%dT%H:%M:%S')} {message}", flush=True)


def adb(adb_path, serial, *args, timeout=20):
    return subprocess.run(
        [adb_path, "-s", serial, *args],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        timeout=timeout,
        check=False,
    ).stdout.strip()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--adb", required=True)
    parser.add_argument("--serial", default="emulator-5554")
    args = parser.parse_args()
    connections = {}
    failures = {}
    log("GUARDIAN_START passive system_server JDWP only")
    while True:
        try:
            current = adb(args.adb, args.serial, "shell", "pidof", "system_server", timeout=15)
            pid = current.split()[0] if current.split() else None
            for old_pid, (sock, port) in list(connections.items()):
                closed = False
                try:
                    readable, _, _ = select.select([sock], [], [], 0)
                    if readable and not sock.recv(1):
                        closed = True
                except (BlockingIOError, InterruptedError):
                    pass
                except OSError:
                    closed = True
                if old_pid != pid or closed:
                    log(f"JDWP_CLOSED pid={old_pid} port={port} current_pid={pid} closed={closed}")
                    sock.close()
                    connections.pop(old_pid, None)
                    adb(args.adb, args.serial, "forward", "--remove", f"tcp:{port}")
            if pid and pid not in connections:
                now = time.monotonic()
                if now - failures.get(pid, 0) >= 2:
                    failures[pid] = now
                    forwarded = adb(args.adb, args.serial, "forward", "tcp:0", f"jdwp:{pid}")
                    try:
                        port = int(forwarded.splitlines()[-1].strip())
                        sock = socket.create_connection(("127.0.0.1", port), timeout=8)
                        sock.settimeout(8)
                        sock.sendall(b"JDWP-Handshake")
                        response = b""
                        while len(response) < 14:
                            chunk = sock.recv(14 - len(response))
                            if not chunk:
                                raise RuntimeError("EOF during JDWP handshake")
                            response += chunk
                        if response != b"JDWP-Handshake":
                            raise RuntimeError(f"Unexpected JDWP handshake: {response!r}")
                        sock.setblocking(False)
                        connections[pid] = (sock, port)
                        log(f"JDWP_ATTACHED pid={pid} port={port} handshake=ok requests=none")
                    except Exception as exc:
                        log(f"JDWP_ATTACH_RETRY pid={pid} forward={forwarded!r} error={exc!r}")
                        try:
                            sock.close()
                        except Exception:
                            pass
            time.sleep(1)
        except Exception as exc:
            log(f"GUARDIAN_RETRY error={exc!r}")
            time.sleep(2)


if __name__ == "__main__":
    main()
