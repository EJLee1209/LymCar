//
//  PermissionRequestView.swift
//  LymCar
//
//  Created by 이은재 on 1/13/24.
//

import SwiftUI
import CoreLocation

struct PermissionRequestView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Color.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                
                Text("시작하기 전에")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.theme.primaryTextColor)
                
                Text("더 나은 서비스를 위해\n동의가 필요한 내용을 확인해주세요")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.theme.primaryTextColor)
                    .multilineTextAlignment(.center)
                
                Circle()
                    .fill(Color.theme.brandColor)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 20)
                
                Text("채팅 메세지 알림을 받을 수 있습니다")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.theme.primaryTextColor)
                    .multilineTextAlignment(.center)
                
                Circle()
                    .fill(Color.theme.brandColor)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "map.fill")
                            .foregroundStyle(.white)
                    }
                Text("사용자 위치를 파악하여 지도에 표시하고,\n 출발지로 설정하기 위해 사용합니다.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.theme.primaryTextColor)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            RoundedActionButton(label: "림카 시작하기", action: {
                Task {
                    let isGranted = try await requestNotificationPermission()
                    print("DEBUG: 알림 권한 \(isGranted)")
                    requestLocationPermission()
                }
                
                
                dismiss()
            })
            .padding([.horizontal, .bottom])
        }
    }
    
    private func requestNotificationPermission() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        return try await UNUserNotificationCenter
            .current()
            .requestAuthorization(options: options)
    }
    
    private func requestLocationPermission() {
        CLLocationManager().requestWhenInUseAuthorization()
    }
}

#Preview {
    PermissionRequestView()
}
