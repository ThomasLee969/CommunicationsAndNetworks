function signals = qam_2l_convert(symbols)
    [len, cols] = size(symbols);
    if mod(len, 2)
        error 'qam_2l_convert: mod(size(symbols, 1), 2) ~= 0'
    end

    signal_len = len / 2 * cols;
    symbols = symbols(:);
    signals = zeros(signal_len, 1);

    for k = 1:signal_len
        signals(k) = 2 * symbols(2 * k - 1) + symbols(2 * k);
    end

    signals(signals == 0) = -3;
    signals(signals == 1) = -1;
    signals(signals == 3) = 1;
    signals(signals == 2) = 3;

    % Make sure averge power = 1 in QAM.
    signals = sqrt(10) / 40 * reshape(signals, len / 2, cols);
end
