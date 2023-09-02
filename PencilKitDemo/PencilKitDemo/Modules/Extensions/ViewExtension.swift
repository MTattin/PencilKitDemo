//
//  ViewExtension.swift
//  PencilKitDemo
//
//  Created by Masakiyo Tachikawa on 2023/08/18.
//

import SwiftUI

extension View {

    func errorMessage(_ show: Binding<Bool>, model: ErrorMessageModel) -> some View {
        self.alert(
            model.title,
            isPresented: show,
            actions: {},
            message: { Text(model.message) }
        )
    }

    func confirmMessage(_ show: Binding<Bool>, model: ConfirmMessageModel) -> some View {
        self.alert(
            model.title,
            isPresented: show,
            actions: {
                Button(role: .cancel, action: {}, label: { Text("Cancel") })
                Button(role: model.rightButtonRole) {
                    model.action?()
                } label: {
                    Text(model.rightButtonTitle)
                }
            },
            message: {
                Text(model.message)
            }
        )
    }
}
