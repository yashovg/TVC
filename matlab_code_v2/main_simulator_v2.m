% main_simulator_v2.m - Deterministic single-fault simulation (per-fault injection)
clear; clc; close all;

% Configuration
verilog_filename = 'circuit.v';
vectors_filename = 'vectors.txt';
output_filename = 'stats_matlab_v2.txt';

fprintf('Starting MATLAB Fault Simulator v2...\n\n');

% Parse Verilog
fprintf('1) Parsing Verilog: %s\n', verilog_filename);
circuit = parse_verilog_v2(verilog_filename);
fprintf('   Parsed %d gates, %d PIs, %d POs\n', length(circuit.gates), length(circuit.primaryInputs), length(circuit.primaryOutputs));

% Create collapsed fault list
fprintf('2) Building collapsed fault list...\n');
[circuit, fault_list] = create_collapsed_fault_list_v2(circuit);
fprintf('   Total faults: %d\n', length(fault_list));

% Read test vectors
fprintf('3) Reading test vectors: %s\n', vectors_filename);
test_vectors = read_test_vectors_v2(vectors_filename);
[num_vectors, num_inputs] = size(test_vectors);
fprintf('   Read %d vectors with %d inputs\n', num_vectors, num_inputs);

if num_inputs ~= length(circuit.primaryInputs)
    error('Number of vector inputs (%d) does not match circuit primary inputs (%d)', num_inputs, length(circuit.primaryInputs));
end

% Run deterministic single-fault injection simulation
fprintf('4) Running single-fault injection simulation...\n');
tic;
% Use the deductive simulator v3 (symbolic propagation)
fault_list = run_deductive_simulation_v3(circuit, fault_list, test_vectors);
sim_time = toc;
fprintf('   Simulation finished in %.2f seconds\n', sim_time);

% Generate statistics
fprintf('5) Writing statistics to %s\n', output_filename);
generate_statistics_v2(output_filename, circuit, fault_list, num_vectors);
fprintf('Done.\n');
