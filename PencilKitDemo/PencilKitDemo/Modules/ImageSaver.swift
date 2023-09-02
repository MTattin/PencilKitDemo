//
//  ImageSaver.swift
//  PencilKitDemo
//
//  Created by Masakiyo Tachikawa on 2023/09/02.
//

import UIKit

final class ImageSaver: NSObject {

    let baseImage: UIImage
    let drawnImage: UIImage

    private var savedContinuation: CheckedContinuation<Error?, Never>?

    init(baseImage: UIImage, drawnImage: UIImage) {
        self.baseImage = baseImage
        self.drawnImage = drawnImage
    }

    func writeDrawnImageToPhotoAlbum() async -> Error? {
        return await withCheckedContinuation { continuation in
            savedContinuation = continuation
            UIImageWriteToSavedPhotosAlbum(drawnImage, self, #selector(saveCompleted), nil)
        }
    }

    func writeCombinedImageToPhotoAlbum() async -> Error? {
        return await withCheckedContinuation { continuation in
            savedContinuation = continuation
            let image: UIImage = baseImage.combine(image: drawnImage)
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
        }
    }
}

private extension ImageSaver {

    @objc private func saveCompleted(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        savedContinuation?.resume(returning: error)
    }
}

private extension UIImage {

    func combine(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(origin: .zero, size: size))
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
