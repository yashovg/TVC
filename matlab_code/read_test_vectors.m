
function test_vectors = read_test_vectors(filename)
    % Reads test vectors from a file.
    % Each line is a vector, e.g., "0 1 1" or "011" (supports both)

    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open test vector file: %s', filename);
    end

    lines = {};
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        if isempty(line)
            continue;
        end
        lines{end+1} = line; %#ok<AGROW>
    end
    fclose(fid);

    if isempty(lines)
        test_vectors = [];
        return;
    end

    % Detect if space-separated or single string
    if contains(lines{1}, ' ')
        num_inputs = numel(strsplit(lines{1}));
        num_vectors = numel(lines);
        test_vectors = zeros(num_vectors, num_inputs);
        for i = 1:num_vectors
            vals = str2num(lines{i}); %#ok<ST2NM>
            test_vectors(i, :) = vals;
        end
    else
        num_inputs = length(lines{1});
        num_vectors = numel(lines);
        test_vectors = zeros(num_vectors, num_inputs);
        for i = 1:num_vectors
            test_vectors(i, :) = lines{i} - '0';
        end
    end
end
