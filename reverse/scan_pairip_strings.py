#!/usr/bin/env python3
"""Heuristic PairIP string scanner based on MatrixEditor/pairipcore-vm.

This does not execute or modify protected code. It decodes candidate strings
from a bytecode asset with either a supplied 255-byte key or the documented
research key, using the public project's address and XOR scheme.
"""
import argparse
import ast
from pathlib import Path

RESEARCH_SOURCE = Path('/home/user/.cache/bus-recovery/pairipcore-vm/pairipcore/strings.py')


def documented_key():
    tree = ast.parse(RESEARCH_SOURCE.read_text())
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(isinstance(t, ast.Name) and t.id == 'KEY' for t in node.targets):
            return ast.literal_eval(node.value)
    raise RuntimeError('documented KEY not found')


def decode_address(encoded, size):
    return ((encoded ^ ((~size) & 0xffffffff)) & 0xffffffff) % size


def find_key(data):
    """Port of pairipcore-vm's two-candidate dynamic key search."""
    size = len(data)
    upper_bound = size - 2
    candidates = set()
    formats = [(loads, extras) for loads in range(1, 6) for extras in range(0, 6)]
    position = 8
    while position < upper_bound:
        position += 2  # opcode is not needed by the public heuristic
        found = False
        for loads, extras in formats:
            info = position + loads * 4
            end = info + 26 + extras * 4
            if end > size:
                continue
            hash_length = int.from_bytes(data[info + 16:info + 18], 'little')
            if not 2 <= hash_length <= 6:
                continue
            encoded = [int.from_bytes(data[position + i * 4:position + i * 4 + 4], 'little')
                       for i in range(loads)]
            encoded += [int.from_bytes(data[info + 26 + i * 4:info + 30 + i * 4], 'little')
                        for i in range(extras)]
            addresses = [decode_address(value, size) for value in encoded]
            for key_index, key_address in enumerate(addresses):
                if key_address + 0xff >= upper_bound:
                    continue
                key_data = data[key_address:key_address + 0xff]
                key_length = int.from_bytes(key_data[:2], 'little')
                for data_index, data_address in enumerate(addresses):
                    if data_index == key_index or data_address + 2 >= upper_bound:
                        continue
                    data_length = int.from_bytes(data[data_address:data_address + 2], 'little')
                    length = (key_length ^ data_length) + 2
                    if length > 1000 or length < 5 or data_address + length >= upper_bound:
                        continue
                    encrypted = data[data_address + 2:data_address + length]
                    plain = bytes(value ^ key_data[(index + 2) % 0xff]
                                  for index, value in enumerate(encrypted))
                    if not all(0x21 <= value <= 0x7e for value in plain):
                        continue
                    if key_address in candidates:
                        return key_address
                    if data_address in candidates:
                        return data_address
                    candidates.update((key_address, data_address))
                    found = True
                    break
                if found:
                    break
            if found:
                position += 0x1a + (loads + extras) * 4
                break
    raise RuntimeError('key not found')


def scan(data, key, min_length=3):
    size = len(data)
    key_length = int.from_bytes(key[:2], 'little')
    found = {}
    for position in range(8, size - 4):
        encoded = int.from_bytes(data[position:position + 4], 'little')
        address = decode_address(encoded, size)
        if address + 4 >= size:
            continue
        data_length = int.from_bytes(data[address:address + 2], 'little')
        length = (key_length ^ data_length) + 2
        if not min_length + 2 <= length <= 1000 or address + length > size:
            continue
        encrypted = data[address + 2:address + length]
        plain = bytes(value ^ key[(index + 2) % 0xff]
                      for index, value in enumerate(encrypted))
        if all(0x20 <= value <= 0x7e for value in plain):
            found.setdefault(address, plain)
    return found


def scan_lengths(data, key, min_length=3, step=2):
    size = len(data)
    key_length = int.from_bytes(key[:2], 'little')
    found = {}
    for address in range(8, size - 4, step):
        data_length = int.from_bytes(data[address:address + 2], 'little')
        length = (key_length ^ data_length) + 2
        if not min_length + 2 <= length <= 1000 or address + length > size:
            continue
        encrypted = data[address + 2:address + length]
        plain = bytes(value ^ key[(index + 2) % 0xff]
                      for index, value in enumerate(encrypted))
        if all(0x20 <= value <= 0x7e for value in plain):
            found[address] = plain
    return found


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('asset', type=Path)
    parser.add_argument('--key', type=Path, help='raw 255-byte key file; defaults to documented research key')
    parser.add_argument('--find-key', action='store_true', help='dynamically locate and use the asset key')
    parser.add_argument('--key-output', type=Path, help='save the dynamically discovered raw key')
    parser.add_argument('--length-based', action='store_true', help='scan data offsets instead of encoded pointers')
    parser.add_argument('--length-step', type=int, default=2, help='offset increment for length-based scanning')
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    data = args.asset.read_bytes()
    if args.find_key:
        key_address = find_key(data)
        key = data[key_address:key_address + 0xff]
        print(f'dynamic key offset={key_address:#x} material={key.hex()}')
        if args.key_output:
            args.key_output.write_bytes(key)
    else:
        key = args.key.read_bytes() if args.key else documented_key()
    if len(key) < 255:
        raise SystemExit(f'key too short: {len(key)}')
    if args.length_step < 1:
        raise SystemExit('length step must be positive')
    results = scan_lengths(data, key, step=args.length_step) if args.length_based else scan(data, key)
    lines = [f'{address:#08x}: {value.decode("ascii")}' for address, value in sorted(results.items())]
    text = '\n'.join(lines) + ('\n' if lines else '')
    if args.output:
        args.output.write_text(text)
    print(f'asset={args.asset} candidates={len(results)}')
    print(text[:20000], end='')


if __name__ == '__main__':
    main()
