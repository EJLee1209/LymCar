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
    let participants: [String] // 참여자 uid
    let maxPersonCount: Int // 최대 참여자 수
    var personCount: Int = 1 // 참여자 수
    var isActivate: Bool = true // 방 활성화 여부
    
    var personCountPerMaxPersonCount: String { return "\(personCount)/\(maxPersonCount)" }
    
    var prettyFormattedDepartureDate: String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")

        if calendar.isDateInToday(departureDate) {
            dateFormatter.dateFormat = "오늘 a h:m"
        } else if calendar.isDateInTomorrow(departureDate) {
            dateFormatter.dateFormat = "내일 a h:m"
        } else {
            dateFormatter.dateFormat = "M월 d일 a h:m"
        }

        return dateFormatter.string(from: departureDate)
    }
    
    
    static let mock: Self = .init(id: "", departurePlace: .init(placeName: "춘천역", latitude: 0, longitude: 0), destination: .init(placeName: "한림대학교 대학본부", latitude: 0, longitude: 0), departureDate: Date(), genderOption: "남성", participants: [], maxPersonCount: 4)
}
