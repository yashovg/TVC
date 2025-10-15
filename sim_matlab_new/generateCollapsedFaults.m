% generateCollapsedFaults.m
function fault_list = generateCollapsedFaults(circuit, levelized_gates)
    % Generates a collapsed list of single stuck-at faults.
    
    all_wires = keys(circuit);
    full_fault_list = {};
    
    % 1. Generate full (uncollapsed) fault list
    for i = 1:numel(all_wires)
        wire = all_wires{i};
        full_fault_list{end+1} = sprintf('%s/0', wire); % Stuck-at-0
        full_fault_list{end+1} = sprintf('%s/1', wire); % Stuck-at-1
    end
    
    fault_list = full_fault_list;
    
    % 2. Perform fault collapsing based on equivalency
    % This is a simplified implementation focusing on gate I/O equivalence.
    for i = 1:numel(levelized_gates)
        gate = levelized_gates{i};
        out = gate.output;
        ins = gate.inputs;
        
        switch gate.type
            case {'and', 'nand'}
                % Input SA0 is equivalent to output SA0 (AND) or SA1 (NAND)
                fault_to_keep = sprintf('%s/%d', out, strcmp(gate.type, 'nand'));
                faults_to_remove = cellfun(@(in) sprintf('%s/0', in), ins, 'UniformOutput', false);
                fault_list = setdiff(fault_list, faults_to_remove(ismember(faults_to_remove, fault_list)));
            case {'or', 'nor'}
                % Input SA1 is equivalent to output SA1 (OR) or SA0 (NOR)
                fault_to_keep = sprintf('%s/%d', out, strcmp(gate.type, 'nor'));
                faults_to_remove = cellfun(@(in) sprintf('%s/1', in), ins, 'UniformOutput', false);
                fault_list = setdiff(fault_list, faults_to_remove(ismember(faults_to_remove, fault_list)));
            case {'buf', 'not'}
                % Input SA0/1 equivalent to output SA0/1 (BUF) or SA1/0 (NOT)
                fault_out_0 = sprintf('%s/%d', out, strcmp(gate.type, 'not'));
                fault_in_0 = sprintf('%s/0', ins{1});
                fault_list = setdiff(fault_list, fault_in_0);
                
                fault_out_1 = sprintf('%s/%d', out, ~strcmp(gate.type, 'not'));
                fault_in_1 = sprintf('%s/1', ins{1});
                fault_list = setdiff(fault_list, fault_in_1);
        end
    end
    
    fault_list = unique(fault_list)';
end