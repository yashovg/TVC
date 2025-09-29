function [circuit, fault_list] = create_collapsed_fault_list(circuit)
    % Creates a collapsed list of single stuck-at faults.
    
    fault_list = struct('node_name', {}, 'stuck_at_value', {}, 'detected', {});
    fault_idx = 0;
    
    all_nodes = [circuit.primaryInputs, circuit.wires, circuit.primaryOutputs];
    
    % For this simple model, we place faults on all gate outputs
    for i = 1:length(circuit.gates)
        node_name = circuit.gates(i).output;
        
        % Stuck-at-0
        fault_idx = fault_idx + 1;
        fault_list(fault_idx).node_name = node_name;
        fault_list(fault_idx).stuck_at_value = 0;
        fault_list(fault_idx).detected = false;
        
        % Stuck-at-1
        fault_idx = fault_idx + 1;
        fault_list(fault_idx).node_name = node_name;
        fault_list(fault_idx).stuck_at_value = 1;
        fault_list(fault_idx).detected = false;
    end
end
