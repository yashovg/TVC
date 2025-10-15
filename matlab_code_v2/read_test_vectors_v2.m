function test_vectors = read_test_vectors_v2(filename)
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

% detect format
if contains(lines{1}, ' ')
    % space separated
    num_inputs = numel(strsplit(lines{1}));
    num_vectors = numel(lines);
    test_vectors = zeros(num_vectors, num_inputs);
    for i=1:num_vectors
        test_vectors(i,:) = str2num(lines{i}); %#ok<ST2NM>
    end
else
    num_inputs = length(lines{1});
    num_vectors = numel(lines);
    test_vectors = zeros(num_vectors, num_inputs);
    for i=1:num_vectors
        test_vectors(i,:) = lines{i} - '0';
    end
end
end
