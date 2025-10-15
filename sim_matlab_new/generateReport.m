% generateReport.m
function generateReport(filename, total_faults, detected_faults, undetected_faults)
    % Generates a formatted output report file.
    
    num_total = numel(total_faults);
    num_detected = numel(detected_faults);
    num_undetected = numel(undetected_faults);
    
    if num_total > 0
        coverage = (num_detected / num_total) * 100;
    else
        coverage = 100; % Or NaN, depending on desired behavior for no faults
    end

    fid = fopen(filename, 'w');
    if fid == -1
        error('Cannot open output file for writing: %s', filename);
    end
    
    fprintf(fid, '========================================\n');
    fprintf(fid, '    Deductive Fault Simulation Report    \n');
    fprintf(fid, '========================================\n\n');
    
    fprintf(fid, '--- Statistics ---\n');
    fprintf(fid, 'Total Collapsed Faults: %d\n', num_total);
    fprintf(fid, 'Detected Faults:        %d\n', num_detected);
    fprintf(fid, 'Undetected Faults:      %d\n', num_undetected);
    fprintf(fid, '--------------------\n');
    fprintf(fid, 'Fault Coverage:         %.2f%%\n\n', coverage);
    
    fprintf(fid, '--- List of Undetected Faults ---\n');
    if isempty(undetected_faults)
        fprintf(fid, 'All faults were detected.\n');
    else
        for i = 1:numel(undetected_faults)
            fprintf(fid, '%s\n', undetected_faults{i});
        end
    end
    
    fprintf(fid, '\n========================================\n');
    
    fclose(fid);
end