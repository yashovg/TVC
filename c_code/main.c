
// Main entry point for the Deductive Fault Simulator
#include "fault_simulator.h"
#include <time.h>


int main(int argc, char *argv[]) {
    // Check for correct usage
    if (argc != 4) {
        fprintf(stderr, "Usage: %s <verilog_file> <vectors_file> <output_file>\n", argv[0]);
        return 1;
    }

    srand(time(NULL)); // Seed random number generator for simulation

    // Parse command-line arguments
    const char* verilog_filename = argv[1];
    const char* vectors_filename = argv[2];
    const char* output_filename = argv[3];

    // 1. Parse the Verilog netlist and build the circuit model
    printf("Parsing Verilog file: %s\n", verilog_filename);
    Circuit* circuit = parse_verilog(verilog_filename);
    if (!circuit) {
        fprintf(stderr, "Failed to parse Verilog file.\n");
        return 1;
    }
    printf("Parsing complete. Found %d gates, %d inputs, %d outputs.\n", 
           circuit->num_gates, circuit->num_primary_inputs, circuit->num_primary_outputs);

    // 2. Generate the collapsed fault list (all single stuck-at faults)
    printf("Creating collapsed fault list...\n");
    create_collapsed_fault_list(circuit);
    printf("Fault list created with %d faults.\n", circuit->num_faults);

    // 3. Read test vectors from file
    int num_vectors, num_inputs;
    printf("Reading test vectors from: %s\n", vectors_filename);
    int** test_vectors = read_test_vectors(vectors_filename, &num_vectors, &num_inputs);
    if (!test_vectors) {
        fprintf(stderr, "Failed to read test vectors.\n");
        free_circuit(circuit);
        return 1;
    }
    printf("Read %d test vectors with %d inputs each.\n", num_vectors, num_inputs);

    // Check that the number of inputs matches the circuit definition
    if (num_inputs != circuit->num_primary_inputs) {
        fprintf(stderr, "Error: Number of inputs in vector file (%d) does not match circuit primary inputs (%d).\n",
                num_inputs, circuit->num_primary_inputs);
        free_circuit(circuit);
        for(int i = 0; i < num_vectors; i++) free(test_vectors[i]);
        free(test_vectors);
        return 1;
    }

    // 4. Run the deductive fault simulation (core logic)
    run_deductive_simulation(circuit, test_vectors, num_vectors, num_inputs);

    // 5. Write statistics to output file
    printf("Generating statistics file: %s\n", output_filename);
    generate_statistics(output_filename, circuit, num_vectors);

    // Clean up all allocated memory
    free_circuit(circuit);
    for (int i = 0; i < num_vectors; i++) {
        free(test_vectors[i]);
    }
    free(test_vectors);

    printf("\nFault simulation finished.\n");
    return 0;
}
