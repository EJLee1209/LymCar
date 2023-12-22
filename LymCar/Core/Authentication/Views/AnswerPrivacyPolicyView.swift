//
//  PrivacyPolicyView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI

struct AnswerPrivacyPolicyView: View {
    @Binding var isAgreeForPrivacyPolicy: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Text("개인정보처리방침")
                .font(.system(size: 14, weight: .medium))
                .underline()
            Text("에 동의합니다")
                .font(.system(size: 14))
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 1)
                .fill(isAgreeForPrivacyPolicy ? Color.theme.brandColor : Color.theme.secondaryTextColor)
                .frame(width: 20, height: 20)
                .onTapGesture {
                    withAnimation {
                        isAgreeForPrivacyPolicy.toggle()
                    }
                }
        }
    }
}

#Preview {
    AnswerPrivacyPolicyView(isAgreeForPrivacyPolicy: .constant(false))
}
