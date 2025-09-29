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
  - Number of test vectors applied
  - Number of detected and undetected faults
  - Fault coverage percentage
  - Lists of detected and undetected faults

---

## 🛠 Troubleshooting

- **Input count mismatch:**  
  Ensure each line in `vectors.txt` matches the number of primary inputs in `circuit.v`.
- **Verilog parsing errors:**  
  Make sure each input/output is on its own line in the module header, and avoid complex Verilog constructs.

---

## ℹ️ Important Note

The `run_deductive_simulation.m` function is a simplified placeholder. A full implementation of deductive fault simulation requires more complex logic for propagating fault lists through the circuit. This version demonstrates the structure and statistics generation, but randomly marks faults as detected.

---