function [circuit, fault_list] = create_collapsed_fault_list_v2(circuit)
% Place SA0 and SA1 on every gate output (including PIs if desired)
fault_list = struct('node_name', {}, 'stuck_at_value', {}, 'detected', {});
fi = 0;
for i = 1:length(circuit.gates)
    node = circuit.gates(i).output;
    if isempty(node), continue; end
    fi = fi + 1;
    fault_list(fi).node_name = node;
    fault_list(fi).stuck_at_value = 0;
    fault_list(fi).detected = false;
    fi = fi + 1;
    fault_list(fi).node_name = node;
    fault_list(fi).stuck_at_value = 1;
    fault_list(fi).detected = false;
end
end
