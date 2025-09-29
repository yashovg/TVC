function circuit = parse_verilog(filename)
    % Parses a structural Verilog file and returns a circuit structure for the style in circuit.v
    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open Verilog file: %s', filename);
    end

    circuit.gates = struct('name', {}, 'type', {}, 'output', {}, 'inputs', {});
    circuit.primaryInputs = {};
    circuit.primaryOutputs = {};
    circuit.wires = {};
    gate_idx = 0;

    in_module_header = false;
    
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        % Skip empty lines and comments
        if isempty(line) || startsWith(line, '//')
            continue;
        end

        % Detect start of module header
        if ~in_module_header && startsWith(line, 'module') && contains(line, '(')
            in_module_header = true;
            continue;
        end

        % Parse module header lines (inputs/outputs)
        if in_module_header
            if contains(line, ');')
                in_module_header = false;
                continue;
            end
            % Handle input
            if startsWith(line, 'input')
                line = strrep(line, 'input', '');
                line = strrep(line, ',', '');
                name = strtrim(line);
                if ~isempty(name)
                    circuit.primaryInputs{end+1} = name;
                end
                continue;
            end
            % Handle output
            if startsWith(line, 'output')
                line = strrep(line, 'output', '');
                line = strrep(line, ',', '');
                name = strtrim(line);
                if ~isempty(name)
                    circuit.primaryOutputs{end+1} = name;
                end
                continue;
            end
            continue;
        end

        % Parse wire declarations
        if startsWith(line, 'wire')
            line = strrep(line, 'wire', '');
            line = strrep(line, ';', '');
            names = strtrim(strsplit(line, ','));
            for i = 1:length(names)
                if ~isempty(names{i})
                    circuit.wires{end+1} = strtrim(names{i});
                end
            end
            continue;
        end

        % Parse gate instantiations
        tokens = regexp(line, '^(\w+)\s+(\w+)\s*\(([^\)]+)\);', 'tokens');
        if ~isempty(tokens)
            gate_idx = gate_idx + 1;
            circuit.gates(gate_idx).type = lower(tokens{1}{1});
            circuit.gates(gate_idx).name = tokens{1}{2};
            ports = strtrim(strsplit(tokens{1}{3}, ','));
            circuit.gates(gate_idx).output = ports{1};
            circuit.gates(gate_idx).inputs = ports(2:end);
            continue;
        end
    end
    fclose(fid);

    % Add primary inputs as "gates" for easier processing
    for i = 1:length(circuit.primaryInputs)
        gate_idx = gate_idx + 1;
        circuit.gates(gate_idx).type = 'input';
        circuit.gates(gate_idx).name = circuit.primaryInputs{i};
        circuit.gates(gate_idx).output = circuit.primaryInputs{i};
        circuit.gates(gate_idx).inputs = {};
    end
end
