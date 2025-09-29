# Code Structure & Flow

The simulator is organized into modular C files:
- `main.c`: Orchestrates the simulation process (parsing, fault list, vectors, simulation, stats, cleanup).
- `fault_simulator.c`/`.h`: Implements all core logic, data structures, and helper functions.
- `circuit.v`: Structural Verilog netlist (inputs/outputs/gates, one per line, simple format).
- `vectors.txt`: Test vectors (space-separated, one per line, order matches input declaration).
- `stats.txt`: Output statistics (detected/undetected faults, coverage, etc).

# How the Simulator Works
1. **Parse Verilog**: Reads the netlist, builds a gate-level model, and identifies primary inputs/outputs.
2. **Create Fault List**: Generates a collapsed list of all single stuck-at faults (SA0/SA1) for each node.
3. **Read Test Vectors**: Loads test vectors, checks for input count match.
4. **Simulate**: For each vector, simulates the circuit and (in v1) randomly marks faults as detected (for demo). In v2, uses improved logic based on node controllability.
5. **Statistics**: Writes a detailed report to `stats.txt`.

# Pre-defined Headers and Functions Used

- `<stdio.h>`: Standard I/O (e.g., `printf`, `fprintf`, `fopen`, `fclose`)
- `<stdlib.h>`: Memory management (`malloc`, `free`, `realloc`), conversions (`atoi`)
- `<string.h>`: String operations (`strcpy`, `strcmp`, `strtok`, `strdup`)
- `<stdbool.h>`: Boolean type (`bool`, `true`, `false`)
- `<time.h>`: Random seed (`time`, `srand`)

**Key Functions:**
- `fopen`, `fclose`, `fgets`, `fprintf`, `printf`: File and console I/O
- `malloc`, `realloc`, `free`: Dynamic memory management
- `strtok`, `strcpy`, `strcmp`, `strdup`: String parsing and copying
- `atoi`: String to integer conversion

# Code Comments and Documentation

All major functions and logic blocks are commented to explain their purpose and flow. See `main.c` and `fault_simulator.c` for inline comments describing each step, data structure, and algorithm.

---
gcc main.c fault_simulator.c -o fault_simulator

# Deductive Fault Simulator (C)

This project implements a deductive fault simulator for gate-level digital circuits described in structural Verilog. It generates statistics about single stuck-at faults detected by a set of test vectors.

## Features
- Reads a gate-level circuit netlist from a structural Verilog file (`circuit.v`).
- Prepares a collapsed list of single stuck-at faults.
- Reads test vectors from a file (`vectors.txt`).
- Simulates the circuit for each test vector and generates fault coverage statistics in `stats.txt`.

## File Structure
- `main.c` — Entry point, manages the simulation flow.
- `fault_simulator.c` / `fault_simulator.h` — Core logic for parsing, simulation, and statistics.
- `circuit.v` — Example Verilog netlist (2:1 multiplexer).
- `vectors.txt` — Example test vectors (space-separated, one vector per line).
- `stats.txt` — Output file with simulation statistics.

## How to Use

### 1. Prepare Your Files
- **Edit `circuit.v`** to describe your circuit in structural Verilog. Each input/output should be declared on its own line, e.g.:
	```verilog
	module mux2to1(
	input A
	input B
	input Sel
	output Y
	);
	...
	endmodule
	```
- **Edit `vectors.txt`** to provide test vectors. Each line should have one value per input, separated by spaces, in the order the inputs are declared.
	Example for 3 inputs:
	```
	0 0 0
	0 1 0
	1 0 1
	...
	```

### 2. Build the Simulator
Open a terminal in the `c_code` directory and run:
```sh
gcc main.c fault_simulator.c -o fault_simulator.exe
```

### 3. Run the Simulator
```sh
./fault_simulator.exe circuit.v vectors.txt stats.txt
```

### 4. View Results
- Open `stats.txt` to see detected/undetected faults and fault coverage.

## Notes
- The simulator counts each primary input as a gate for internal modeling. Thus, the gate count in stats includes both logic gates and inputs.
- The current simulation logic randomly marks faults as detected for demonstration. For a real deductive simulation, further logic is needed.
- The Verilog parser expects a simple, structural format. Avoid complex Verilog constructs.

## Troubleshooting
- If you see an error about input count mismatch, check that each line in `vectors.txt` has the same number of values as the number of primary inputs in `circuit.v`.
- If the simulator fails to parse your Verilog, ensure each input/output is on its own line and there are no commas.

## Example
See the provided `circuit.v` and `vectors.txt` for a working 2:1 multiplexer example.

---
For questions or improvements, please contact the project maintainer.