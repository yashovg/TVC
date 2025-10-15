% DeductiveFaultSimulator.m
function DeductiveFaultSimulator(verilog_file, vector_file, output_file)
    % A Deductive Fault Simulator for Single Stuck-at Faults
    %
    % Args:
    %   verilog_file: Path to the structural Verilog netlist file.
    %   vector_file: Path to the test vectors file.
    %   output_file: Path for the output statistics file.

    if nargin < 1 || isempty(verilog_file)
        verilog_file = "c17.v";
    end
    if nargin < 2 || isempty(vector_file)
        vector_file = "vectors.txt";
    end
    if nargin < 3 || isempty(output_file)
        output_file = "results.txt";
    end

    fprintf('Deductive Fault Simulator Started...\n');

    % Step 1: Parse the Verilog file and levelize the circuit
    fprintf('1. Parsing Verilog file: %s\n', verilog_file);
    [circuit, PIs, POs, levelized_gates] = parseVerilog(verilog_file);
    fprintf('   - Parsing complete. Found %d PIs, %d POs, and %d gates.\n', ...
            numel(PIs), numel(POs), numel(levelized_gates));

    % Step 2: Generate the collapsed fault list
    fprintf('2. Generating collapsed fault list...\n');
    collapsed_faults = generateCollapsedFaults(circuit, levelized_gates);
    fprintf('   - Fault list generated. Total collapsed faults: %d\n', numel(collapsed_faults));

    % Step 3: Read test vectors
    fprintf('3. Reading test vectors from: %s\n', vector_file);
    test_vectors = readTestVectors(vector_file, PIs);
    fprintf('   - Found %d test vectors.\n', size(test_vectors, 1));

    % Step 4: Run the simulation
    fprintf('4. Running deductive fault simulation...\n');
    [detected_faults, undetected_faults] = runSimulation(circuit, PIs, POs, ...
                                            levelized_gates, test_vectors, collapsed_faults);
    fprintf('   - Simulation complete.\n');

    % Step 5: Generate the final report
    fprintf('5. Generating report file: %s\n', output_file);
    generateReport(output_file, collapsed_faults, detected_faults, undetected_faults);
    fprintf('   - Report generated successfully.\n');

    fprintf('Done.\n');
end