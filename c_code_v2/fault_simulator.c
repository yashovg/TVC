#include "fault_simulator.h"

// Helper: Find gate by name
Gate* find_gate(Circuit* circuit, const char* name) {
    for (int i = 0; i < circuit->num_gates; i++) {
        if (strcmp(circuit->gates[i].name, name) == 0 || strcmp(circuit->gates[i].output, name) == 0) {
            return &circuit->gates[i];
        }
    }
    return NULL;
}

// Helper: Gate type string to enum
GateType get_gate_type(const char* type_str) {
    if (strcmp(type_str, "and") == 0) return AND;
    if (strcmp(type_str, "or") == 0) return OR;
    if (strcmp(type_str, "not") == 0) return NOT;
    if (strcmp(type_str, "nand") == 0) return NAND;
    if (strcmp(type_str, "nor") == 0) return NOR;
    if (strcmp(type_str, "xor") == 0) return XOR;
    if (strcmp(type_str, "xnor") == 0) return XNOR;
    if (strcmp(type_str, "buf") == 0) return BUF;
    return -1;
}


// Parse Verilog (copied from v1)
Circuit* parse_verilog(const char* filename) {
    FILE* file = fopen(filename, "r");
    if (!file) {
        perror("Error opening Verilog file");
        return NULL;
    }
    Circuit* circuit = (Circuit*)malloc(sizeof(Circuit));
    circuit->gates = NULL;
    circuit->num_gates = 0;
    circuit->primary_inputs = NULL;
    circuit->num_primary_inputs = 0;
    circuit->primary_outputs = NULL;
    circuit->num_primary_outputs = 0;
    char line[1024];
    int line_num = 0;
    while (fgets(line, sizeof(line), file)) {
        line_num++;
        char* token = strtok(line, " \t\n\r(),;");
        if (token == NULL || strcmp(token, "//") == 0) continue;
        if (strcmp(token, "module") == 0) {
            strtok(NULL, " \t\n\r(),;");
        } else if (strcmp(token, "input") == 0) {
            while ((token = strtok(NULL, " \t\n\r(),;")) != NULL) {
                circuit->num_primary_inputs++;
                circuit->primary_inputs = (char**)realloc(circuit->primary_inputs, circuit->num_primary_inputs * sizeof(char*));
                circuit->primary_inputs[circuit->num_primary_inputs - 1] = strdup(token);
                circuit->num_gates++;
                circuit->gates = (Gate*)realloc(circuit->gates, circuit->num_gates * sizeof(Gate));
                Gate* new_gate = &circuit->gates[circuit->num_gates-1];
                strcpy(new_gate->name, token);
                strcpy(new_gate->output, token);
                new_gate->type = INPUT;
                new_gate->num_inputs = 0;
                new_gate->fanout_count = 0;
                new_gate->fanouts = NULL;
            }
        } else if (strcmp(token, "output") == 0) {
            while ((token = strtok(NULL, " \t\n\r(),;")) != NULL) {
                circuit->num_primary_outputs++;
                circuit->primary_outputs = (char**)realloc(circuit->primary_outputs, circuit->num_primary_outputs * sizeof(char*));
                circuit->primary_outputs[circuit->num_primary_outputs - 1] = strdup(token);
            }
        } else if (strcmp(token, "wire") == 0) {
            continue;
        } else if (strcmp(token, "endmodule") == 0) {
            continue;
        } else { // Gate instantiation
            GateType type = get_gate_type(token);
            char* gate_name = strtok(NULL, " \t\n\r(),;");
            circuit->num_gates++;
            circuit->gates = (Gate*)realloc(circuit->gates, circuit->num_gates * sizeof(Gate));
            Gate* new_gate = &circuit->gates[circuit->num_gates - 1];
            strcpy(new_gate->name, gate_name);
            new_gate->type = type;
            char* output = strtok(NULL, " \t\n\r(),;");
            strcpy(new_gate->output, output);
            new_gate->num_inputs = 0;
            while ((token = strtok(NULL, " \t\n\r(),;")) != NULL) {
                strcpy(new_gate->inputs[new_gate->num_inputs], token);
                new_gate->num_inputs++;
            }
            new_gate->fanout_count = 0;
            new_gate->fanouts = NULL;
        }
    }
    fclose(file);
    for (int i = 0; i < circuit->num_gates; i++) {
        for (int j = 0; j < circuit->gates[i].num_inputs; j++) {
            Gate* fanin_gate = find_gate(circuit, circuit->gates[i].inputs[j]);
            if(fanin_gate){
                circuit->gates[i].fanins[j] = fanin_gate;
                fanin_gate->fanout_count++;
                fanin_gate->fanouts = (Gate**)realloc(fanin_gate->fanouts, fanin_gate->fanout_count * sizeof(Gate*));
                fanin_gate->fanouts[fanin_gate->fanout_count-1] = &circuit->gates[i];
            }
        }
    }
    return circuit;
}

void create_collapsed_fault_list(Circuit* circuit) {
    circuit->faults = NULL;
    circuit->num_faults = 0;
    for (int i = 0; i < circuit->num_gates; i++) {
        Gate* gate = &circuit->gates[i];
        for (int j = 0; j < 2; j++) {
            circuit->num_faults++;
            circuit->faults = (Fault*)realloc(circuit->faults, circuit->num_faults * sizeof(Fault));
            Fault* new_fault = &circuit->faults[circuit->num_faults - 1];
            strcpy(new_fault->node_name, gate->output);
            new_fault->stuck_at_value = j;
            new_fault->detected = false;
            gate->faults[j] = new_fault;
        }
    }
}

int** read_test_vectors(const char* filename, int* num_vectors, int* num_inputs) {
    FILE* file = fopen(filename, "r");
    if (!file) {
        perror("Error opening test vector file");
        return NULL;
    }
    int** vectors = NULL;
    *num_vectors = 0;
    *num_inputs = 0;
    char line[1024];
    while (fgets(line, sizeof(line), file)) {
        if (*num_vectors == 0) {
            int count = 0;
            char* tmp = strdup(line);
            char* token = strtok(tmp, " \t\n\r");
            while (token) {
                count++;
                token = strtok(NULL, " \t\n\r");
            }
            *num_inputs = count;
            free(tmp);
        }
        (*num_vectors)++;
        vectors = (int**)realloc(vectors, (*num_vectors) * sizeof(int*));
        vectors[*num_vectors - 1] = (int*)malloc((*num_inputs) * sizeof(int));
        int idx = 0;
        char* token = strtok(line, " \t\n\r");
        while (token && idx < *num_inputs) {
            vectors[*num_vectors - 1][idx] = atoi(token);
            idx++;
            token = strtok(NULL, " \t\n\r");
        }
    }
    fclose(file);
    return vectors;
}

// Improved deductive simulation logic
void run_deductive_simulation(Circuit* circuit, int** test_vectors, int num_vectors, int num_inputs) {
    printf("\nRunning Improved Deductive Fault Simulation...\n");
    // For each test vector, simulate the circuit and propagate faults
    for (int v = 0; v < num_vectors; v++) {
        // 1. Set primary inputs
        for (int i = 0; i < circuit->num_primary_inputs; i++) {
            Gate* g = find_gate(circuit, circuit->primary_inputs[i]);
            if (g) g->value = test_vectors[v][i] ? ONE : ZERO;
        }
        // 2. Propagate values through the circuit
        for (int g = 0; g < circuit->num_gates; g++) {
            Gate* gate = &circuit->gates[g];
            if (gate->type == INPUT) continue;
            LogicValue in0 = (gate->num_inputs > 0 && gate->fanins[0]) ? gate->fanins[0]->value : X;
            LogicValue in1 = (gate->num_inputs > 1 && gate->fanins[1]) ? gate->fanins[1]->value : X;
            switch (gate->type) {
                case AND: gate->value = (in0 == ONE && in1 == ONE) ? ONE : ZERO; break;
                case OR:  gate->value = (in0 == ONE || in1 == ONE) ? ONE : ZERO; break;
                case NOT: gate->value = (in0 == ONE) ? ZERO : (in0 == ZERO ? ONE : X); break;
                case NAND: gate->value = (in0 == ONE && in1 == ONE) ? ZERO : ONE; break;
                case NOR:  gate->value = (in0 == ONE || in1 == ONE) ? ZERO : ONE; break;
                case XOR:  gate->value = (in0 != in1) ? ONE : ZERO; break;
                case XNOR: gate->value = (in0 == in1) ? ONE : ZERO; break;
                case BUF:  gate->value = in0; break;
                default: gate->value = X; break;
            }
        }
        // 3. Fault deduction: Mark faults as detected if output is controllable
        for (int f = 0; f < circuit->num_faults; f++) {
            Fault* fault = &circuit->faults[f];
            // Find the gate for this fault
            Gate* g = find_gate(circuit, fault->node_name);
            if (!g) continue;
            // If the node can be set to both 0 and 1 by any vector, mark both faults as detected
            if ((g->value == ZERO && fault->stuck_at_value == 1) ||
                (g->value == ONE && fault->stuck_at_value == 0)) {
                fault->detected = true;
            }
        }
    }
    printf("Improved simulation run complete.\n");
}


void generate_statistics(const char* filename, const Circuit* circuit, int num_vectors) {
    FILE* file = fopen(filename, "w");
    if (!file) {
        perror("Error opening statistics file");
        return;
    }
    fprintf(file, "Fault Simulation Statistics\n");
    fprintf(file, "=============================\n\n");
    fprintf(file, "Circuit Details:\n");
    fprintf(file, "- Primary Inputs: %d\n", circuit->num_primary_inputs);
    fprintf(file, "- Primary Outputs: %d\n", circuit->num_primary_outputs);
    fprintf(file, "- Gates: %d\n\n", circuit->num_gates);
    fprintf(file, "Faults:\n");
    fprintf(file, "- Total Collapsed Faults: %d\n\n", circuit->num_faults);
    fprintf(file, "Simulation Results:\n");
    fprintf(file, "- Test Vectors Applied: %d\n", num_vectors);
    int detected_faults = 0;
    for (int i = 0; i < circuit->num_faults; i++) {
        if (circuit->faults[i].detected) detected_faults++;
    }
    double fault_coverage = 0.0;
    if (circuit->num_faults > 0) {
        fault_coverage = ((double)detected_faults / circuit->num_faults) * 100.0;
    }
    fprintf(file, "- Detected Faults: %d\n", detected_faults);
    fprintf(file, "- Undetected Faults: %d\n", circuit->num_faults - detected_faults);
    fprintf(file, "- Fault Coverage: %.2f%%\n\n", fault_coverage);
    fprintf(file, "List of Detected Faults:\n");
    for (int i = 0; i < circuit->num_faults; i++) {
        if (circuit->faults[i].detected) {
            fprintf(file, "- Node: %s, Stuck-at-%d\n", circuit->faults[i].node_name, circuit->faults[i].stuck_at_value);
        }
    }
    fprintf(file, "\nList of Undetected Faults:\n");
    for (int i = 0; i < circuit->num_faults; i++) {
        if (!circuit->faults[i].detected) {
            fprintf(file, "- Node: %s, Stuck-at-%d\n", circuit->faults[i].node_name, circuit->faults[i].stuck_at_value);
        }
    }
    fclose(file);
    printf("Statistics file '%s' generated successfully.\n", filename);
}

void free_circuit(Circuit* circuit) {
    if (!circuit) return;
    for (int i = 0; i < circuit->num_gates; i++) {
        if (circuit->gates[i].fanouts) free(circuit->gates[i].fanouts);
    }
    for (int i = 0; i < circuit->num_primary_inputs; i++) free(circuit->primary_inputs[i]);
    for (int i = 0; i < circuit->num_primary_outputs; i++) free(circuit->primary_outputs[i]);
    free(circuit->primary_inputs);
    free(circuit->primary_outputs);
    free(circuit->gates);
    free(circuit->faults);
    free(circuit);
}
