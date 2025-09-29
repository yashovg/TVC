#ifndef FAULT_SIMULATOR_H
#define FAULT_SIMULATOR_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Represents the type of a gate
typedef enum {
    INPUT,
    OUTPUT,
    AND,
    OR,
    NOT,
    NAND,
    NOR,
    XOR,
    XNOR,
    BUF
} GateType;

// Represents a logic value
typedef enum {
    ZERO,
    ONE,
    D,
    D_BAR,
    X // Represents an unknown value
} LogicValue;


// Represents a single stuck-at fault
typedef struct {
    char node_name[256];
    int stuck_at_value; // 0 for stuck-at-0, 1 for stuck-at-1
    bool detected;
} Fault;

// Represents a gate in the circuit
typedef struct Gate {
    char name[256];
    GateType type;
    char inputs[2][256];
    char output[256];
    int num_inputs;
    LogicValue value;
    struct Gate* fanins[2];
    struct Gate** fanouts;
    int fanout_count;
    Fault* faults[2]; // Index 0 for SA0, 1 for SA1
} Gate;

// Represents the entire circuit
typedef struct {
    Gate* gates;
    int num_gates;
    char** primary_inputs;
    int num_primary_inputs;
    char** primary_outputs;
    int num_primary_outputs;
    Fault* faults;
    int num_faults;
} Circuit;

/**
 * @brief Parses a structural Verilog file to build a circuit representation.
 *
 * @param filename The path to the Verilog file.
 * @return A pointer to the created Circuit structure.
 */
Circuit* parse_verilog(const char* filename);

/**
 * @brief Creates a collapsed list of single stuck-at faults for the circuit.
 *
 * @param circuit A pointer to the circuit.
 */
void create_collapsed_fault_list(Circuit* circuit);

/**
 * @brief Reads test vectors from a file.
 *
 * @param filename The path to the test vector file.
 * @param num_vectors A pointer to store the number of vectors read.
 * @param num_inputs A pointer to store the number of inputs per vector.
 * @return A 2D array of test vectors.
 */
int** read_test_vectors(const char* filename, int* num_vectors, int* num_inputs);

/**
 * @brief Runs the deductive fault simulation.
 *
 * @param circuit A pointer to the circuit.
 * @param test_vectors The test vectors to apply.
 * @param num_vectors The number of test vectors.
 * @param num_inputs The number of inputs per vector.
 */
void run_deductive_simulation(Circuit* circuit, int** test_vectors, int num_vectors, int num_inputs);

/**
 * @brief Generates a statistics file with the fault simulation results.
 *
 * @param filename The path to the output statistics file.
 * @param circuit A pointer to the circuit.
 * @param num_vectors The total number of test vectors applied.
 */
void generate_statistics(const char* filename, const Circuit* circuit, int num_vectors);

/**
 * @brief Frees the memory allocated for the circuit.
 *
 * @param circuit A pointer to the circuit.
 */
void free_circuit(Circuit* circuit);

#endif // FAULT_SIMULATOR_H
