function fault_list = run_deductive_simulation_v3_verbose(circuit, fault_list, test_vectors)
% Verbose deductive simulator: prints symbolic sets while simulating to help debug
all_nodes = unique([circuit.primaryInputs, circuit.wires, circuit.primaryOutputs, cellfun(@(g) g.output, num2cell(circuit.gates), 'UniformOutput', false)]);
node_map = containers.Map();
for i = 1:length(all_nodes)
    node_map(all_nodes{i}) = i;
end
make_key = @(n,v) sprintf('%s:%d', n, v);

detected_map = containers.Map();
for i = 1:length(fault_list)
    k = make_key(fault_list(i).node_name, fault_list(i).stuck_at_value);
    detected_map(k) = false;
end

num_vectors = size(test_vectors,1);
for vi = 1:num_vectors
    fprintf('\n=== Vector %d ===\n', vi);
    vec = test_vectors(vi,:);
    node_values = compute_node_values(circuit, vec);

    N = length(all_nodes);
    make0 = cell(1,N); make1 = cell(1,N);
    for i = 1:N
        make0{i} = {make_key(all_nodes{i},0)};
        make1{i} = {make_key(all_nodes{i},1)};
    end

    changed = true;
    iter = 0;
    while changed
        iter = iter + 1;
        changed = false;
        fprintf('-- Iteration %d --\n', iter);
        for g = 1:length(circuit.gates)
            gate = circuit.gates(g);
            if strcmpi(gate.type, 'input'), continue; end
            outn = gate.output; out_idx = node_map(outn); inps = gate.inputs;
            vals = zeros(1,length(inps));
            for k = 1:length(inps)
                if isKey(node_values, inps{k}), vals(k)=node_values(inps{k}); end
            end
            vo = eval_gate(gate.type, vals);

            out_make0 = {}; out_make1 = {};
            for k = 1:length(inps)
                iname = inps{k}; in_idx = node_map(iname); vfi = vals(k);
                for s = 0:1
                    if s==vfi, continue; end
                    tmp = vals; tmp(k)=s; newo = eval_gate(gate.type, tmp);
                    if newo ~= vo
                        faults_that_force_input = make_suitable(make0{in_idx}, make1{in_idx}, s);
                        if newo==0, out_make0 = union(out_make0, faults_that_force_input);
                        else out_make1 = union(out_make1, faults_that_force_input); end
                    end
                end
            end
            out_make0 = union(out_make0, {make_key(outn,0)});
            out_make1 = union(out_make1, {make_key(outn,1)});
            new_make0 = unique(out_make0); new_make1 = unique(out_make1);
            if ~isequal(new_make0, make0{out_idx}) || ~isequal(new_make1, make1{out_idx})
                make0{out_idx} = new_make0; make1{out_idx} = new_make1; changed = true;
            end
            fprintf('Gate %s -> output %s: make0=%s, make1=%s\n', gate.name, outn, strjoin(make0{out_idx}, ', '), strjoin(make1{out_idx}, ', '));
        end
    end

    % summarize which faults force POs to opposite
    for p = 1:length(circuit.primaryOutputs)
        pname = circuit.primaryOutputs{p}; pidx = node_map(pname);
        pval = 0; if isKey(node_values, pname), pval = node_values(pname); end
        if pval==1, keys = make0{pidx}; else keys = make1{pidx}; end
        fprintf('Primary output %s (val=%d) forced by: %s\n', pname, pval, strjoin(keys, ', '));
        for j = 1:length(keys)
            k = keys{j}; if isKey(detected_map, k), detected_map(k)=true; end
        end
    end
end

for i = 1:length(fault_list)
    k = make_key(fault_list(i).node_name, fault_list(i).stuck_at_value);
    if isKey(detected_map, k), fault_list(i).detected = detected_map(k); else fault_list(i).detected=false; end
end
end
