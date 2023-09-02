//
//  ToastModifier.swift
//  PencilKitDemo
//
//  Created by Masakiyo Tachikawa on 2023/09/02.
//

import SwiftUI

struct ToastModifier: ViewModifier {

    let model: ToastMessageModel

    @State private var opacityContent = 0.0

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .bottom) {
            if model.show {
                HStack {
                    Text(model.message)
                        .multilineTextAlignment(.leading)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(uiColor: .systemGray6).opacity(0.95))
                        }
                }
                .padding([.horizontal], 20)
                .offset(y: -10)
                .opacity(opacityContent)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.2)) {
                        opacityContent = 1.0
                    }
                }
                .onTapGesture {
                    model.tapped?()
                }
            }
        }
    }
}

extension View {
    func toast(_ model: ToastMessageModel) -> some View {
        modifier(ToastModifier(model: model))
    }
}

#if DEBUG
struct ToastModifierContentView: View {
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            Text("Hello, World!")
        }
        .toast(
            ToastMessageModel(
                show: true,
                message: """
                    Sample Sample Sample Sample Sample Sample Sample Sample
                    Sample Sample Sample Sample Sample Sample Sample Sample Sample Sample Sample
                    """
            )
        )
    }
}

struct ToastModifier_Previews: PreviewProvider {
    static var previews: some View {
        ToastModifierContentView()
    }
}
#endif
