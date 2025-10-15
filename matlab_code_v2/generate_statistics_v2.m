function generate_statistics_v2(filename, circuit, fault_list, num_vectors)
fid = fopen(filename, 'w');
if fid == -1
    error('Cannot open statistics file for writing: %s', filename);
end

fprintf(fid, 'Fault Simulation v2 Statistics\n');
fprintf(fid, '============================\n\n');

fprintf(fid, 'Circuit:\n');
fprintf(fid, '- Primary Inputs: %d (%s)\n', length(circuit.primaryInputs), strjoin(circuit.primaryInputs, ', '));
fprintf(fid, '- Primary Outputs: %d (%s)\n', length(circuit.primaryOutputs), strjoin(circuit.primaryOutputs, ', '));
fprintf(fid, '- Gate Count: %d\n\n', length(circuit.gates));

total_faults = length(fault_list);
detected = sum([fault_list.detected]);
coverage = 0;
if total_faults > 0
    coverage = detected/total_faults*100;
end

fprintf(fid, 'Simulation:\n');
fprintf(fid, '- Test Vectors Applied: %d\n', num_vectors);
fprintf(fid, '- Total Collapsed Faults: %d\n', total_faults);
fprintf(fid, '- Detected Faults: %d\n', detected);
fprintf(fid, '- Fault Coverage: %.2f%%\n\n', coverage);

fprintf(fid, 'Detected Faults:\n');
if detected == 0
    fprintf(fid, '- None\n');
else
    idx = find([fault_list.detected]);
    for i=1:length(idx)
        f = fault_list(idx(i));
        fprintf(fid, '- %s stuck-at-%d\n', f.node_name, f.stuck_at_value);
    end
end

fprintf(fid, '\nUndetected Faults:\n');
if detected == total_faults
    fprintf(fid, '- None\n');
else
    idx2 = find(~[fault_list.detected]);
    for i=1:length(idx2)
        f = fault_list(idx2(i));
        fprintf(fid, '- %s stuck-at-%d\n', f.node_name, f.stuck_at_value);
    end
end

fclose(fid);
end
