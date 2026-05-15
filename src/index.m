% =========================
% SVD Image Compression MATLAB Version
% =========================
function index()
    image_path = "assets/input/04_painting.avif";
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

        % Save compressed image → assets/output/01_landscape_k5.jpg
        output_path = sprintf("%s/%s_k%d%s", output_dir, name, k, ext);
        imwrite(img_k, output_path);
        fprintf("Saved: %s\n", output_path);
    end

    % Visualization: images
    figure('visible', 'on');
    subplot(2,3,1);
    imshow(img_original);
    title("Original Image");
    for i = 1:length(k_values)
        subplot(2,3,i+1);
        imshow(reconstructed_images{i});
        title(sprintf("Processed (k=%d)\nData Retained: %.1f%%", ...
            k_values(i), data_ratios(i)));
    end
    drawnow;

    % Trade-off plot
    figure('visible', 'on');
    yyaxis left
    plot(k_values, errors, '-or', 'LineWidth', 2);
    ylabel("Frobenius Error");
    yyaxis right
    plot(k_values, data_ratios, '--sb', 'LineWidth', 2);
    ylabel("Data Storage Retained (%)");
    xlabel("Rank (k values)");
    title("Trade-off Analysis: Image Quality vs Data Reduction");
    grid on;
    drawnow;
end

function reconstructed = compress_channel_svd(channel, k)
    [U, S, V] = svd(channel, 'econ');
    reconstructed = U(:,1:k) * S(1:k,1:k) * V(:,1:k)';
end

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

function err = calculate_frobenius_error(original, reconstructed)
    diff = original - reconstructed;
    err = sqrt(sum(diff(:).^2));
end

function ratio = calculate_data_retention(shape, k)
    m = shape(1); n = shape(2);
    channels = 1;
    if numel(shape) == 3
        channels = shape(3);
    end
    ratio = (k * (m + n + 1) * channels) / (m * n * channels) * 100;
end