# MATLAB Fault Simulator v2 — Beginner Friendly Guide

Welcome! This README explains, in plain language and with step-by-step instructions, how to use the MATLAB Fault Simulator v2. It's written for beginners who may be new to MATLAB or to digital circuit fault simulation.

What this project does (simple overview)
--------------------------------------

- We have a small digital circuit described in a Verilog file (`circuit.v`).
- We have a set of input test vectors in a text file (`vectors.txt`).
- For each single stuck-at fault (a node forced to 0 or forced to 1) we apply all test vectors and see whether any vector makes the circuit outputs different from the correct (fault-free) outputs. If yes, that fault is "detected" by the test set.
- The simulator reports how many faults the tests detect and writes a summary file.

Why v2 is useful
-----------------

- Deterministic and easy to understand: every fault is tested explicitly, so results are reproducible.
- Great for learning and verifying test vectors and small circuits.
- Simpler to extend (e.g., parallelize) before moving to more advanced deductive algorithms.

Files you will see and what they do
----------------------------------

- `main_simulator_v2.m` — top-level script. Edit the filenames at the top if you want to use different files and run this script to execute the whole flow.
- `parse_verilog_v2.m` — a small parser that reads a simplified Verilog netlist and builds an internal `circuit` structure (gates, primary inputs, primary outputs, wires).
- `create_collapsed_fault_list_v2.m` — creates a simple list of faults: for each gate output we create two faults: stuck-at-0 and stuck-at-1.
- `read_test_vectors_v2.m` — reads `vectors.txt`. Supports two formats:
	- Space-separated bits, one vector per line: `0 1 0`
	- Packed string per line: `010`
- `run_deductive_simulation_v2.m` — performs deterministic single-fault injection. For each fault it:
	1) computes the correct outputs for each test vector;
	2) injects the fault and re-simulates for each vector;
	3) if any vector produces a different output, the fault is marked detected.
- `generate_statistics_v2.m` — writes the results into `stats_matlab_v2.txt` (counts and lists of detected/undetected faults).

Very short MATLAB primer (if you're new)
---------------------------------------

- MATLAB programs are stored in `.m` files. Some `.m` files are scripts (no function definition at the top) and some are functions (start with `function ...`).
- To run a script: start MATLAB, change the current folder to the project's folder and type the script name without `.m`.
- To call a function: use its name with parentheses and arguments, for example: `circuit = parse_verilog_v2('circuit.v');`.

Step-by-step: run the simulator (beginner-friendly)
--------------------------------------------------

1) Open MATLAB on your computer.

2) In the MATLAB toolbar or command window change your current folder to the v2 folder. For example, copy-paste this line into MATLAB's command window (adjust path if needed):

```matlab
cd('c:/Users/HP5CD/Desktop/TVC/matlab_code_v2');
```

3) Optionally, open `main_simulator_v2.m` in the MATLAB editor and change the filenames at the top if you want to point to different files (e.g., a different `circuit.v` or `vectors.txt`). The default names are `circuit.v`, `vectors.txt` and the script writes `stats_matlab_v2.txt`.

4) Run the top-level script by typing in the command window:

```matlab
main_simulator_v2;
```

5) Wait for the script to finish. When it's done it writes `stats_matlab_v2.txt`. Open that text file from MATLAB (or any text editor) to see the coverage report.

Example walkthrough (what you will see)
-------------------------------------

- The script prints progress messages: parsing, building fault list, reading vectors, running simulation, and writing statistics.
- `stats_matlab_v2.txt` contains:
	- Circuit summary (number of inputs/outputs, gate count)
	- Total number of collapsed faults (2 per gate output)
	- Number of test vectors applied
	- Number of detected faults and the coverage percentage
	- A list of detected and undetected faults (node name + stuck-at value)

Tips for preparing `circuit.v` and `vectors.txt`
------------------------------------------------

- `circuit.v` should be in a very simple structural Verilog style. Example module header:

```verilog
module myckt(
		input A,
		input B,
		input Sel,
		output Y
);
// gate instances like: and g1 (n1, A, B);
endmodule
```

- `vectors.txt` examples (either format is supported):

Space-separated:
```
0 0 0
0 1 0
1 0 1
```

Packed strings:
```
000
010
101
```

Troubleshooting (common beginner issues)
---------------------------------------

- Problem: "Number of vector inputs does not match circuit primary inputs"
	- Fix: Open `circuit.v` and count the declared `input` lines. Make sure each test vector has the same number of bits (or space-separated values) in the same order.

- Problem: "Cannot open file" or "file not found"
	- Fix: Make sure MATLAB's current folder is `matlab_code_v2` (use the `cd(...)` command shown above), or provide absolute file paths in `main_simulator_v2.m`.

- Problem: Unexpected gate names or wrong outputs
	- Fix: Ensure your gate instances use common names such as `and`, `or`, `nand`, `nor`, `xor`, `xnor`, `not`, `buf`. Unknown gates fall back to a conservative behavior in the demo interpreter.

Performance note
----------------

- The v2 approach tests each fault explicitly. For a circuit with many gates and many vectors this can take time. If you have larger circuits we can:
	- Parallelize the per-fault loop using MATLAB's `parfor` (simple, effective), or
	- Implement the real deductive (symbolic) simulator which is faster for large fault lists but more complex to implement.

What I can do next for you (pick one)
------------------------------------

1) Add parallelization (fast win): make the per-fault loop run in parallel to greatly reduce runtime on multi-core machines.
2) Add unit tests and example circuits: create small test harnesses to verify correctness.
3) Start designing/implementing the deductive simulator (larger task).

Tell me which option you'd like and I will create a short plan and implement it.

----
Open MATLAB, set the current folder to this directory and run:

```matlab
cd('c:/Users/HP5CD/Desktop/TVC/matlab_code_v2');
main_simulator_v2;
```

The script will write `stats_matlab_v2.txt`.

Limitations & next steps
- The interpreter supports common gates (`and`, `or`, `nand`, `nor`, `xor`, `xnor`, `not`, `buf`) but will treat unknown gate types conservatively.
- Performance: for larger circuits, move to a real deductive engine (symbolic propagation) or add parallelization.
