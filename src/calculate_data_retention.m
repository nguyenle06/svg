% =========================
% Data retention ratio
% =========================
function ratio = calculate_data_retention(shape, k)
    % Formula: \text{ratio} = \frac{k(m + n + 1)}{m \cdot n} \times 100\%
    m = shape(1); n = shape(2);
    channels = 1;
    if numel(shape) == 3
        channels = shape(3);
    end
    ratio = (k * (m + n + 1) * channels) / (m * n * channels) * 100;
end