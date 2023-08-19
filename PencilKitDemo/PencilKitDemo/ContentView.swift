//
//  ContentView.swift
//  PencilKitDemo
//
//  Created by Masakiyo Tachikawa on 2023/08/17.
//

import SwiftUI

struct ContentView: View {

    @State private var startShowDrawing: Bool = false
    @State private var showDrawing: Bool = false
    @State private var screenShotBounds: CGRect = .zero

    private var drawBaseView: some View {
        ZStack {
            GeometryReader { geometry in
                Color.clear
                    .ignoresSafeArea(.all)
                    .preference(
                        key: BoundsPreferenceKey.self,
                        value: geometry.frame(in: .global)
                    )
                    .onPreferenceChange(BoundsPreferenceKey.self) { bounds in
                        guard let bounds = bounds, !startShowDrawing else {
                            return
                        }
                        screenShotBounds = bounds
                    }
            }

            VStack(spacing: 50) {
                Image("faboll_color")
                    .resizable()
                    .frame(width: 200, height: 200)
                Text("Hello, SwiftUI")
                    .padding()
                    .border(.blue)
                Image(systemName: "camera.viewfinder")
                    .font(.largeTitle)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.yellow, .green, .blue)
                    .scaleEffect(3.0)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                drawBaseView
            }
            .ignoresSafeArea(.all)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            startShowDrawing = true
                            DispatchQueue.main.async {
                                ContentView.makeImage(
                                    from: drawBaseView,
                                    bounds: screenShotBounds
                                )
                                showDrawing = true
                                startShowDrawing = false
                            }
                        } label: {
                            Text("Draw")
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showDrawing) {
                DrawingView(baseImage: ContentView.baseImage)
            }
        }
    }
}

private extension ContentView {

    static var baseImage: UIImage = UIImage()

    @MainActor
    static func makeImage(from swiftUIView: some View, bounds: CGRect) {
        let controller = UIHostingController(rootView: swiftUIView)
        controller.safeAreaRegions.remove(.all)
        controller.view.bounds = bounds
        controller.view.backgroundColor = .clear
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        baseImage = image
    }
}

private struct BoundsPreferenceKey: PreferenceKey {

    static var defaultValue: CGRect?

    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = value ?? nextValue()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
