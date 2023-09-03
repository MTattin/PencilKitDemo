//
//  SaveConfirmationView.swift
//  PencilKitDemo
//
//  Created by Masakiyo Tachikawa on 2023/08/17.
//

import PencilKit
import SwiftUI

struct SaveConfirmationView: View {

    let model: SaveConfirmMessageModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                Text(model.message)
                    .font(.caption)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding([.top, .horizontal], 30)

                VStack(spacing: 0) {
                    Divider()

                    Button("Save just the drawn image") {
                        model.selected?(.drawnImage)
                    }
                    .buttonStyle(FullWidthButtonStyle())

                    Divider()

                    Button("Save also the background image") {
                        model.selected?(.combinedImage)
                    }
                    .buttonStyle(FullWidthButtonStyle())

                    Divider()

                    Button("Cancel") {
                        model.selected?(.cancel)
                    }
                    .buttonStyle(FullWidthButtonStyle(isCancel: true))

                    Divider()

                    Spacer(minLength: 0)
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

private struct FullWidthButtonStyle: ButtonStyle {

    let isCancel: Bool

    init(isCancel: Bool = false) {
        self.isCancel = isCancel
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding([.vertical], 15)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color(uiColor: .systemBlue))
            .font(.callout)
            .fontWeight(isCancel ? .bold : .regular)
            .background(
                configuration.isPressed
                ? Color(uiColor: .systemGray5)
                : Color(uiColor: .systemBackground)
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SaveConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        SaveConfirmationView(model: .init())
    }
}
