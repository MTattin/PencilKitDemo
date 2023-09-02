//
//  SaveConfirmMessageModel.swift
//  PencilKitDemo
//
//  Created by Masakiyo Tachikawa on 2023/09/02.
//

import Foundation

struct SaveConfirmMessageModel {
    var show: Bool = false
    var message: String = ""
    var selected: ((SaveConfirmMessageResponseType) -> Void)?
}

enum SaveConfirmMessageResponseType {
    case drawnImage
    case combinedImage
    case cancel
}
