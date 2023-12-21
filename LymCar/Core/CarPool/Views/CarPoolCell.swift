//
//  CarPoolCell.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

struct CarPoolCell: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("춘천역 경춘선")
                .font(.system(size: 20, weight: .semibold))
            HStack {
                Image(systemName: "arrow.turn.down.right")
                    .foregroundStyle(Color.theme.brandColor)
                
                Text("한림대학교 대학본부")
                    .font(.system(size: 20, weight: .semibold))
                    .lineLimit(2)
            }
            .padding(.bottom, 13)
            
            Text("여성끼리 탑승하기")
                .font(.system(size: 13))
                
            Text("오늘 오후 2:40")
                .font(.system(size: 13))
                .padding(.top, 3)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("지금 위치에서")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.theme.brandColor)
                    Text("5m")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.theme.brandColor)
                }
                Spacer()
                
                Text("2/4")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundStyle(Color.theme.brandColor)
            }
            .padding(.top, 40)
        }
        .padding(14)
        .frame(width: 180)
        .background(Color.theme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.theme.brandColor.opacity(0.3), radius: 3, y: 2)
        .padding(.top, 14)
    }
}

#Preview {
    CarPoolCell()
}
