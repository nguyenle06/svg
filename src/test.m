% =========================
% Test matrices for custom_svd
% =========================

% 1. Square diagonal matrix
A1 = [
    1 0 0;
    0 2 0;
    0 0 3
];

% 2. Square non-diagonal matrix
A2 = [
    1 2 3;
    4 5 6;
    7 8 9
];

% 3. Rectangular tall matrix (4x2)
A3 = [
    1 2;
    3 4;
    5 6;
    7 8
];

% 4. Rectangular wide matrix (2x4)
A4 = [
    1 2 3 4;
    5 6 7 8
];

% Store all matrices in a cell array
matrices = {A1, A2, A3, A4};

% =========================
% Compare custom_svd vs MATLAB svd
% =========================

for k = 1:length(matrices)

    A = matrices{k};

    fprintf('\n=========================\n');
    fprintf('Matrix A%d:\n', k);
    disp(A);

    % Custom SVD
    [Uc, Sc, Vc] = custom_svd(A);

    % MATLAB SVD
    [Um, Sm, Vm] = svd(A);

    fprintf('--- Custom SVD Reconstruction ---\n');
    disp(Uc * Sc * Vc');

    fprintf('--- MATLAB SVD Reconstruction ---\n');
    disp(Um * Sm * Vm');

    fprintf('--- Reconstruction Error (Custom) ---\n');
    disp(norm(A - Uc * Sc * Vc'));

    fprintf('--- Reconstruction Error (MATLAB) ---\n');
    disp(norm(A - Um * Sm * Vm'));

end