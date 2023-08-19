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

    let canvasView: PKCanvasView

    func makeUIView(context: Context) -> UIViewType {
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
    }
}
