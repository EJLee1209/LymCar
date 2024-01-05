//
//  FavoriteButton.swift
//  LymCar
//
//  Created by 이은재 on 1/5/24.
//

import SwiftUI

struct FavoriteButton: View {
    let label: String
    
    var body: some View {
        Text(label)
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(Color.theme.primaryTextColor)
            .padding(.horizontal, 24)
            .frame(height: 35)
            .background(Color.theme.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 50))
            .overlay {
                RoundedRectangle(cornerRadius: 50)
                    .stroke(lineWidth: 1)
                    .fill(Color.theme.brandColor)
            }
            .shadow(radius: 4)
    }
}

#Preview {
    FavoriteButton(label: "춘천역")
}
