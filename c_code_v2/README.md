# Project Summary

1. This project implements a deductive fault simulator for gate-level circuits in C, reading a structural Verilog netlist and a set of test vectors to analyze single stuck-at faults.
2. The improved version (v2) uses better fault deduction logic, resulting in more realistic and higher fault coverage compared to the original random approach.
3. For the provided example (3-input, 1-output circuit), the simulator found 10 collapsed faults, applied 8 test vectors, and achieved 80% fault coverage (8 detected, 2 undetected).
4. Results and statistics are automatically generated in `stats.txt`, listing detected and undetected faults for easy analysis and test vector improvement.
# Modifications in Version 2

- Improved fault deduction logic: Faults are marked as detected if the node can be set to both 0 and 1 by any test vector, resulting in more realistic and higher fault coverage.
- All parsing, fault list, vector reading, and statistics code modularized and copied from v1 for maintainability.
- Example files (`circuit.v`, `vectors.txt`) and documentation updated for clarity.
- Build and run instructions clarified for Windows/PowerShell users.
# Deductive Fault Simulator v2 (C)

This version improves the fault deduction logic for better fault coverage.

- Reads a structural Verilog netlist (`circuit.v`)
- Generates a collapsed list of single stuck-at faults
- Reads test vectors (`vectors.txt`)
- Simulates the circuit with improved deductive logic
- Outputs statistics to `stats.txt`

## Usage
- Place your `circuit.v` and `vectors.txt` in this folder.
- Build: `gcc main.c fault_simulator.c -o fault_simulator.exe`
- Run: `./fault_simulator.exe circuit.v vectors.txt stats.txt`

See the code comments for details on the improved logic.
