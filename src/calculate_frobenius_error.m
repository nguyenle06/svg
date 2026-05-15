% =========================
% Frobenius error
% =========================
function err = calculate_frobenius_error(original, reconstructed)
    % Formula: \|Original - Reconstructed\|_F = \sqrt{\sum_{i,j} (O_{ij} - R_{ij})^2}
    diff = original - reconstructed;
    err = sqrt(sum(diff(:).^2));
end