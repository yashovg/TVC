# Deductive Fault Simulator (C Version)

This project helps you analyze the fault coverage of digital circuits described in structural Verilog. It simulates how well a set of test vectors can detect single stuck-at faults in your circuit. The simulator is written in C and is designed to be easy to use, even for beginners.

---

## 📁 What Files Are Involved?

- **main.c** — The main program. It controls the whole simulation process.
- **fault_simulator.c / fault_simulator.h** — All the core logic for parsing, simulation, and statistics.
- **circuit.v** — Your digital circuit, written in a simple, gate-level Verilog format.
- **vectors.txt** — Test vectors (input patterns), one per line, values separated by spaces.
- **stats.txt** — The output file. Shows which faults were detected and the overall fault coverage.

---

## 🛠️ How Does It Work?

1. **Parse Verilog**: Reads your circuit from `circuit.v`, builds a model, and finds all primary inputs/outputs.
2. **Create Fault List**: Makes a list of all possible single stuck-at faults (each wire stuck at 0 or 1).
3. **Read Test Vectors**: Loads your test patterns from `vectors.txt`.
4. **Simulate**: For each test vector, simulates the circuit and checks which faults are detected.
5. **Statistics**: Writes a detailed report to `stats.txt` (detected/undetected faults, coverage, etc).

---

## 🚀 Step-by-Step Guide

### 1. Describe Your Circuit
- Open `circuit.v` and write your circuit in a simple, structural Verilog style.
- Each input/output should be on its own line, for example:
  ```verilog
  module mux2to1(
      input A
      input B
      input Sel
      output Y
  );
  // ... your gates here ...
  endmodule
  ```

### 2. Create Test Vectors
- Open `vectors.txt`.
- Each line is a test vector: one value per input, separated by spaces, in the order you declared the inputs.
- Example for 3 inputs:
  ```
  0 0 0
  0 1 0
  1 0 1
  ...
  ```

### 3. Build the Simulator
- Open a terminal in the `c_code` directory.
- Run:
  ```sh
  gcc main.c fault_simulator.c -o fault_simulator.exe
  ```

### 4. Run the Simulator
- In the same terminal, run:
  ```sh
  ./fault_simulator.exe circuit.v vectors.txt stats.txt
  ```

### 5. Check the Results
- Open `stats.txt` to see:
  - How many faults were detected
  - How many were missed
  - The overall fault coverage percentage
  - Lists of detected and undetected faults

---

## ℹ️ Tips & Troubleshooting

- **Input count mismatch?**
  - Make sure every line in `vectors.txt` has the same number of values as the number of primary inputs in `circuit.v`.
- **Verilog parsing errors?**
  - Each input/output must be on its own line in the module header. Avoid commas and complex Verilog features.
- **Want to try a different circuit?**
  - Just edit `circuit.v` and `vectors.txt` and re-run the simulator!

---

## 🧑‍💻 Example

See the provided `circuit.v` and `vectors.txt` for a working 2:1 multiplexer example.

---

## 📚 How the Code is Organized

- The code is modular and well-commented. Look in `main.c` and `fault_simulator.c` for explanations of each function and logic block.
- Uses standard C libraries: `<stdio.h>`, `<stdlib.h>`, `<string.h>`, `<stdbool.h>`, `<time.h>`.
- Key functions: file I/O (`fopen`, `fclose`, `fgets`, `fprintf`), memory management (`malloc`, `free`), string handling (`strtok`, `strcpy`, `strcmp`), and more.

---

For questions or improvements, please contact the project maintainer.