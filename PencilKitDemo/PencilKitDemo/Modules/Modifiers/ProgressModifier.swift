//
//  ProgressModifier.swift
//  PencilKitDemo
//
//  Created by Masakiyo Tachikawa on 2023/08/18.
//

import SwiftUI

struct ProgressModifier: ViewModifier {

    let show: Bool

    @State private var opacityOverlay = 0.0
    @State private var opacityContent = 0.0

    func body(content: Content) -> some View {
        ZStack {
            content.allowsHitTesting(!show)

            if show {
                Rectangle()
                    .fill(.black)
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .opacity(opacityOverlay)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.1)) {
                            opacityOverlay = 1.0
                        }
                    }

                VStack(spacing: 10) {
                    ProgressView()
                    Text("Loading...")
                        .font(.caption)
                }
                .padding(30)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .systemGray6))
                }
                .offset(y: -20)
                .opacity(opacityContent)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.2)) {
                        opacityContent = 1.0
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
    }
}

extension View {
    func progressing(_ show: Bool) -> some View {
        modifier(ProgressModifier(show: show))
    }
}
