//
//  CarPoolShortcutView.swift
//  LymCar
//
//  Created by 이은재 on 12/26/23.
//

import SwiftUI

struct CarPoolShortcutView: View {
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        if let carPool = appData.carPool {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(carPool.departurePlace.placeName)
                        .lineLimit(1)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    HStack {
                        Image(systemName: "arrow.turn.down.right")
                            .foregroundStyle(.white)
                        
                        Text(carPool.destination.placeName)
                            .lineLimit(1)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 0) {
                    Text(carPool.prettyFormattedDepartureDate)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white)
                    
                    Text(carPool.personCountPerMaxPersonCount)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.theme.brandColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 3)
        }
    }
}

#Preview {
    CarPoolShortcutView()
        .environmentObject(AppData(
            authManager: AuthManager(), carPoolManager: CarPoolManager()
        ))
}
