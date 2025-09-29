#include "fault_simulator.h"

// Helper function to find a gate by its name
// Returns a pointer to the gate with the given name or output, or NULL if not found
Gate* find_gate(Circuit* circuit, const char* name) {
    for (int i = 0; i < circuit->num_gates; i++) {
        if (strcmp(circuit->gates[i].name, name) == 0 || strcmp(circuit->gates[i].output, name) == 0) {
            return &circuit->gates[i];
        }
    }
    return NULL;
}

// Helper function to convert a gate type string to the GateType enum
GateType get_gate_type(const char* type_str) {
    if (strcmp(type_str, "and") == 0) return AND;
    if (strcmp(type_str, "or") == 0) return OR;
    if (strcmp(type_str, "not") == 0) return NOT;
    if (strcmp(type_str, "nand") == 0) return NAND;
    if (strcmp(type_str, "nor") == 0) return NOR;
    if (strcmp(type_str, "xor") == 0) return XOR;
    if (strcmp(type_str, "xnor") == 0) return XNOR;
    if (strcmp(type_str, "buf") == 0) return BUF;
    return -1; // Should not happen for valid Verilog
}


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
        printf("[DEBUG] Parsing line %d: %s", line_num, line);
        char* token = strtok(line, " \t\n\r(),;");

        if (token == NULL || strcmp(token, "//") == 0) {
            continue;
        }

        if (strcmp(token, "module") == 0) {
            printf("[DEBUG] Found module declaration\n");
            strtok(NULL, " \t\n\r(),;");
        } else if (strcmp(token, "input") == 0) {
            printf("[DEBUG] Found input declaration\n");
            while ((token = strtok(NULL, " \t\n\r(),;")) != NULL) {
                printf("[DEBUG] Adding input: %s\n", token);
                circuit->num_primary_inputs++;
                circuit->primary_inputs = (char**)realloc(circuit->primary_inputs, circuit->num_primary_inputs * sizeof(char*));
                circuit->primary_inputs[circuit->num_primary_inputs - 1] = strdup(token);

                // Add INPUT gates
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
            printf("[DEBUG] Found output declaration\n");
            while ((token = strtok(NULL, " \t\n\r(),;")) != NULL) {
                printf("[DEBUG] Adding output: %s\n", token);
                circuit->num_primary_outputs++;
                circuit->primary_outputs = (char**)realloc(circuit->primary_outputs, circuit->num_primary_outputs * sizeof(char*));
                circuit->primary_outputs[circuit->num_primary_outputs - 1] = strdup(token);
            }
        } else if (strcmp(token, "wire") == 0) {
            printf("[DEBUG] Found wire declaration\n");
            continue;
        } else if (strcmp(token, "endmodule") == 0) {
            printf("[DEBUG] Found endmodule, skipping.\n");
            continue;
        } else { // Gate instantiation
            printf("[DEBUG] Found gate instantiation: %s\n", token);
            GateType type = get_gate_type(token);
            char* gate_name = strtok(NULL, " \t\n\r(),;");
            printf("[DEBUG] Gate name: %s\n", gate_name);

            circuit->num_gates++;
            circuit->gates = (Gate*)realloc(circuit->gates, circuit->num_gates * sizeof(Gate));
            Gate* new_gate = &circuit->gates[circuit->num_gates - 1];
            strcpy(new_gate->name, gate_name);
            new_gate->type = type;

            char* output = strtok(NULL, " \t\n\r(),;");
            printf("[DEBUG] Gate output: %s\n", output);
            strcpy(new_gate->output, output);

            new_gate->num_inputs = 0;
            while ((token = strtok(NULL, " \t\n\r(),;")) != NULL) {
                printf("[DEBUG] Gate input %d: %s\n", new_gate->num_inputs, token);
                strcpy(new_gate->inputs[new_gate->num_inputs], token);
                new_gate->num_inputs++;
            }
            new_gate->fanout_count = 0;
            new_gate->fanouts = NULL;
        }
    }
    fclose(file);

    // Build fan-in and fan-out connections
    printf("[DEBUG] Building fan-in and fan-out connections\n");
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

    printf("[DEBUG] Verilog parsing complete. Gates: %d, Inputs: %d, Outputs: %d\n", circuit->num_gates, circuit->num_primary_inputs, circuit->num_primary_outputs);
    return circuit;
}


void create_collapsed_fault_list(Circuit* circuit) {
    circuit->faults = NULL;
    circuit->num_faults = 0;

    for (int i = 0; i < circuit->num_gates; i++) {
        Gate* gate = &circuit->gates[i];
        // Faults on gate outputs: stuck-at-0 and stuck-at-1
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

void free_circuit(Circuit* circuit) {
    if (!circuit) return;

    for (int i = 0; i < circuit->num_gates; i++) {
        free(circuit->gates[i].fanouts);
    }
    free(circuit->gates);

    for (int i = 0; i < circuit->num_primary_inputs; i++) {
        free(circuit->primary_inputs[i]);
    }
    free(circuit->primary_inputs);

    for (int i = 0; i < circuit->num_primary_outputs; i++) {
        free(circuit->primary_outputs[i]);
    }
    free(circuit->primary_outputs);
    
    free(circuit->faults);
    free(circuit);
}
