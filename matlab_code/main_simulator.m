% main_simulator.m - Main script to run the deductive fault simulator

clear;
clc;
close all;

% --- Configuration ---
verilog_filename = 'circuit.v';
vectors_filename = 'vectors.txt';
output_filename = 'stats_matlab.txt';

fprintf('Starting MATLAB Fault Simulator...\n\n');

% 1. Parse Verilog file
fprintf('1. Parsing Verilog file: %s\n', verilog_filename);
try
    circuit = parse_verilog(verilog_filename);
    fprintf('   - Parsing complete.\n');
    fprintf('   - Found %d gates, %d inputs, %d outputs.\n\n', ...
            length(circuit.gates), length(circuit.primaryInputs), length(circuit.primaryOutputs));
catch ME
    fprintf(2, 'Error parsing Verilog file: %s\n', ME.message);
    return;
end

% 2. Create collapsed fault list
fprintf('2. Creating collapsed fault list...\n');
[circuit, fault_list] = create_collapsed_fault_list(circuit);
fprintf('   - Fault list created with %d total faults.\n\n', length(fault_list));

% 3. Read test vectors
fprintf('3. Reading test vectors from: %s\n', vectors_filename);
try
    test_vectors = read_test_vectors(vectors_filename);
    [num_vectors, num_inputs] = size(test_vectors);
    fprintf('   - Read %d test vectors with %d inputs each.\n\n', num_vectors, num_inputs);
catch ME
    fprintf(2, 'Error reading test vectors: %s\n', ME.message);
    return;
end

% Validate vector dimensions
if num_inputs ~= length(circuit.primaryInputs)
    fprintf(2, 'Error: Number of inputs in vector file (%d) does not match circuit PI count (%d).\n', ...
            num_inputs, length(circuit.primaryInputs));
    return;
end

% 4. Run deductive fault simulation
fprintf('4. Running Deductive Fault Simulation...\n');
% NOTE: This is a simplified simulation for demonstration purposes.
fault_list = run_deductive_simulation(circuit, fault_list, test_vectors);
fprintf('   - Simulation complete.\n\n');


% 5. Generate statistics
fprintf('5. Generating statistics file: %s\n', output_filename);
generate_statistics(output_filename, circuit, fault_list, num_vectors);
fprintf('   - Statistics file generated successfully.\n\n');

fprintf('Fault simulation finished.\n');
