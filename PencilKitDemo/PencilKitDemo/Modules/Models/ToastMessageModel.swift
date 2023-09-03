//
//  ToastMessageModel.swift
//  PencilKitDemo
//
//  Created by Masakiyo Tachikawa on 2023/09/02.
//

import Foundation

struct ToastMessageModel {
    var show: Bool = false
    var message: String = ""
    var tapped: (() -> Void)?
}
