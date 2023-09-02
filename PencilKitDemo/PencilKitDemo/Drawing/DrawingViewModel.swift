//
//  DrawingViewModel.swift
//  PencilKitDemo
//
//  Created by Masakiyo Tachikawa on 2023/08/18.
//

import OSLog
import PencilKit
import SwiftUI

final class DrawingViewModel: NSObject, ObservableObject {

    // MARK: - Properties

    @Published var showProgress: Bool = false
    @Published var errorMessageModel = ErrorMessageModel()
    @Published var confirmMessageModel = ConfirmMessageModel()
    @Published var saveConfirmMessageModel = SaveConfirmMessageModel()
    @Published var toastMessageModel = ToastMessageModel()

    let canvasView = PKCanvasView()

    private let toolPicker = PKToolPicker()
    private let serializationQueue = DispatchQueue(label: "SerializationQueue", qos: .userInitiated)
    private let saveURL: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths.first!
        return documentsDirectory.appendingPathComponent("PencilKitDemo.data")
    }()

    private var hasModifiedDrawing = false

    // MARK: - Conveniences

    func onAppear() {
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = self
        Task {
            let drawing = try? await loadDataModel()
            if drawing?.strokes.count ?? 0 > 0 {
                Task { @MainActor in
                    confirmMessageModel.title = ""
                    confirmMessageModel.message = "Do you want to restore the previously drawn image?"
                    confirmMessageModel.rightButtonRole = nil
                    confirmMessageModel.rightButtonTitle = "Restore"
                    confirmMessageModel.action = { self.restore() }
                    confirmMessageModel.show = true
                }
            }
        }
    }

    func dismiss(_ dismiss: DismissAction) {
        guard hasModifiedDrawing else {
            dismiss()
            return
        }
        confirmMessageModel.title = "Warning"
        confirmMessageModel.message = """
            When you return to the top screen, the history of undo and redo will be deleted.
            """
        confirmMessageModel.rightButtonRole = .destructive
        confirmMessageModel.rightButtonTitle = "OK"
        confirmMessageModel.action = { dismiss() }
        confirmMessageModel.show = true
    }

    func toggleTool() {
        if toolPicker.isVisible {
            toolPicker.setVisible(false, forFirstResponder: canvasView)
            toolPicker.removeObserver(canvasView)
        } else {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }
    }

    func saveToAlbum(baseImage: UIImage) {
        saveConfirmMessageModel.selected = {
            self.saveConfirmMessageModel.show = false
            self.saveToAlbum(of: $0, baseImage: baseImage)
        }
        saveConfirmMessageModel.message = """
            Please select the option for saving your drawn contents to Photo App.
            """
        saveConfirmMessageModel.show = true
    }

    func restore() {
        showProgress = true
        Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(0.5))
                canvasView.drawing = PKDrawing(strokes: try await loadDataModel().strokes)
            } catch {
                errorMessageModel.title = "Error"
                errorMessageModel.message = """
                    Load error(\(error.localizedDescription)).

                    Please try again.
                    """
                errorMessageModel.show = true
            }
            hasModifiedDrawing = false
            showProgress = false
        }
    }

    func pause() {
        guard hasModifiedDrawing, !canvasView.drawing.strokes.isEmpty else {
            return
        }
        showProgress = true
        Task { @MainActor in
            do {
                try await saveData(canvasView.drawing)
                canvasView.drawing = PKDrawing()
                hasModifiedDrawing = false
            } catch {
                errorMessageModel.title = "Error"
                errorMessageModel.message = error.localizedDescription
                errorMessageModel.show = true
            }
            try await Task.sleep(for: .seconds(0.5))
            showProgress = false
        }
    }

    func trash() {
        canvasView.drawing = PKDrawing()
        hasModifiedDrawing = false
    }

    func help() {
        errorMessageModel.title = ""
        errorMessageModel.message = """
            Sorry!!
            Not implement yet...
            """
        errorMessageModel.show = true
    }
}

// MARK: - Private extension

private extension DrawingViewModel {

    func loadDataModel() async throws -> PKDrawing {
        return try await withCheckedThrowingContinuation { continuation in
            let url = saveURL
            serializationQueue.async {
                guard FileManager.default.fileExists(atPath: url.path) else {
                    continuation.resume(returning: PKDrawing())
                    return
                }
                do {
                    let decoder = PropertyListDecoder()
                    let data = try Data(contentsOf: url)
                    let drawing = try decoder.decode(PKDrawing.self, from: data)
                    continuation.resume(returning: drawing)
                } catch {
                    os_log("Could not load data model: %s", type: .error, error.localizedDescription)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func saveData(_ drawing: PKDrawing) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let url = saveURL
            serializationQueue.async {
                do {
                    let encoder = PropertyListEncoder()
                    let data = try encoder.encode(drawing)
                    try data.write(to: url)
                    continuation.resume(returning: ())
                } catch {
                    os_log("Could not save data model: %s", type: .error, error.localizedDescription)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func saveToAlbum(of type: SaveConfirmMessageResponseType, baseImage: UIImage) {
        if type == .cancel {
            return
        }
        showProgress = true
        let imageSaver = ImageSaver(
            baseImage: baseImage,
            drawnImage: canvasView.drawing.image(from: canvasView.frame, scale: 1.0)
        )
        Task {
            let error: Error?
            if type == .drawnImage {
                error = await imageSaver.writeDrawnImageToPhotoAlbum()
            } else {
                error = await imageSaver.writeCombinedImageToPhotoAlbum()
            }
            try await Task.sleep(for: .seconds(0.5))
            Task { @MainActor in
                if let error {
                    errorMessageModel.title = "Error"
                    errorMessageModel.message = """
                        Save error(\(error.localizedDescription)).

                        Please try again.
                        """
                    errorMessageModel.show = true
                    return
                }
                toastMessageModel.message = "Saving is complete."
                toastMessageModel.show = true
                toastMessageModel.tapped = {
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.toastMessageModel.show = false
                    }
                }
                Task {
                    try await Task.sleep(for: .seconds(5))
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.toastMessageModel.show = false
                    }
                }
                showProgress = false
            }
        }
    }
}

// MARK: - PKCanvasViewDelegate

extension DrawingViewModel: PKCanvasViewDelegate {

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        hasModifiedDrawing = true
    }
}
