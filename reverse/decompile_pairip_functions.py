#!/usr/bin/env python3
"""Decompile selected libpairipcore functions from the saved Ghidra project."""
import argparse
import os
import pathlib

parser = argparse.ArgumentParser()
parser.add_argument("addresses", nargs="+", help="Ghidra addresses, e.g. 0x169eb4")
parser.add_argument("--out", type=pathlib.Path, default=pathlib.Path("reverse/pairip-ghidra-c"))
parser.add_argument("--ghidra-install-dir", default="/home/user/.cache/ghidra/ghidra_11.3.2_PUBLIC")
parser.add_argument("--project-path", default="/home/user/.cache/ghidra/projects")
parser.add_argument("--project", default="Pairip")
parser.add_argument("--program", default="libpairipcore.so")
args = parser.parse_args()

os.environ["GHIDRA_INSTALL_DIR"] = args.ghidra_install_dir
import pyhidra
pyhidra.start(verbose=False)
from ghidra.base.project import GhidraProject
from ghidra.app.decompiler import DecompInterface, DecompileOptions
from ghidra.program.flatapi import FlatProgramAPI
from ghidra.util.task import ConsoleTaskMonitor

project = GhidraProject.openProject(os.path.abspath(args.project_path), args.project, True)
program = project.openProgram("/", args.program, False)
flatapi = FlatProgramAPI(program)
decomp = DecompInterface()
decomp.setOptions(DecompileOptions())
decomp.openProgram(program)
monitor = ConsoleTaskMonitor()
args.out.mkdir(parents=True, exist_ok=True)

for raw in args.addresses:
    value = int(raw, 0)
    addr = flatapi.toAddr(value)
    func = flatapi.getFunctionContaining(addr)
    if func is None:
        # Indirectly used thread entry points are not always recovered by the
        # initial auto-analysis. Create a function at the exact known entry.
        flatapi.disassemble(addr)
        func = flatapi.createFunction(addr, f"FUN_{value:08x}")
    if func is None:
        print(f"{raw}: no containing function and unable to create one")
        continue
    entry = func.getEntryPoint().getOffset()
    result = decomp.decompileFunction(func, 300, monitor)
    if not result.decompileCompleted():
        print(f"{raw}: decompilation failed: {result.getErrorMessage()}")
        continue
    out = args.out / f"func_{entry:08x}.c"
    out.write_text(result.getDecompiledFunction().getC())
    print(f"{raw}: {func.getName()} at 0x{entry:x} -> {out}")

program.release(project)
project.close()
