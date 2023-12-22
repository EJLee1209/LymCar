//
//  RegisterView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//


import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State var authStep: AuthStep = .email
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            /// 뒤로가기 버튼
            AuthBackButton(authStep: $authStep)
                .padding(.top, 10)
                .padding(.leading, 21)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("회원가입")
                    .font(.system(size: 40, weight: .heavy))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 21)
                    .foregroundStyle(.white)
                    .padding(.top, 100)
                
                VStack(spacing: 0) {
                    Text(authStep.title)
                        .font(.system(size: 24, weight: .heavy))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 27)
                        .foregroundStyle(Color.theme.primaryTextColor)
                    
                    Text(authStep.description)
                        .font(.system(size: 15, weight: .medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 5)
                        .foregroundStyle(Color.theme.primaryTextColor)
                    
                    showCurrentStepView
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            buttonAction()
                        }
                    }, label: {
                        Text(authStep == .privacyPolicy ? "회원가입" : "다음")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                    })
                    .background(Color.theme.brandColor)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                    .padding(.bottom, 47)
                }
                .padding(.horizontal, 21)
                .background(Color.theme.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .padding(.top, 18)
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .background {
            Image("WelcomeBackgroundImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden()
    }
    
    func buttonAction() {
        if authStep.rawValue < AuthStep.privacyPolicy.rawValue {
            authStep = AuthStep(rawValue: authStep.rawValue + 1)!
        } else {
            print("DEBUG: 회원가입 요청 email: \(viewModel.emailText), password: \(viewModel.passwordText)")
        }
    }
    
    /// @State 프로퍼티인 authStep 의 값에 따라 다른 뷰를 구성한다.
    /// @ViewBuilder 는 Closure에서 View를 구성할 수 있도록한다.
    /// @ViewBuilder는 computedProperty 또는 메서드 앞에도 붙을 수 있다.
    @ViewBuilder
    private var showCurrentStepView: some View {
        switch authStep {
        case .email:
            /// step1 - 이메일 입력 뷰
            TextField(text: $viewModel.emailText) {
                Text("이메일을 입력해주세요")
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 15)
            .background(Color.theme.secondaryBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.top, 17)
        case .gender:
            /// step2 - 성별 선택 뷰
            GenderSelectionView(selectedGender: $viewModel.gender)
        case .name:
            /// step3 - 이름 입력 뷰
            AuthTextField(text: $viewModel.name, inputType: .name)
                .padding(.top, 17)
        case .password:
            /// step4 - 비밀번호 입력 뷰
            AuthTextField(text: $viewModel.passwordText, inputType: .password)
                .padding(.top, 17)
        case .passwordConfirm:
            /// step5 - 비밀번호 확인 입력 뷰
            AuthTextField(text: $viewModel.passwordConfirmText, inputType: .confirmPassword)
                .padding(.top, 17)
        case .privacyPolicy:
            /// step6 - 개인정보처리방침 동의 뷰 & 회원가입 요청
            AnswerPrivacyPolicyView(isAgreeForPrivacyPolicy: $viewModel.isAgreeForPrivacyPolicy)
                .padding(.top, 17)
        }
    }
    
    
    
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel(authManager: AuthManager()))
}
