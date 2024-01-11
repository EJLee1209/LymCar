//
//  Constant.swift
//  LymCar
//
//  Created by 이은재 on 1/2/24.
//

import Foundation
import UIKit

final class Constant {
    static let baseURL: String = "http://192.168.219.103:8080"
    
    
    /// getDeviceUUID
    /// - Returns: 디바이스 고유 식별값
    static func getDeviceUUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
}
