//
//  AuthTextField.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//



import SwiftUI
struct AuthTextField: View {
    @Binding var text: String
    @State var isHidden: Bool = false
    let inputType: AuthTextFieldType
    
    var body: some View {
        VStack(spacing: 6) {
            Text(inputType.rawValue)
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                if !isHidden {
                    TextField(text: $text) {
                        Text(inputType.placeHolder)
                    }
                    .font(.system(size: 16))
                    .foregroundStyle(Color.theme.primaryTextColor)
                    
                } else {
                    SecureField(text: $text) {
                        Text(inputType.placeHolder)
                    }
                    .font(.system(size: 16))
                    .foregroundStyle(Color.theme.primaryTextColor)
                }
                
                if inputType == .password || inputType == .confirmPassword {
                    Button(action: {
                        isHidden.toggle()
                    }, label: {
                        Image(systemName: isHidden ? "eye.slash" : "eye")
                            .tint(Color.theme.secondaryTextColor)
                    })
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(Color.theme.secondaryBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    AuthTextField(
        text: .constant(""),
        inputType: .password
    )
}
