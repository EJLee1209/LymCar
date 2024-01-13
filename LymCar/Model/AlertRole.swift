//
//  AlertRole.swift
//  LymCar
//
//  Created by 이은재 on 1/12/24.
//

import SwiftUI

enum AlertRole {
    case positive(action: () -> Void)
    case negative(action: () -> Void)
    case both(positiveAction: () -> Void, negativeAction: () -> Void)
    case withTextField(
        text: Binding<String>,
        positiveAction: () -> Void,
        negativeAction: () -> Void
    )
    case none
}

