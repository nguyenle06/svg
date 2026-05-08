# Singular Value Decomposition (SVD) and Image Processing

## Assets

[Google Docs](https://docs.google.com/document/d/11FNSgcuDh-w_I31kYfoU_i7r9FK-QdVD0GJHR205YXY/edit?tab=t.0)

## Specification

In the digital age, images play a crucial role in many fields such as communication, medicine, surveillance, and artificial intelligence. However, image data is often large in size and susceptible to noise during acquisition, transmission, and storage. Therefore, image processing for noise reduction, data compression, and quality enhancement has become an essential task.

One of the most powerful tools in linear algebra that is widely applied in image processing is Singular Value Decomposition (SVD). This method allows a matrix to be decomposed into fundamental components, helping us better understand the structure of the data and perform low-rank approximations. Thanks to this property, SVD is particularly effective for image compression and denoising while preserving the most important features of an image.

In this report, we study the application of SVD to both grayscale and color images. For color images, each RGB channel is processed separately to ensure accuracy. By retaining only a limited number of the largest singular values, the image can be reconstructed with reduced storage requirements, while allowing us to analyze the trade-off between image quality and data compression.

The objective of this project is to develop a program for image processing using SVD, visually compare the original and processed images at different rank values, and perform quantitative analysis to evaluate the effectiveness of the method.
