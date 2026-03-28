# SNES Hello World

A small SNES **Hello World** project built with **65816 assembly** and a simple **C# build runner**.

The assembly source creates a self-contained **LoROM** demo that loads palette, tile graphics, and tilemap data directly in code, then builds a `helloworld.sfc` ROM :contentReference[oaicite:0]{index=0}

## What’s included

- `main.asm` — SNES assembly source
- `Program.cs` — runs the assembler and linker
- `linkfile` — linker input
- output: `helloworld.sfc`

## What you need to add

This repo does **not** include the WLA-DX executables.

Place these files next to the project files:

- `wla-65816.exe`
- `wlalink.exe`

## Expected folder layout

```text
/project-folder
  main.asm
  Program.cs
  linkfile
  wla-65816.exe
  wlalink.exe
