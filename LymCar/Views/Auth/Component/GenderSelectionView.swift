//
//  GenderSelectionView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI

struct GenderSelectionView: View {
    @Binding var selectedGender: Gender
    
    var body: some View {
        VStack(spacing: 7) {
            Text("성별")
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 0) {
                Spacer()
                ForEach(Gender.allCases, id: \.self) { gender in
                    Button(action: {
                        withAnimation {
                            selectedGender = gender
                        }
                    }, label: {
                        Text(gender.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(buttonLabelColor(gender))
                            .frame(width: 92, height: 36)
                    })
                    .background(buttonBackgroundColor(gender))
                    .clipShape(RoundedRectangle(cornerRadius: 46))
                    .overlay {
                        RoundedRectangle(cornerRadius: 46)
                            .stroke(Color.theme.brandColor, lineWidth: 1)
                    }
                    Spacer()
                }
            }
            
            if selectedGender == .none {
                Text("\"선택 안함\" 선택 시 카풀 참여에 제한이 있을 수 있습니다.")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.theme.red)
            }

        }
    }
    
    func buttonBackgroundColor(_ gender: Gender) -> Color {
        return gender == selectedGender ? Color.theme.brandColor : Color.theme.backgroundColor
    }
    
    func buttonLabelColor(_ gender: Gender) -> Color {
        return gender == selectedGender ? .white : Color.theme.primaryTextColor
    }
}

#Preview {
    GenderSelectionView(selectedGender: .constant(.none))
        
}
