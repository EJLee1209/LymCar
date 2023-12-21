//
//  TabMenuItem.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import Foundation

enum TabMenuItem: Int, CaseIterable {
    case history
    case map
    case menu
    
    var tabImageString: String {
        switch self {
        case .history:
            return "message-circle"
        case .map:
            return "map"
        case .menu:
            return "menu"
        }
    }
}
