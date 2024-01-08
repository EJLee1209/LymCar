//
//  VerificationCodeView.swift
//  LymCar
//
//  Created by 이은재 on 1/8/24.
//

import SwiftUI

struct VerificationCodeView: View {
    
    let numberOfFields: Int
    @State private var enterValue: [String]
    @FocusState private var focusField: Int?
    
    @Binding var code: Int?
    
    init(
        numberOfFields: Int,
        code: Binding<Int?>
    ) {
        self.numberOfFields = numberOfFields
        self.enterValue = Array(repeating: "", count: numberOfFields)
        self._code = code
    }
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<numberOfFields, id: \.self) { index in
                TextField(text: $enterValue[index], label: {})
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .frame(height: 60)
                    .background(Color.theme.secondaryBackgroundColor)
                    .foregroundStyle(Color.theme.primaryTextColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .focused($focusField, equals: index)
                    .onChange(of: enterValue[index]) { newValue in
                        if enterValue[index].count > 1 {
                            enterValue[index] = String(enterValue[index].suffix(1))
                        }
                        if !newValue.isEmpty {
                            if index == numberOfFields - 1 {
                                focusField = nil
                            } else {
                                focusField = (focusField ?? 0) + 1
                            }
                        } else {
                            focusField = (focusField ?? 0) - 1
                        }
                        
                        code = Int(enterValue.joined())
                    }
                    .overlay {
                        if focusField == index {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 2)
                        }
                    }
                    
            }
        }
        .padding(.horizontal)
        .onAppear {
            code = nil
        }
        
    }
}

#Preview {
    VerificationCodeView(
        numberOfFields: 6,
        code: .constant(nil)
    )
}
