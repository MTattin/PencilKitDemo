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

    private let serializationQueue = DispatchQueue(label: "SerializationQueue", qos: .userInitiated)
    private let saveURL: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths.first!
        return documentsDirectory.appendingPathComponent("PencilKitDemo.data")
    }()

    private(set) var hasModifiedDrawing = false

    // MARK: - Conveniences

    func loadDrawing() async -> PKDrawing {
        do {
            return try await loadDataModel()
        } catch {
            errorMessage = """
                Load error(\(error.localizedDescription)).

                Please try again.
                """
            return PKDrawing()
        }
    }

    func saveDrawing(_ drawing: PKDrawing) async {
        do {
            try await saveData(drawing)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setErrorMessage(_ message: String) {
        errorMessage = message
    }

    func setConfirmMessage(_ message: String) {
        confirmMessage = message
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
