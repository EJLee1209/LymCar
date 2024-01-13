//
//  AlertModifier.swift
//  LymCar
//
//  Created by 이은재 on 1/11/24.
//

import SwiftUI

struct AlertModifier: ViewModifier {
    let role: AlertRole
    let alertMessage: String
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .alert(
                alertMessage,
                isPresented: $isPresented
            ) {
                switch role {
                case .positive(let action):
                    Button(
                        role: .cancel,
                        action: action,
                        label: {
                            Text("확인")
                        })
                case .negative(let action):
                    Button(
                        role: .cancel,
                        action: action,
                        label: {
                            Text("취소")
                        })
                case .both(let positiveAction, let negativeAction):
                    Button(
                        role: .destructive,
                        action: positiveAction,
                        label: {
                            Text("확인")
                        })
                    Button(
                        role: .cancel,
                        action: negativeAction,
                        label: {
                            Text("취소")
                        })
                case let .withTextField(
                    text,
                    positiveAction,
                    negativeAction
                ):
                    TextField("패스워드", text: text)
                    Button(
                        role: .destructive,
                        action: positiveAction,
                        label: {
                            Text("확인")
                        })
                    Button(
                        role: .cancel,
                        action: negativeAction,
                        label: {
                            Text("취소")
                        })
                case .none:
                    EmptyView()
                }
            }
    }
}
