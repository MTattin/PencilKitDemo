//
//  ConfirmMessageModel.swift
//  PencilKitDemo
//
//  Created by Masakiyo Tachikawa on 2023/09/02.
//

import SwiftUI

struct ConfirmMessageModel {
    var show: Bool = false
    var title: String = ""
    var message: String = ""
    var rightButtonRole: ButtonRole?
    var rightButtonTitle: String = "OK"
    var action: (() -> Void)?
}
