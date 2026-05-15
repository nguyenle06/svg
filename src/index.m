% =========================
% SVD Image Compression MATLAB Version
% =========================
function svd_image_compression(image_paths)
    % Default list if no input given
    if nargin < 1
        image_paths = {
            "assets/input/01_landscape.jpg", ...
            "assets/input/02_dog.jpeg", ...
            "assets/input/03_color.png"
        };
    end

    % Loop over each image
    for f = 1:length(image_paths)
        image_path = image_paths{f};
        fprintf("\n========== Processing: %s ==========\n", image_path);
        process_single_image(image_path);
    end
end

% =========================
% Process one image
% =========================
function process_single_image(image_path)
    try
        img_data = imread(image_path);
        img_data = imresize(img_data, 0.25);
        img_original = im2double(img_data);
        disp(size(img_original));
    catch ME
        fprintf("Error loading image: %s\n", ME.message);
        return;
    end

    % Extract filename parts for output naming
    [~, name, ext] = fileparts(image_path);
    output_dir = "assets/output";
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    k_values = [1, 5, 10, 20];
    errors = zeros(size(k_values));
    data_ratios = zeros(size(k_values));
    reconstructed_images = cell(size(k_values));

    disp("--- PROGRAM EXECUTION RESULTS ---");
    for i = 1:length(k_values)
        k = k_values(i);
        img_k = compress_image_svd(img_original, k);
        reconstructed_images{i} = img_k;
        errors(i) = calculate_frobenius_error(img_original, img_k);
        data_ratios(i) = calculate_data_retention(size(img_original), k);
        fprintf("Rank k = %-3d | Error: %8.2f | Data: %5.2f%%\n", ...
            k, errors(i), data_ratios(i));

        % Save compressed image
        output_path = sprintf("%s/%s_k%d%s", output_dir, name, k, ext);
        imwrite(img_k, output_path);
        fprintf("Saved: %s\n", output_path);
    end

    % Visualization: images
    figure('visible', 'on', 'Name', name);
    subplot(2,3,1);
    imshow(img_original);
    title("Original: " + name);
    for i = 1:length(k_values)
        subplot(2,3,i+1);
        imshow(reconstructed_images{i});
        title(sprintf("k=%d | Data: %.1f%%", k_values(i), data_ratios(i)));
    end
    drawnow;

    % Trade-off plot
    figure('visible', 'on', 'Name', name + " Trade-off");
    yyaxis left
    plot(k_values, errors, '-or', 'LineWidth', 2);
    ylabel("Frobenius Error");
    yyaxis right
    plot(k_values, data_ratios, '--sb', 'LineWidth', 2);
    ylabel("Data Storage Retained (%)");
    xlabel("Rank (k values)");
    title("Trade-off: " + name);
    grid on;
    drawnow;
end

% =========================
% Compress single channel
% =========================
function reconstructed = compress_channel_svd(channel, k)
    [U, S, V] = svd(channel, 'econ');
    reconstructed = U(:,1:k) * S(1:k,1:k) * V(:,1:k)';
end

% =========================
% Compress image
% =========================
function reconstructed_img = compress_image_svd(image, k)
    if ndims(image) == 3
        r = compress_channel_svd(image(:,:,1), k);
        g = compress_channel_svd(image(:,:,2), k);
        b = compress_channel_svd(image(:,:,3), k);
        reconstructed_img = cat(3, r, g, b);
    else
        reconstructed_img = compress_channel_svd(image, k);
    end
    reconstructed_img = min(max(reconstructed_img, 0), 1);
end

% =========================
% Frobenius error
% =========================
function err = calculate_frobenius_error(original, reconstructed)
    diff = original - reconstructed;
    err = sqrt(sum(diff(:).^2));
end

% =========================
% Data retention ratio
% =========================
function ratio = calculate_data_retention(shape, k)
    m = shape(1); n = shape(2);
    channels = 1;
    if numel(shape) == 3
        channels = shape(3);
    end
    ratio = (k * (m + n + 1) * channels) / (m * n * channels) * 100;
end

% =========================
% Custom svd function
% =========================
function [U, S, V] = custom_svd(A)
    [m, n] = size(A);

    % Step 1: Compute A^T * A
    C = transpose(A) * A;

    % Step 2: Eigenvalues decomposition of C
    % V: eigenvectors
    % D: eigenvalues
    [V, D] = eig(C);

    % Step 3: Singular values 
    % Formula: \sigma_i = sqrt(|\lambda_i|)
    singular = sqrt(abs(diag(D))); 

    % Step 4: Sort singular values in descending order
    [singular, idx] = sort(singular, 'descend'); 
    V = V(:, idx);

    % Step 5: Sigma matrix (singular values on the diagonal)
    S = zeros(m, n);
    k = min(m, n);
    S(1:k, 1:k) = diag(singular(1:k));

    % Step 6: Compute U
    % Formula: u_i = (1/\sigma_i) * A * v_i
    U = zeros(m, n);
    for i = 1:n
        if singular(i) > 1e-10 % Avoid division by zero
            U(:, i) = (1/singular(i)) * A * V(:, i);
        end
    end

    % Step 7: Complete orthonormal basis (QR decomposition - make U from almost orthogonal to fully orthogonal)
    [U, ~] = qr(U);
end
