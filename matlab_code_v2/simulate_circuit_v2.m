function outputs = simulate_circuit_v2(circuit, inputs, inject_node, inject_value)
% simulate_circuit_v2 - simulate circuit for given inputs
% Usage:
%   outputs = simulate_circuit_v2(circuit, inputs)
%   outputs = simulate_circuit_v2(circuit, inputs, inject_node, inject_value)
%
% inputs can be a single row vector (1xM) or a matrix (NxM).
% If inject_node is provided, that node's output is forced to inject_value during simulation.

if nargin < 3
    inject_node = '';
    inject_value = [];
end

is_batch = size(inputs,1) > 1;
if is_batch
    num_vec = size(inputs,1);
else
    num_vec = 1;
    inputs = reshape(inputs, 1, []);
end

% map node name -> value
outputs = [];
for vi = 1:num_vec
    node_values = containers.Map();
    % set primary inputs for this vector
    for i = 1:length(circuit.primaryInputs)
        node_values(circuit.primaryInputs{i}) = inputs(vi,i);
    end

    % evaluate gates in the order they appear
    for g = 1:length(circuit.gates)
        gt = circuit.gates(g).type;
        outn = circuit.gates(g).output;
        inps = circuit.gates(g).inputs;

        % resolve input values
        vals = zeros(1,length(inps));
        for k = 1:length(inps)
            key = inps{k};
            if isKey(node_values, key)
                vals(k) = node_values(key);
            else
                vals(k) = 0;
            end
        end

        % compute gate output
        switch lower(gt)
            case {'and'}
                res = all(vals);
            case {'or'}
                res = any(vals);
            case {'not', 'inv'}
                res = ~vals(1);
            case {'nand'}
                res = ~all(vals);
            case {'nor'}
                res = ~any(vals);
            case {'xor'}
                res = mod(sum(vals),2);
            case {'xnor'}
                res = ~mod(sum(vals),2);
            case {'buf'}
                res = vals(1);
            case {'input'}
                if isKey(node_values, outn)
                    res = node_values(outn);
                else
                    res = 0;
                end
            otherwise
                if isempty(vals)
                    res = 0;
                else
                    res = vals(1);
                end
        end

        % inject fault if specified and node matches
        if ~isempty(inject_node) && strcmp(outn, inject_node)
            res = inject_value;
        end

        node_values(outn) = double(res);
    end

    % collect primary outputs
    outs = zeros(1, length(circuit.primaryOutputs));
    for o = 1:length(circuit.primaryOutputs)
        key = circuit.primaryOutputs{o};
        if isKey(node_values, key)
            outs(o) = node_values(key);
        else
            outs(o) = 0;
        end
    end

    outputs(vi,:) = outs; %#ok<AGROW>
end

if ~is_batch
    outputs = outputs(1,:);
end
end
