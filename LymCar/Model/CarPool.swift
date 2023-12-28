//
//  CarPool.swift
//  LymCar
//
//  Created by 이은재 on 12/25/23.
//

import Foundation
import Firebase

struct CarPool: Codable, Equatable {
    let id: String // 식별값
    var createdAt: Timestamp = Timestamp()
    let departurePlace: Location // 출발지
    let destination: Location // 목적지
    let departureDate: Date // 출발 시간
    let genderOption: String // 성별 옵션
    let participants: [String] // 참여자 uid
    let maxPersonCount: Int // 최대 참여자 수
    var personCount: Int = 1 // 참여자 수
    var isActivate: Bool = true // 방 활성화 여부
    
    var personCountPerMaxPersonCount: String { return "\(personCount)/\(maxPersonCount)" }
    
    var prettyFormattedDepartureDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h시 mm분"
        return formatter.string(from: self.departureDate)
    }
    
}
