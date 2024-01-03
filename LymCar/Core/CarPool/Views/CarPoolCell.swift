//
//  CarPoolCell.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

struct CarPoolCell: View {
    @EnvironmentObject var appData: AppData
    let carPool: CarPool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(carPool.departurePlace.placeName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(firstTextColor())
                .lineLimit(2)
            HStack {
                Image(systemName: "arrow.turn.down.right")
                    .foregroundStyle(secondTextColor())
                
                Text(carPool.destination.placeName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(firstTextColor())
                    .lineLimit(2)
            }
            .padding(.bottom, 13)
            
            Text(carPool.genderOption == "선택 안함" ? "성별 상관없음" : "\(carPool.genderOption)끼리 탑승하기")
                .font(.system(size: 13))
                .foregroundStyle(firstTextColor())
                
            Text(carPool.prettyFormattedDepartureDate)
                .font(.system(size: 13))
                .padding(.top, 3)
                .foregroundStyle(firstTextColor())
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("지금 위치에서")
                        .font(.system(size: 10))
                        .foregroundStyle(secondTextColor())
                    Text("5m")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(secondTextColor())
                }
                Spacer()
                
                Text(carPool.personCountPerMaxPersonCount)
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundStyle(secondTextColor())
            }
        }
        .padding(14)
        .frame(width: 180, height: 225)
        .background(backgroundColor())
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.theme.brandColor.opacity(0.3), radius: 3, y: 2)
        .padding(.top, 14)
    }
    
    var isMyCarPool: Bool {
        return carPool.participants.contains(appData.currentUser?.uid ?? "")
    }
    
    func backgroundColor() -> Color {
        return isMyCarPool ? Color.theme.brandColor : Color.theme.backgroundColor
    }
    
    func firstTextColor() -> Color {
        return isMyCarPool ? .white : Color.theme.primaryTextColor
    }
    
    func secondTextColor() -> Color {
        return isMyCarPool ? .white : Color.theme.brandColor
    }
}

#Preview {
    CarPoolCell(
        carPool: .init(id: "", departurePlace: .init(placeName: "춘천역 경춘선", latitude: 0, longitude: 0), destination: .init(placeName: "한림대학교 대학본부", latitude: 0, longitude: 0), departureDate: Date(), genderOption: "남성", participants: [], maxPersonCount: 4)
    )
    .environmentObject(
        AppData(
            authManager: AuthManager(),
            carPoolManager: CarPoolManager(),
            locationSearchManager: LocationSearchManager(),
            messageManager: MessageManager()
        )
    )
}
