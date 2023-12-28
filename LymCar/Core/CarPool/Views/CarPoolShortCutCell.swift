//
//  CarPoolShortCutCell.swift
//  LymCar
//
//  Created by 이은재 on 12/28/23.
//

import SwiftUI

struct CarPoolShortCutCell: View {
    let carPool: CarPool
    
    var body: some View {
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
        .frame(width: UIScreen.main.bounds.width - 32)
        .background(Color.theme.brandColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 3)
        
    }
}

#Preview {
    CarPoolShortCutCell(
        carPool: CarPool.mock
    )
}
