#include "fault_simulator.h"
#include <time.h>

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s <verilog_file> <vectors_file> <output_file>\n", argv[0]);
        return 1;
    }

    srand(time(NULL));
    const char* verilog_filename = argv[1];
    const char* vectors_filename = argv[2];
    const char* output_filename = argv[3];

    printf("Parsing Verilog file: %s\n", verilog_filename);
    Circuit* circuit = parse_verilog(verilog_filename);
    if (!circuit) {
        fprintf(stderr, "Failed to parse Verilog file.\n");
        return 1;
    }
    printf("Parsing complete. Found %d gates, %d inputs, %d outputs.\n", circuit->num_gates, circuit->num_primary_inputs, circuit->num_primary_outputs);

    printf("Creating collapsed fault list...\n");
    create_collapsed_fault_list(circuit);
    printf("Fault list created with %d faults.\n", circuit->num_faults);

    int num_vectors, num_inputs;
    printf("Reading test vectors from: %s\n", vectors_filename);
    int** test_vectors = read_test_vectors(vectors_filename, &num_vectors, &num_inputs);
    if (!test_vectors) {
        fprintf(stderr, "Failed to read test vectors.\n");
        free_circuit(circuit);
        return 1;
    }
    printf("Read %d test vectors with %d inputs each.\n", num_vectors, num_inputs);

    if (num_inputs != circuit->num_primary_inputs) {
        fprintf(stderr, "Error: Number of inputs in vector file (%d) does not match circuit primary inputs (%d).\n", num_inputs, circuit->num_primary_inputs);
        free_circuit(circuit);
        for(int i = 0; i < num_vectors; i++) free(test_vectors[i]);
        free(test_vectors);
        return 1;
    }

    run_deductive_simulation(circuit, test_vectors, num_vectors, num_inputs);
    printf("Generating statistics file: %s\n", output_filename);
    generate_statistics(output_filename, circuit, num_vectors);

    free_circuit(circuit);
    for (int i = 0; i < num_vectors; i++) free(test_vectors[i]);
    free(test_vectors);
    printf("\nFault simulation finished.\n");
    return 0;
}
