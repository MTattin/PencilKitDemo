//
//  DrawingView.swift
//  PencilKitDemo
//
//  Created by Masakiyo Tachikawa on 2023/08/17.
//

import PencilKit
import SwiftUI

struct DrawingView: View {

    @Environment(\.dismiss) var dismiss

    let baseImage: UIImage

    @StateObject private var viewModel = DrawingViewModel()

    @State private var toolPicker = PKToolPicker()
    @State private var canvasView = PKCanvasView()
    @State private var showProgress: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Image(uiImage: baseImage)
                    .ignoresSafeArea(.all)

                PencilKitView(
                    drawingPolicy: .anyInput,
                    toolPicker: $toolPicker,
                    canvasView: $canvasView
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    canvasView.delegate = viewModel
                }
            }
            .ignoresSafeArea(.all)
            .progressing(showProgress)
            .alert(
                "Error",
                isPresented: $viewModel.showError,
                actions: {},
                message: {
                    Text(viewModel.errorMessage)
                }
            )
            .alert(
                "Warning",
                isPresented: $viewModel.showConfirm,
                actions: {
                    Button(role: .destructive) {
                        dismiss()
                    } label: {
                        Text("OK")
                    }
                },
                message: {
                    Text(viewModel.confirmMessage)
                }
            )
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    HStack {
                        dismissButton
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    HStack(spacing: 2.5) {
                        toolButton
                        saveButton
                        restartButton
                        pauseButton
                        undoButton
                        redoButton
                        trashButton
                        helpButton
                    }
                }
            }
        }
    }
}

@MainActor
private extension DrawingView {
    /// Dismiss
    var dismissButton: some View {
        Button {
            guard viewModel.hasModifiedDrawing else {
                dismiss()
                return
            }
            viewModel.setConfirmMessage("""
                When you return to the top screen, the history of undo and redo will be deleted.
                """
            )
        } label: {
            Image(systemName: "xmark.circle")
        }
    }
    /// tool display & hide
    var toolButton: some View {
        Button {
            if toolPicker.isVisible {
                toolPicker.setVisible(false, forFirstResponder: canvasView)
            } else {
                toolPicker.setVisible(true, forFirstResponder: canvasView)
                toolPicker.addObserver(canvasView)
                canvasView.becomeFirstResponder()
            }
        } label: {
            Image(systemName: "pencil.tip.crop.circle")
        }
    }
    /// Save to Album
    var saveButton: some View {
        Button {
            viewModel.setErrorMessage("""
                Sorry!!
                Not implement yet...
                """
            )
        } label: {
            Image(systemName: "camera.circle")
        }
    }
    /// 再開用
    var restartButton: some View {
        Button {
            showProgress = true
            Task {
                try await Task.sleep(for: .seconds(0.5))
                canvasView.drawing = await viewModel.loadDrawing()
                showProgress = false
            }
        } label: {
            Image(systemName: "play.circle")
        }
    }
    /// 中断用
    var pauseButton: some View {
        Button {
            guard viewModel.hasModifiedDrawing, !canvasView.drawing.strokes.isEmpty else {
                return
            }
            showProgress = true
            Task {
                await viewModel.saveDrawing(canvasView.drawing)
                canvasView.drawing = PKDrawing()
                try await Task.sleep(for: .seconds(0.5))
                showProgress = false
            }
        } label: {
            Image(systemName: "pause.circle")
        }
    }
    /// Undo
    var undoButton: some View {
        Button {
            canvasView.undoManager?.undo()
        } label: {
            Image(systemName: "arrow.uturn.backward.circle")
        }
    }
    /// Redo
    var redoButton: some View {
        Button {
            canvasView.undoManager?.redo()
        } label: {
            Image(systemName: "arrow.uturn.forward.circle")
        }
    }
    /// Trash
    var trashButton: some View {
        Button {
            canvasView.drawing = PKDrawing()
        } label: {
            Image(systemName: "trash.circle")
        }
    }
    /// Help
    var helpButton: some View {
        Button {
            viewModel.setErrorMessage("""
                Sorry!!
                Not implement yet...
                """
            )
        } label: {
            Image(systemName: "questionmark.circle")
        }
    }
}
