//
//  OptionView.swift
//  LymCar
//
//  Created by 이은재 on 12/24/23.
//

import SwiftUI

struct OptionView: View {
    let title: String
    @Binding var isActivate: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.theme.primaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("동성끼리 탑승하기")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    
                    if !isActivate {
                        Text("선택하지 않으면 성별 상관없이 참여할 수 있습니다")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.theme.red)
                    }
                }
                
                Spacer()
                Rectangle()
                    .fill(isActivate ? Color.theme.brandColor : Color.theme.secondaryTextColor)
                    .frame(width: 20, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 1))
                    .onTapGesture {
                        isActivate.toggle()
                    }
                    
            }
        }
    }
}

#Preview {
    OptionView(
        title: "탑승 옵션",
        isActivate: .constant(false)
    )
}
