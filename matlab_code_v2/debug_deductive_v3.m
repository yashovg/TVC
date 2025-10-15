% debug_deductive_v3 - run deductive simulator v3 on the example circuit and print per-fault results
clear; clc;
cd(fileparts(mfilename('fullpath')));

circuit = parse_verilog_v2('circuit.v');
[circuit, fault_list] = create_collapsed_fault_list_v2(circuit);
test_vectors = read_test_vectors_v2('vectors.txt');

fprintf('Running deductive simulator v3 (debug)...\n');
fault_list = run_deductive_simulation_v3(circuit, fault_list, test_vectors);

detected = find([fault_list.detected]);
fprintf('Total faults: %d\n', length(fault_list));
fprintf('Detected faults: %d\n', length(detected));
for i = 1:length(fault_list)
    f = fault_list(i);
    fprintf('%2d) %-8s SA-%d  -> %s\n', i, f.node_name, f.stuck_at_value, mat2str(f.detected));
end
