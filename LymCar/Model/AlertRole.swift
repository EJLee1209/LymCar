//
//  AlertRole.swift
//  LymCar
//
//  Created by 이은재 on 1/12/24.
//

import Foundation

enum AlertRole {
    case positive(action: () -> Void)
    case negative(action: () -> Void)
    case both(positiveAction: () -> Void, negativeAction: () -> Void)
    case none
}
