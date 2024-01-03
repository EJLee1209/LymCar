//
//  CarPool.swift
//  LymCar
//
//  Created by 이은재 on 12/25/23.
//

import Foundation
import Firebase

struct CarPool: Codable, Equatable, Identifiable {
    let id: String // 식별값
    var createdAt: Timestamp = Timestamp()
    let departurePlace: Location // 출발지
    let destination: Location // 목적지
    let departureDate: Date // 출발 시간
    let genderOption: String // 성별 옵션
    var participants: [String] // 참여자 uid
    let maxPersonCount: Int // 최대 참여자 수
    var personCount: Int = 1 // 참여자 수
    var isActivate: Bool = true // 방 활성화 여부
    
    var personCountPerMaxPersonCount: String { return "\(personCount)/\(maxPersonCount)" }
    
    var prettyFormattedDepartureDate: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(departureDate) {
            return departureDate.dateToString(dateFormat: "오늘 a h:m")
        } else if calendar.isDateInTomorrow(departureDate) {
            return departureDate.dateToString(dateFormat: "내일 a h:m")
        } else {
            return departureDate.dateToString(dateFormat: "M월 d일 a h:m")
        }
    }
    static let mock: Self = .init(
        id: "31EEzdEpRlr1Wudz85rF",
        departurePlace: .init(placeName: "춘천역", latitude: 0, longitude: 0),
        destination: .init(placeName: "한림대학교 대학본부", latitude: 0, longitude: 0),
        departureDate: Date(),
        genderOption: "남성",
        participants: [],
        maxPersonCount: 4
    )
}




