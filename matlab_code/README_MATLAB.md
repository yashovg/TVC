# Deductive Fault Simulator (MATLAB Version)

This project implements a deductive fault simulator for single stuck-at faults in gate-level digital circuits using MATLAB.

---

## 📁 File Overview

- `main_simulator.m` — Main script to run the simulation.
- `parse_verilog.m` — Parses the Verilog netlist.
- `create_collapsed_fault_list.m` — Generates the fault list.
- `read_test_vectors.m` — Reads test vectors.
- `run_deductive_simulation.m` — Core simulation logic (demo version).
- `generate_statistics.m` — Writes the output statistics.
- `circuit.v` — Example 2-to-1 multiplexer circuit (structural Verilog).
- `vectors.txt` — Example test vectors.
- `stats_matlab.txt` — Output statistics file (created after running).
- `README_MATLAB.md` — This file.

---

## 🚀 How to Use

### 1. Prepare Your Files

- **Edit `circuit.v`**  
  Describe your circuit in structural Verilog.  
  Each input/output should be declared on its own line, e.g.:
  ```verilog
  module mux2to1(
      input A,
      input B,
      input Sel,
      output Y
  );
  ...
  endmodule
  ```
- **Edit `vectors.txt`**  
  Each line should have one value per input, separated by spaces, in the order the inputs are declared.  
  Example for 3 inputs:
  ```
  0 0 0
  0 1 0
  1 0 1
  ...
  ```

### 2. Run the Simulator

1. Open MATLAB.
2. Navigate to the directory containing all the `.m` files, `circuit.v`, and `vectors.txt`.
3. In the MATLAB command window, run:
   ```
   main_simulator
   ```
   *(You can modify filenames inside `main_simulator.m` if you wish to use different files.)*

### 3. View Results

- After execution, open `stats_matlab.txt` to see:
  - Circuit details
  - Total number of collapsed faults
  # MATLAB Fault Simulation (MATLAB)

  This folder contains a compact MATLAB demonstrator of a gate-level deductive fault simulation flow for single stuck-at faults. The implementation is educational and intentionally simple — it shows the typical stages of a simulation flow (parsing, fault-list creation, applying vectors, simulation, statistics) but is not a production-ready deductive simulator.

  ## What you'll find here

  - `main_simulator.m` — Top-level script that runs the end-to-end flow.
  - `parse_verilog.m` — Lightweight parser for the small subset of Verilog used by the example `circuit.v`.
  - `create_collapsed_fault_list.m` — Builds a collapsed list of single stuck-at faults for gate outputs (SA0 and SA1).
  - `read_test_vectors.m` — Reads test vectors from `vectors.txt` (space-separated or packed strings).
  - `run_deductive_simulation.m` — Demonstration/simplified simulation; it does not implement a full deductive algorithm.
  - `generate_statistics.m` — Produces a human-readable `stats_matlab.txt` report of simulation results.
  - `circuit.v` — Example netlist used by the simulator.
  - `vectors.txt` — Example test vectors.

  ## Brief MATLAB primer (for newcomers)

  - Files with `.m` are either scripts or functions. A script runs top-to-bottom. A function has a signature like `out = myfunc(in)` and lives in its own `.m` file.
  - To run a script: start MATLAB, cd to this directory and type the script name (without `.m`), e.g. `main_simulator`.
  - To call a function: use its name and pass arguments, e.g. `circuit = parse_verilog('circuit.v');`.
  - Matrices and arrays are primary data types; test vectors are represented as numeric matrices of 0s and 1s.

  ## How the simulator works (high level)

  1. `main_simulator.m` sets filenames and orchestrates the workflow.
  2. `parse_verilog` reads a simplified Verilog netlist and returns a `circuit` struct containing gates, primary inputs/outputs, and wires.
  3. `create_collapsed_fault_list` enumerates collapsed single stuck-at faults (one SA0 and one SA1 per gate output).
  4. `read_test_vectors` loads vectors from `vectors.txt` into an NxM matrix (N vectors, M inputs).
  5. `run_deductive_simulation` (demo) applies vectors and updates `fault_list` detected flags. The real deductive algorithm symbolically propagates fault lists through gates and merges/reduces them; that is not implemented here.
  6. `generate_statistics` writes `stats_matlab.txt` summarizing the results.

  ## Function contracts / file details

  - `main_simulator.m`
    - Inputs: none (edit the filename variables at the top of the script to change inputs/outputs)
    - Outputs: writes `stats_matlab.txt` (or the configured output filename)
    - Behavior: coordinates parsing, fault-list creation, vector reading, simulation and statistics generation.

  - `circuit = parse_verilog(filename)`
    - Inputs: `filename` (string) — Verilog file path
    # MATLAB Fault Simulation (MATLAB)

    This folder contains a compact MATLAB demonstrator of a gate-level deductive fault simulation flow for single stuck-at faults. The implementation is educational and intentionally simple — it shows the typical stages of a simulation flow (parsing, fault-list creation, applying vectors, simulation, statistics) but is not a production-ready deductive simulator.

    ## What you'll find here

    - `main_simulator.m` — Top-level script that runs the end-to-end flow.
    - `parse_verilog.m` — Lightweight parser for the small subset of Verilog used by the example `circuit.v`.
    - `create_collapsed_fault_list.m` — Builds a collapsed list of single stuck-at faults for gate outputs (SA0 and SA1).
    - `read_test_vectors.m` — Reads test vectors from `vectors.txt` (space-separated or packed strings).
    - `run_deductive_simulation.m` — Demonstration/simplified simulation; it does not implement a full deductive algorithm.
    - `generate_statistics.m` — Produces a human-readable `stats_matlab.txt` report of simulation results.
    - `circuit.v` — Example netlist used by the simulator.
    - `vectors.txt` — Example test vectors.

    ## Brief MATLAB primer (for newcomers)

    - Files with `.m` are either scripts or functions. A script runs top-to-bottom. A function has a signature like `out = myfunc(in)` and lives in its own `.m` file.
    - To run a script: start MATLAB, cd to this directory and type the script name (without `.m`), e.g. `main_simulator`.
    - To call a function: use its name and pass arguments, e.g. `circuit = parse_verilog('circuit.v');`.
    - Matrices and arrays are primary data types; test vectors are represented as numeric matrices of 0s and 1s.

    ## How the simulator works (high level)

    1. `main_simulator.m` sets filenames and orchestrates the workflow.
    2. `parse_verilog` reads a simplified Verilog netlist and returns a `circuit` struct containing gates, primary inputs/outputs, and wires.
    3. `create_collapsed_fault_list` enumerates collapsed single stuck-at faults (one SA0 and one SA1 per gate output).
    4. `read_test_vectors` loads vectors from `vectors.txt` into an NxM matrix (N vectors, M inputs).
    5. `run_deductive_simulation` (demo) applies vectors and updates `fault_list` detected flags. The real deductive algorithm symbolically propagates fault lists through gates and merges/reduces them; that is not implemented here.
    6. `generate_statistics` writes `stats_matlab.txt` summarizing the results.

    ## Function contracts / file details

    - `main_simulator.m`
      - Inputs: none (edit the filename variables at the top of the script to change inputs/outputs)
      - Outputs: writes `stats_matlab.txt` (or the configured output filename)
      - Behavior: coordinates parsing, fault-list creation, vector reading, simulation and statistics generation.

    - `circuit = parse_verilog(filename)`
      - Inputs: `filename` (string) — Verilog file path
      - Outputs: `circuit` struct with:
        - `gates` (struct array): `name`, `type`, `output`, `inputs`
        - `primaryInputs` (cell array of strings)
        - `primaryOutputs` (cell array of strings)
        - `wires` (cell array of strings)
      - Note: Assumes a very simple structural Verilog syntax like the example `circuit.v`.

    - `[circuit, fault_list] = create_collapsed_fault_list(circuit)`
      - Inputs: parsed `circuit`
      - Outputs: updated `circuit` and `fault_list` (struct array with `node_name`, `stuck_at_value`, `detected`)

    - `test_vectors = read_test_vectors(filename)`
      - Inputs: path to vector text file
      - Outputs: numeric matrix NxM (N vectors, M inputs). Supports both space-separated values and packed strings.

    - `fault_list = run_deductive_simulation(circuit, fault_list, test_vectors)`
      - Inputs: `circuit`, `fault_list`, `test_vectors`
      - Outputs: updated `fault_list` with `.detected` flags. Current implementation is a placeholder.

    - `generate_statistics(filename, circuit, fault_list, num_vectors)`
      - Inputs: output filename string, `circuit`, `fault_list`, and number of applied vectors
      - Outputs: writes a text report with circuit summary, fault counts, lists of detected/undetected faults and coverage.

    ## Example — run the simulator

    Start MATLAB and run the top-level script. You can either run the script directly or edit the filenames in `main_simulator.m`.

    In MATLAB:

    ```matlab
    cd('c:/Users/HP5CD/Desktop/TVC/matlab_code');
    main_simulator;
    ```

    By default the script expects `circuit.v` and `vectors.txt` in the same folder and writes `stats_matlab.txt`.

    ## Expected output

    - `stats_matlab.txt` — contains:
      - Circuit details (PI/PO lists and gate count)
      - Total collapsed fault count
      - Number of test vectors applied
      - Counts of detected and undetected faults
      - Fault coverage percentage
      - Lists of detected and undetected faults

    ## Known limitations

    - The Verilog parser is minimal and only supports the specific, simple format used by the example netlist. It will not parse complex Verilog features.
    - `run_deductive_simulation` is not a full deductive simulation: it is a demonstrator that randomly marks faults detected. Replace with a complete algorithm for real results.
    - Fault collapsing is simplistic: faults are placed on gate outputs only.

    ## Suggested next steps / improvements

    - Implement a full deductive fault propagation engine (complex but well-scoped).
    - Improve the Verilog parser to accept more Verilog constructs or integrate a proper parser.
    - Add unit tests for parsing, vector reading, and statistics generation.
    - Add command-line parameters or a wrapper script to batch-run experiments and aggregate results.

    ## Troubleshooting

    - If MATLAB reports "cannot open file" errors, ensure your working directory is set correctly and filenames are correct.
    - If you see "number of inputs in vector file does not match circuit PI count", verify the ordering and count of inputs in `circuit.v` and formatting of `vectors.txt`.

    ## License / Credits

    Educational/demo code — use at your own risk. Credit to the original author(s) of this repository.

    ---

    If you'd like, I can implement a proper deductive simulator, add unit tests, or expand the Verilog parser — tell me which and I'll create a plan and start working.
