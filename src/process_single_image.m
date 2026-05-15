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
    saveas(gcf, sprintf("%s/%s_visualization.png", output_dir, name));

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
    saveas(gcf, sprintf("%s/%s_tradeoff.png", output_dir, name));
end