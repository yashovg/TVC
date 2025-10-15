function circuit = parse_verilog_v2(filename)
% Robust-ish parser for a small structural Verilog subset used in examples.
% Returns a circuit struct with fields: gates, primaryInputs, primaryOutputs, wires

fid = fopen(filename, 'r');
if fid == -1
    error('Cannot open Verilog file: %s', filename);
end

circuit.gates = struct('name', {}, 'type', {}, 'output', {}, 'inputs', {});
circuit.primaryInputs = {};
circuit.primaryOutputs = {};
circuit.wires = {};

gate_idx = 0;
in_module = false;

while ~feof(fid)
    line = strtrim(fgetl(fid));
    if isempty(line) || startsWith(line, '//')
        continue;
    end
    % remove trailing semicolon for easier parsing
    if line(end) == ';'
        line = line(1:end-1);
    end

    % module header
    if ~in_module && startsWith(line, 'module')
        in_module = true;
        % try to read inputs/outputs between parentheses
        % subsequent lines with input/output keywords will be parsed below
        continue;
    end

    if in_module
        if contains(line, ');')
            in_module = false;
            continue;
        end
        if startsWith(line, 'input')
            toks = strsplit(line);
            % support: input A, or input [N:0] A,
            name = toks{2};
            name = strrep(name, ',', '');
            circuit.primaryInputs{end+1} = name; %#ok<AGROW>
            continue;
        end
        if startsWith(line, 'output')
            toks = strsplit(line);
            name = toks{2};
            name = strrep(name, ',', '');
            circuit.primaryOutputs{end+1} = name; %#ok<AGROW>
            continue;
        end
        continue;
    end

    % wires
    if startsWith(line, 'wire')
        rest = strtrim(line(5:end));
        parts = strsplit(rest, ',');
        for i=1:length(parts)
            nm = strtrim(parts{i});
            circuit.wires{end+1} = nm; %#ok<AGROW>
        end
        continue;
    end

    % gate instantiation: type name (out, in1, in2)
    tokens = regexp(line, '^(\w+)\s+(\w+)\s*\(([^\)]+)\)', 'tokens');
    if ~isempty(tokens)
        gate_idx = gate_idx + 1;
        t = tokens{1};
        circuit.gates(gate_idx).type = lower(t{1});
        circuit.gates(gate_idx).name = t{2};
        ports = strtrim(strsplit(t{3}, ','));
        circuit.gates(gate_idx).output = ports{1};
        circuit.gates(gate_idx).inputs = ports(2:end);
    end
end

fclose(fid);

% add PIs as pseudo-gates for easier processing in some workflows
for i = 1:length(circuit.primaryInputs)
    gate_idx = gate_idx + 1;
    circuit.gates(gate_idx).type = 'input';
    circuit.gates(gate_idx).name = circuit.primaryInputs{i};
    circuit.gates(gate_idx).output = circuit.primaryInputs{i};
    circuit.gates(gate_idx).inputs = {};
end
end
