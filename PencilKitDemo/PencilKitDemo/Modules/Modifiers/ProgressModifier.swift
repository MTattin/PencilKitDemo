//
//  ProgressModifier.swift
//  PencilKitDemo
//
//  Created by Masakiyo Tachikawa on 2023/08/18.
//

import SwiftUI

struct ProgressModifier: ViewModifier {

    let show: Bool

    func body(content: Content) -> some View {
        ZStack {
            content.allowsHitTesting(!show)

            if show {
                Rectangle()
                    .fill(.black)
                    .opacity(0.5)
                    .ignoresSafeArea()
                
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
                .offset(y: -50)
            }
        }
    }
}

extension View {
    func progressing(_ show: Bool) -> some View {
        modifier(ProgressModifier(show: show))
    }
}
