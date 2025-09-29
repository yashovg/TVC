#ifndef FAULT_SIMULATOR_H
#define FAULT_SIMULATOR_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// Gate types
typedef enum {
    INPUT, OUTPUT, AND, OR, NOT, NAND, NOR, XOR, XNOR, BUF
} GateType;

// Logic values
typedef enum {
    ZERO, ONE, X
} LogicValue;

// Fault structure
typedef struct {
    char node_name[256];
    int stuck_at_value; // 0 or 1
    bool detected;
} Fault;

// Gate structure
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
    Fault* faults[2];
} Gate;

// Circuit structure
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

Circuit* parse_verilog(const char* filename);
void create_collapsed_fault_list(Circuit* circuit);
int** read_test_vectors(const char* filename, int* num_vectors, int* num_inputs);
void run_deductive_simulation(Circuit* circuit, int** test_vectors, int num_vectors, int num_inputs);
void generate_statistics(const char* filename, const Circuit* circuit, int num_vectors);
void free_circuit(Circuit* circuit);

#endif // FAULT_SIMULATOR_H
