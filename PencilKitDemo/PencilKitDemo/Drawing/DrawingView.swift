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

    var body: some View {
        NavigationStack {
            ZStack {
                Image(uiImage: baseImage)
                    .ignoresSafeArea(.all)

                PencilKitView(canvasView: viewModel.canvasView)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        viewModel.onAppear()
                    }
            }
            .ignoresSafeArea(.all)
            .progressing(viewModel.showProgress)
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
            viewModel.dismiss(dismiss)
        } label: {
            Image(systemName: "xmark.circle")
        }
    }
    /// tool display & hide
    var toolButton: some View {
        Button {
            viewModel.toggleTool()
        } label: {
            Image(systemName: "pencil.tip.crop.circle")
        }
    }
    /// Save to Album
    var saveButton: some View {
        Button {
            viewModel.saveToAlbum()
        } label: {
            Image(systemName: "camera.circle")
        }
    }
    /// 再開用
    var restartButton: some View {
        Button {
            viewModel.restart()
        } label: {
            Image(systemName: "play.circle")
        }
    }
    /// 中断用
    var pauseButton: some View {
        Button {
            viewModel.pause()
        } label: {
            Image(systemName: "pause.circle")
        }
    }
    /// Undo
    var undoButton: some View {
        Button {
            viewModel.canvasView.undoManager?.undo()
        } label: {
            Image(systemName: "arrow.uturn.backward.circle")
        }
    }
    /// Redo
    var redoButton: some View {
        Button {
            viewModel.canvasView.undoManager?.redo()
        } label: {
            Image(systemName: "arrow.uturn.forward.circle")
        }
    }
    /// Trash
    var trashButton: some View {
        Button {
            viewModel.canvasView.drawing = PKDrawing()
        } label: {
            Image(systemName: "trash.circle")
        }
    }
    /// Help
    var helpButton: some View {
        Button {
            viewModel.help()
        } label: {
            Image(systemName: "questionmark.circle")
        }
    }
}
