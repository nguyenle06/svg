import numpy as np
import matplotlib.pyplot as plt
from PIL import Image

def compress_channel_svd(channel, k):
    U, S, Vt = np.linalg.svd(channel, full_matrices=False)              
    # A_k = U_k * S_k * Vt_k
    reconstructed_channel = np.dot(U[:, :k], np.dot(np.diag(S[:k]), Vt[:k, :]))
    return reconstructed_channel

def compress_image_svd(image, k):
    if len(image.shape) == 3:
        # Process color images separately for each channel
        r_compressed = compress_channel_svd(image[:, :, 0], k)
        g_compressed = compress_channel_svd(image[:, :, 1], k)
        b_compressed = compress_channel_svd(image[:, :, 2], k)
        reconstructed_img = np.stack((r_compressed, g_compressed, b_compressed), axis=2)
    else:
        reconstructed_img = compress_channel_svd(image, k)
    return np.clip(reconstructed_img, 0, 1)

def calculate_frobenius_error(original, reconstructed):
    return np.sqrt(np.sum((original - reconstructed) ** 2))
def calculate_data_retention(shape, k):
    m, n = shape[0], shape[1]
    channels = shape[2] if len(shape) == 3 else 1

    original_size = m * n * channels
    compressed_size = k * (m + n + 1) * channels
    
    ratio = (compressed_size / original_size) * 100
    return ratio

# Main execution
try:
    image_path = "assets/input/01_landscape.jpg"
    img_data = Image.open(image_path)
    img_original = np.array(img_data)
    print(img_original.shape)

except Exception as e:
    print(f"Error loading image: {e}")
    exit()

if img_original.dtype == np.uint8:
    img_original = img_original / 255.0

k_values = [5, 20, 50, 100]
errors = []
data_ratios = []
reconstructed_images = []

print("--- PROGRAM EXECUTION RESULTS ---")
for k in k_values:
    img_k = compress_image_svd(img_original, k)
    reconstructed_images.append(img_k)

    error = calculate_frobenius_error(img_original, img_k)
    errors.append(error)
    
    ratio = calculate_data_retention(img_original.shape, k)
    data_ratios.append(ratio)
    
    print(f"Rank k = {k:<3} | Frobenius Error: {error:8.2f} | Data Retained: {ratio:5.2f}%")

# Visual Evaluation
plt.figure(figsize=(15, 8))

plt.subplot(2, 3, 1)
plt.imshow(img_original, cmap='gray' if len(img_original.shape)==2 else None)
plt.title("Original Image")
plt.axis('off')

for i, k in enumerate(k_values):
    plt.subplot(2, 3, i + 2)
    plt.imshow(reconstructed_images[i], cmap='gray' if len(img_original.shape)==2 else None)
    plt.title(f"Processed (k = {k})\nData Retained: {data_ratios[i]:.1f}%")
    plt.axis('off')

plt.tight_layout()
plt.show()

# Trade-off Visualization
fig, ax1 = plt.subplots(figsize=(8, 5))

color = 'tab:red'
ax1.set_xlabel('Rank (k values)')
ax1.set_ylabel('Frobenius Error', color=color)
ax1.plot(k_values, errors, marker='o', color=color, linewidth=2, label="Frobenius Error (Quality Loss)")
ax1.tick_params(axis='y', labelcolor=color)

ax2 = ax1.twinx()  
color = 'tab:blue'
ax2.set_ylabel('Data Storage Retained (%)', color=color)  
ax2.plot(k_values, data_ratios, marker='s', color=color, linewidth=2, linestyle='--', label="Data Size")
ax2.tick_params(axis='y', labelcolor=color)

plt.title("Trade-off Analysis: Image Quality vs. Data Reduction")
fig.tight_layout()  
plt.show()