function index(image_paths)
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


