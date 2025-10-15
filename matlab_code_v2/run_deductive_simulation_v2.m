function fault_list = run_deductive_simulation_v2(circuit, fault_list, test_vectors)
% Deterministic single-fault injection: for each fault, inject the stuck-at at the node
% and apply all test vectors; mark fault detected if any vector causes primary outputs
% to differ from the golden (fault-free) outputs.

% First compute fault-free outputs for all vectors
golden_outputs = simulate_circuit(circuit, test_vectors);

for f = 1:length(fault_list)
    node = fault_list(f).node_name;
    sa = fault_list(f).stuck_at_value;
    detected = false;
    for v = 1:size(test_vectors,1)
        vec = test_vectors(v,:);
        fout = simulate_circuit(circuit, vec, node, sa);
        if ~isequal(fout, golden_outputs(v,:))
            detected = true;
            break;
        end
    end
    fault_list(f).detected = detected;
end
end

function outputs = simulate_circuit(circuit, inputs, inject_node, inject_value)
% Very small interpreter for the parsed circuit supporting a few gate types
% inputs: if a matrix (NxM) is provided, returns NxP output matrix; otherwise 1xP vector
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

% map node name -> column index/value
% evaluate gates in order: assume input-gates are present as pseudo-gates at end
node_values = containers.Map();

% set primary inputs for each vector
for vi = 1:num_vec
    for i = 1:length(circuit.primaryInputs)
        node_values(circuit.primaryInputs{i}) = inputs(vi,i);
    end

    % evaluate gates in the order they appear (simple topological assumption)
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
                vals(k) = 0; % default
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
                % PI pseudo-gate: value already set
                if isKey(node_values, outn)
                    res = node_values(outn);
                else
                    res = 0;
                end
            otherwise
                % unknown gate: attempt simple two-input behavior (OR fallback)
                if isempty(vals)
                    res = 0;
                else
                    res = vals(1);
                end
        end

        % inject fault if this node matches and injection specified
        if nargin >= 3 && ~isempty(inject_node) && strcmp(outn, inject_node)
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

    if vi == 1
        outputs = zeros(num_vec, length(outs));
    end
    outputs(vi,:) = outs;
end

if ~is_batch
    outputs = outputs(1,:);
end
end
