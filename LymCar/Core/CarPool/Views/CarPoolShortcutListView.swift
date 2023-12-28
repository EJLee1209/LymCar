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
                    NavigationLink {
                        
                    } label: {
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
