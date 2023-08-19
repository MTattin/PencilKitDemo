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
    @Published var showError: Bool = false {
        didSet {
            if !showError {
                errorMessage = ""
            }
        }
    }
    @Published var showConfirm: Bool = false {
        didSet {
            if !showConfirm {
                confirmMessage = ""
            }
        }
    }

    let canvasView = PKCanvasView()

    private(set) var errorMessage: String = "" {
        didSet {
            if !errorMessage.isEmpty {
                DispatchQueue.main.async {
                    self.showError = true
                }
            }
        }
    }
    private(set) var confirmMessage: String = "" {
        didSet {
            if !confirmMessage.isEmpty {
                DispatchQueue.main.async {
                    self.showConfirm = true
                }
            }
        }
    }

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
    }

    func dismiss(_ dismiss: DismissAction) {
        guard hasModifiedDrawing else {
            dismiss()
            return
        }
        confirmMessage = """
            When you return to the top screen, the history of undo and redo will be deleted.
            """
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

    func saveToAlbum() {
        errorMessage = """
            Sorry!!
            Not implement yet...
            """
    }

    func restart() {
        showProgress = true
        Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(0.5))
                canvasView.drawing = PKDrawing(strokes: try await loadDataModel().strokes)
            } catch {
                errorMessage = """
                    Load error(\(error.localizedDescription)).

                    Please try again.
                    """
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
                errorMessage = error.localizedDescription
            }
            try await Task.sleep(for: .seconds(0.5))
            showProgress = false
        }
    }

    func help() {
        errorMessage = """
            Sorry!!
            Not implement yet...
            """
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
}

// MARK: - PKCanvasViewDelegate

extension DrawingViewModel: PKCanvasViewDelegate {

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        hasModifiedDrawing = true
    }
}
