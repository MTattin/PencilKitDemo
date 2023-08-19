//
//  PencilKitView.swift
//  PencilKitDemo
//
//  Created by Masakiyo Tachikawa on 2023/08/17.
//

import PencilKit
import SwiftUI

struct PencilKitView: UIViewRepresentable {

    typealias UIViewType = PKCanvasView

    let drawingPolicy: PKCanvasViewDrawingPolicy

    @Binding var toolPicker: PKToolPicker
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> UIViewType {
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = drawingPolicy
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
    }
}
