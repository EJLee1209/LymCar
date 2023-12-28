//
//  CarPoolShortcutView.swift
//  LymCar
//
//  Created by 이은재 on 12/26/23.
//

import SwiftUI

struct CarPoolShortcutListView: View {
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(appData.userCarPoolList) { carPool in
                    if let vm = appData.makeChatRoomVM(with: carPool) {
                        NavigationLink {
                            ChatRoomView(viewModel: vm)
                        } label: {
                            CarPoolShortCutCell(carPool: carPool)
                        }
                    } else {
                        CarPoolShortCutCell(carPool: carPool)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(maxHeight: 70)
    }
}

#Preview {
    CarPoolShortcutListView()
        .environmentObject(AppData(
            authManager: AuthManager(), carPoolManager: CarPoolManager()
        ))
}
