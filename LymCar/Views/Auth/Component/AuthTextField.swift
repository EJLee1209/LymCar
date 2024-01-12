//
//  AuthTextField.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI
struct AuthTextField: View {
    @Binding var text: String
    @State var isHidden: Bool = true
    let inputType: AuthTextFieldType
    let height: CGFloat
    let isShowTitle: Bool
    
    init(
        text: Binding<String>,
        inputType: AuthTextFieldType,
        height: CGFloat = 36.0,
        isShowTitle: Bool = true
    ) {
        self._text = text
        self.inputType = inputType
        self.height = height
        self.isShowTitle = isShowTitle
    }
    
    var body: some View {
        VStack(spacing: 6) {
            if isShowTitle {
                HStack(alignment: .bottom) {
                    Text(inputType.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                    
                    if inputType == .password {
                        Text("영문 대/소문자, 숫자, 특수문자 포함 8~16자")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.theme.secondaryTextColor)
                    }
                    
                    Spacer()
                }
            }
            HStack {
                if !isHidden {
                    TextField(text: $text) {
                        Text(inputType.placeHolder)
                    }
                    .font(.system(size: 16))
                    .foregroundStyle(Color.theme.primaryTextColor)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .tint(Color.theme.brandColor)
                    
                } else {
                    SecureField(text: $text) {
                        Text(inputType.placeHolder)
                    }
                    .font(.system(size: 16))
                    .foregroundStyle(Color.theme.primaryTextColor)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .tint(Color.theme.brandColor)
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
            .frame(height: height)
            .background(Color.theme.secondaryBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .onAppear {
            switch inputType {
            case .password, .confirmPassword:
                break
            default:
                isHidden = false
            }
        }
    }
}

#Preview {
    AuthTextField(
        text: .constant(""),
        inputType: .password
    )
}
