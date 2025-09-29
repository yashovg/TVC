function generate_statistics(filename, circuit, fault_list, num_vectors)
    % Generates a statistics file with the fault simulation results.
    
    fid = fopen(filename, 'w');
    if fid == -1
        error('Cannot open statistics file for writing: %s', filename);
    end
    
    fprintf(fid, 'Fault Simulation Statistics (MATLAB Version)\n');
    fprintf(fid, '=============================================\n\n');
    
    fprintf(fid, 'Circuit Details:\n');
    fprintf(fid, '- Primary Inputs: %d (%s)\n', length(circuit.primaryInputs), strjoin(circuit.primaryInputs, ', '));
    fprintf(fid, '- Primary Outputs: %d (%s)\n', length(circuit.primaryOutputs), strjoin(circuit.primaryOutputs, ', '));
    fprintf(fid, '- Gate Count: %d\n\n', length(circuit.gates));
    
    total_faults = length(fault_list);
    fprintf(fid, 'Faults:\n');
    fprintf(fid, '- Total Collapsed Faults: %d\n\n', total_faults);
    
    fprintf(fid, 'Simulation Results:\n');
    fprintf(fid, '- Test Vectors Applied: %d\n', num_vectors);
    
    detected_mask = [fault_list.detected];
    detected_faults = sum(detected_mask);
    undetected_faults = total_faults - detected_faults;
    
    fault_coverage = 0;
    if total_faults > 0
        fault_coverage = (detected_faults / total_faults) * 100;
    end
    
    fprintf(fid, '- Detected Faults: %d\n', detected_faults);
    fprintf(fid, '- Undetected Faults: %d\n', undetected_faults);
    fprintf(fid, '- Fault Coverage: %.2f%%\n\n', fault_coverage);
    
    fprintf(fid, 'List of Detected Faults:\n');
    if detected_faults == 0
        fprintf(fid, '- None\n');
    else
        detected_indices = find(detected_mask);
        for i = 1:length(detected_indices)
            idx = detected_indices(i);
            fprintf(fid, '- Node: %-8s, Stuck-at-%d\n', fault_list(idx).node_name, fault_list(idx).stuck_at_value);
        end
    end
    
    fprintf(fid, '\nList of Undetected Faults:\n');
    if undetected_faults == 0
         fprintf(fid, '- None\n');
    else
        undetected_indices = find(~detected_mask);
        for i = 1:length(undetected_indices)
            idx = undetected_indices(i);
            fprintf(fid, '- Node: %-8s, Stuck-at-%d\n', fault_list(idx).node_name, fault_list(idx).stuck_at_value);
        end
    end

    fclose(fid);
end
