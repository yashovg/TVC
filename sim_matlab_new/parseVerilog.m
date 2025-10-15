% parseVerilog.m
function [circuit, PIs, POs, levelized_gates] = parseVerilog(filename)
    % Parses a structural Verilog file and levelizes the circuit.
    
    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open Verilog file: %s', filename);
    end

    circuit = containers.Map('KeyType', 'char', 'ValueType', 'any');
    PIs = {};
    POs = {};
    gate_list = {};
    
    % First pass: Identify all wires, inputs, outputs, and gates
    lines = textscan(fid, '%s', 'Delimiter', '\n');
    lines = lines{1};
    fclose(fid);

    in_module = false;
    for i = 1:length(lines)
        line = strtrim(lines{i});
        if isempty(line) || startsWith(line, '//')
            continue;
        end
        % handle module header that declares inputs/outputs across multiple lines
        if ~in_module && startsWith(line, 'module')
            in_module = true;
            continue;
        end
        if in_module
            if contains(line, ');')
                in_module = false;
                continue;
            end
            % parse input lines inside module header (e.g., "input A, B,")
            if startsWith(line, 'input')
                decl = strtrim(line(6:end));
                decl = regexprep(decl, '\[[^\]]+\]', ''); % remove bus ranges
                parts = strsplit(decl, ',');
                for k = 1:numel(parts)
                    name = strtrim(parts{k});
                    name = regexprep(name, '[,;\)]', '');
                    if isempty(name), continue; end
                    PIs{end+1} = name; %#ok<AGROW>
                    circuit(name) = struct('name', name, 'type', 'PI', 'value', NaN, 'fault_list', {{}} , 'level', 0);
                end
                continue;
            end
            if startsWith(line, 'output')
                decl = strtrim(line(7:end));
                decl = regexprep(decl, '\[[^\]]+\]', '');
                parts = strsplit(decl, ',');
                for k = 1:numel(parts)
                    name = strtrim(parts{k});
                    name = regexprep(name, '[,;\)]', '');
                    if isempty(name), continue; end
                    POs{end+1} = name; %#ok<AGROW>
                    if ~isKey(circuit, name)
                        circuit(name) = struct('name', name, 'type', 'PO', 'value', NaN, 'fault_list', {{}} , 'level', -1);
                    end
                end
                continue;
            end
            continue;
        end

        % Match standalone inputs/outputs/wires with semicolons
        tokens = regexp(line, '^\s*input\s+(.*?);', 'tokens');
        if ~isempty(tokens)
            names = strsplit(tokens{1}{1}, ',');
            for k = 1:numel(names)
                name = strtrim(names{k});
                PIs{end+1} = name; %#ok<AGROW>
                circuit(name) = struct('name', name, 'type', 'PI', 'value', NaN, 'fault_list', {{}} , 'level', 0);
            end
            continue;
        end
        tokens = regexp(line, '^\s*output\s+(.*?);', 'tokens');
        if ~isempty(tokens)
            names = strsplit(tokens{1}{1}, ',');
            for k = 1:numel(names)
                name = strtrim(names{k});
                POs{end+1} = name; %#ok<AGROW>
                if ~isKey(circuit, name)
                    circuit(name) = struct('name', name, 'type', 'PO', 'value', NaN, 'fault_list', {{}} , 'level', -1);
                end
            end
            continue;
        end
        tokens = regexp(line, '^\s*wire\s+(.*?);', 'tokens');
        if ~isempty(tokens)
            names = strsplit(tokens{1}{1}, ',');
            for k = 1:numel(names)
                name = strtrim(names{k});
                if ~isKey(circuit, name)
                    circuit(name) = struct('name', name, 'type', 'WIRE', 'value', NaN, 'fault_list', {{}} , 'level', -1);
                end
            end
            continue;
        end

        % Match gates
        % Match gate instantiation; accept optional trailing semicolon and spaces
        tokens = regexp(line, '^\s*(\w+)\s+(\w+)\s*\(\s*([^\)]+?)\s*\)\s*;?', 'tokens');
        if ~isempty(tokens)
            gate_type = lower(tokens{1}{1});
            gate_name = tokens{1}{2};
            ports = strsplit(tokens{1}{3}, ',');
            ports = cellfun(@(s) strtrim(regexprep(s,'[,;]$','')), ports, 'UniformOutput', false);

            if isempty(ports)
                continue;
            end
            output_port = ports{1};
            input_ports = {};
            if numel(ports) > 1
                input_ports = ports(2:end);
            end

            % ensure nodes exist in circuit map
            if ~isKey(circuit, output_port)
                circuit(output_port) = struct('name', output_port, 'type', 'WIRE', 'value', NaN, 'fault_list', {{}} , 'level', -1);
            end
            for k = 1:numel(input_ports)
                iname = input_ports{k};
                if ~isKey(circuit, iname)
                    circuit(iname) = struct('name', iname, 'type', 'WIRE', 'value', NaN, 'fault_list', {{}} , 'level', -1);
                end
            end

            gate_info = struct('name', gate_name, 'type', gate_type, 'output', output_port, 'inputs', {input_ports});
            gate_list{end+1} = gate_info; %#ok<AGROW>
        end
    end
    PIs = unique(PIs, 'stable');
    POs = unique(POs, 'stable');

    % Levelization (Topological Sort)
    level = 0;
    levelized_gates = {};
    processed_gates = false(1, numel(gate_list));

    while any(~processed_gates)
        level_changed = false;
        for i = 1:numel(gate_list)
            if processed_gates(i)
                continue;
            end
            gate = gate_list{i};
            
            % Check if all inputs are ready (have a level assigned)
            inputs_ready = true;
            max_input_level = -1;
            for k = 1:numel(gate.inputs)
                input_node = circuit(gate.inputs{k});
                if input_node.level == -1
                    inputs_ready = false;
                    break;
                end
                max_input_level = max(max_input_level, input_node.level);
            end
            
            if inputs_ready
                levelized_gates{end+1} = gate;
                output_node = circuit(gate.output);
                output_node.level = max_input_level + 1;
                circuit(gate.output) = output_node;
                processed_gates(i) = true;
                level_changed = true;
            end
        end
        if ~level_changed && any(~processed_gates)
            error('Combinational loop detected or circuit graph is disconnected.');
        end
    end
end