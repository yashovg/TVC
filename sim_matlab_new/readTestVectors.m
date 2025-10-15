function test_vectors = readTestVectors(filename, PIs)
% readTestVectors - read test vectors file into numeric matrix
% Usage: test_vectors = readTestVectors(filename, PIs)
% Supports two formats per line:
%  - Packed bits: 0101
%  - Space-separated bits: 0 1 0 1

fid = fopen(filename, 'r');
if fid == -1
    error('Cannot open test vector file: %s', filename);
end

raw = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
lines = raw{1};

% remove empty lines and trim
lines = lines(~cellfun(@isempty, cellfun(@strtrim, lines, 'UniformOutput', false)));

num_vectors = numel(lines);
num_pis = numel(PIs);

if num_vectors == 0
    test_vectors = [];
    return;
end

% detect format from first non-empty line
first = strtrim(lines{1});
if contains(first, ' ')
    % space-separated
    test_vectors = zeros(num_vectors, num_pis);
    for i = 1:num_vectors
        vals = sscanf(lines{i}, '%d');
        if numel(vals) ~= num_pis
            error('Vector on line %d has %d values but expected %d.', i, numel(vals), num_pis);
        end
        test_vectors(i, :) = vals(:)';
    end
else
    % packed string per line
    test_vectors = zeros(num_vectors, num_pis);
    for i = 1:num_vectors
        ln = strtrim(lines{i});
        if length(ln) ~= num_pis
            error('Vector on line %d has length %d but expected %d.', i, length(ln), num_pis);
        end
        % convert chars '0'/'1' to numbers
        test_vectors(i, :) = ln - '0';
    end
end
end