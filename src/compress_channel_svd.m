% =========================
% Compress single channel
% =========================
function reconstructed = compress_channel_svd(channel, k)
    % [U, S, V] = svd(channel, 'econ'); % Using built-in SVD function
    [U, S, V] = custom_svd(channel);
    reconstructed = U(:,1:k) * S(1:k,1:k) * V(:,1:k)';
end