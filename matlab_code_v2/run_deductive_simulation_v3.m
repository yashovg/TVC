function fault_list = run_deductive_simulation_v3(circuit, fault_list, test_vectors)
% Deductive fault simulation (single stuck-at) per test vector
% For each vector, compute sets of faults that can force each node to 0 or 1
% using symbolic propagation rules, then mark faults that force primary outputs
% to the opposite value as detected.

% Build node index map
all_nodes = unique([circuit.primaryInputs, circuit.wires, circuit.primaryOutputs, cellfun(@(g) g.output, num2cell(circuit.gates), 'UniformOutput', false)]);
node_map = containers.Map();
for i = 1:length(all_nodes)
    node_map(all_nodes{i}) = i;
end

% helper to key faults as strings 'node:val'
make_key = @(n,v) sprintf('%s:%d', n, v);

% prepare fault detection map
detected_map = containers.Map();
for i = 1:length(fault_list)
    k = make_key(fault_list(i).node_name, fault_list(i).stuck_at_value);
    detected_map(k) = false;
end

num_vectors = size(test_vectors,1);

for vi = 1:num_vectors
    vec = test_vectors(vi,:);

    % compute fault-free node values and store in node_values map
    node_values = compute_node_values(circuit, vec);

    % initialize make0/make1 sets for each node (as cell arrays of keys)
    N = length(all_nodes);
    make0 = cell(1,N); make1 = cell(1,N);
    for i = 1:N
        make0{i} = {make_key(all_nodes{i}, 0)}; % node SA0 can force node to 0
        make1{i} = {make_key(all_nodes{i}, 1)}; % node SA1 can force node to 1
    end

    % Iterative symbolic propagation: repeat until make0/make1 sets converge
    changed = true;
    while changed
        changed = false;
        for g = 1:length(circuit.gates)
            gate = circuit.gates(g);
            if strcmpi(gate.type, 'input')
                continue;
            end
            outn = gate.output;
            out_idx = node_map(outn);
            inps = gate.inputs;

            % gather input values
            vals = zeros(1,length(inps));
            for k = 1:length(inps)
                iname = inps{k};
                if isKey(node_values, iname)
                    vals(k) = node_values(iname);
                else
                    vals(k) = 0;
                end
            end
            vo = eval_gate(gate.type, vals);

            out_make0 = {}; out_make1 = {};

            % For each input, check if forcing that input to the opposite value changes the gate output
            for k = 1:length(inps)
                iname = inps{k};
                in_idx = node_map(iname);
                vfi = vals(k);
                for s = 0:1
                    if s == vfi
                        continue;
                    end
                    tmp = vals;
                    tmp(k) = s;
                    newo = eval_gate(gate.type, tmp);
                    if newo ~= vo
                        % faults that can force input iname to s cause output to change to newo
                        faults_that_force_input = make_suitable(make0{in_idx}, make1{in_idx}, s);
                        if newo == 0
                            out_make0 = union(out_make0, faults_that_force_input);
                        else
                            out_make1 = union(out_make1, faults_that_force_input);
                        end
                    end
                end
            end

            % include faults on the output node itself
            out_make0 = union(out_make0, {make_key(outn,0)});
            out_make1 = union(out_make1, {make_key(outn,1)});

            % update and detect changes
            new_make0 = unique(out_make0);
            new_make1 = unique(out_make1);
            if ~isequal(new_make0, make0{out_idx}) || ~isequal(new_make1, make1{out_idx})
                make0{out_idx} = new_make0;
                make1{out_idx} = new_make1;
                changed = true;
            end
        end
    end

    % At primary outputs, see which faults force the PO to the opposite value
    for p = 1:length(circuit.primaryOutputs)
        pname = circuit.primaryOutputs{p};
        pidx = node_map(pname);
        pval = 0;
        if isKey(node_values, pname)
            pval = node_values(pname);
        end
        if pval == 1
            % faults that force it to 0 are detected
            keys = make0{pidx};
        else
            keys = make1{pidx};
        end
        for j = 1:length(keys)
            k = keys{j};
            if isKey(detected_map, k)
                detected_map(k) = true;
            end
        end
    end
end

% write back fault_list detected flags
for i = 1:length(fault_list)
    k = make_key(fault_list(i).node_name, fault_list(i).stuck_at_value);
    if isKey(detected_map, k)
        fault_list(i).detected = detected_map(k);
    else
        fault_list(i).detected = false;
    end
end
end

function list = makecell(c)
% ensure cell
if isempty(c)
    list = {};
elseif iscell(c)
    list = c;
else
    list = {c};
end
end

function out = make_suitable(make0_cell, make1_cell, s)
% return the correct cell of faults that can make the input equal to s
if s == 0
    out = make0_cell;
else
    out = make1_cell;
end
end

function val = eval_gate(type, inputs)
t = lower(type);
switch t
    case 'and'
        val = all(inputs);
    case 'or'
        val = any(inputs);
    case {'not', 'inv'}
        val = ~inputs(1);
    case 'nand'
        val = ~all(inputs);
    case 'nor'
        val = ~any(inputs);
    case 'xor'
        val = mod(sum(inputs),2);
    case 'xnor'
        val = ~mod(sum(inputs),2);
    case 'buf'
        val = inputs(1);
    otherwise
        % default conservative: return first input
        if isempty(inputs)
            val = 0;
        else
            val = inputs(1);
        end
end
val = double(val);
end

function node_values = compute_node_values(circuit, vec)
% Evaluate circuit in order and return map of node->value for this vector
node_values = containers.Map();
% set primary inputs
for i = 1:length(circuit.primaryInputs)
    node_values(circuit.primaryInputs{i}) = vec(i);
end

% evaluate gates in order (skip PI pseudo-gates)
for g = 1:length(circuit.gates)
    gate = circuit.gates(g);
    if strcmpi(gate.type, 'input')
        continue;
    end
    inps = gate.inputs;
    vals = zeros(1,length(inps));
    for k = 1:length(inps)
        key = inps{k};
        if isKey(node_values, key)
            vals(k) = node_values(key);
        else
            vals(k) = 0;
        end
    end
    outv = eval_gate(gate.type, vals);
    node_values(gate.output) = outv;
end
end
