//
//  RegisterView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//


import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var appData: AppData
    @StateObject var viewModel: ViewModel
    @Binding var loginViewIsPresented: Bool
    
    init(
        loginViewIsPresented: Binding<Bool>,
        authManager: AuthManagerType
    ) {
        self._loginViewIsPresented = loginViewIsPresented
        _viewModel = .init(wrappedValue: .init(authManager: authManager))
    }
    
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            /// 뒤로가기 버튼
            AuthBackButton(authStep: $viewModel.authStep)
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
                    Text(viewModel.authStep.title)
                        .font(.system(size: 24, weight: .heavy))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 27)
                        .foregroundStyle(Color.theme.primaryTextColor)
                    
                    Text(viewModel.authStep.description)
                        .font(.system(size: 15, weight: .medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 5)
                        .foregroundStyle(Color.theme.primaryTextColor)
                    
                    Divider()
                        .padding(.top, 17)
                    
                    currentStepBody
                        .padding(.top, 17)
                        .submitLabel(.next)
                        .onSubmit {
                            withAnimation {
                                viewModel.buttonAction()
                            }
                        }
                    
                    Spacer()
                    
                    RoundedActionButton(
                        label: buttonLabel(),
                        action: {
                            withAnimation {
                                viewModel.buttonAction()
                            }
                        },
                        backgroundColor: buttonBackgroundColor(),
                        labelColor: buttonLabelColor()
                    )
                    .padding(.bottom, 47)
                    .disabled(!viewModel.buttonIsEnabled())
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
        .alert(
            viewModel.alertMessage,
            isPresented: $viewModel.alertIsPresented
        ) {
            Button {
                switch viewModel.viewState {
                case .successToNetworkRequest(let user):
                    appData.currentUser = user
                    appData.subscribeUserCarPool()
                    loginViewIsPresented.toggle()
                default:
                    break
                }
                viewModel.viewState = .none
            } label: {
                Text("확인")
                    .font(.system(size: 15))
            }
        }
        .loadingProgress(viewState: $viewModel.viewState)
    }
    
    private func buttonBackgroundColor() -> Color {
        return viewModel.buttonIsEnabled() ? Color.theme.brandColor : Color.theme.secondaryBackgroundColor
    }
    
    private func buttonLabelColor() -> Color {
        return viewModel.buttonIsEnabled() ? .white : .gray
    }
    
    private func buttonLabel() -> String {
        switch viewModel.authStep {
        case .emailVerification:
            return "인증하기"
        case .privacyPolicy:
            return "회원가입"
        default:
            return "다음"
        }
    }
    
    /// @State 프로퍼티인 authStep 의 값에 따라 다른 뷰를 구성한다.
    /// @ViewBuilder 는 Closure에서 View를 구성할 수 있도록한다.
    /// @ViewBuilder는 computedProperty 또는 메서드 앞에도 붙을 수 있다.
    @ViewBuilder
    private var currentStepBody: some View {
        switch viewModel.authStep {
        case .email:
            /// step1 - 이메일 입력 뷰
            AuthTextField(
                text: $viewModel.emailText,
                inputType: .email,
                height: 50,
                isShowTitle: false
            )
            /// step2 - 이메일 인증 코드 입력 뷰
        case .emailVerification:
            VerificationCodeView(
                numberOfFields: 6,
                code: $viewModel.emailCode
            )
        case .gender:
            /// step3 - 성별 선택 뷰
            GenderSelectionView(selectedGender: $viewModel.gender)
        case .name:
            /// step4 - 이름 입력 뷰
            AuthTextField(
                text: $viewModel.nameText,
                inputType: .name
            )
        case .password:
            /// step5 - 비밀번호 입력 뷰
            AuthTextField(
                text: $viewModel.passwordText,
                inputType: .password
            )
        case .passwordConfirm:
            /// step6 - 비밀번호 확인 입력 뷰
            AuthTextField(
                text: $viewModel.passwordConfirmText,
                inputType: .confirmPassword
            )
        case .privacyPolicy:
            /// step7 - 개인정보처리방침 동의 뷰 & 회원가입 요청
            AnswerPrivacyPolicyView(isAgreeForPrivacyPolicy: $viewModel.isAgreeForPrivacyPolicy)
            
            
        }
    }
    
    
    
}

#Preview {
    RegisterView(
        loginViewIsPresented: .constant(false),
        authManager: AuthManager()
    )
    .environmentObject(
        AppData(
            authManager: AuthManager(),
            carPoolManager: CarPoolManager(),
            locationSearchManager: LocationSearchManager(),
            messageManager: MessageManager()
        )
    )
}
