//
//  MainTabView.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

struct MainTabView: View {
    @Binding var selectedItem: TabMenuItem
    private let screenWidth = UIScreen.main.bounds.width
    private let tabMenuItems = TabMenuItem.allCases
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                ForEach(tabMenuItems, id: \.self) { menu in
                    Button(action: {
                        withAnimation {
                            selectedItem = menu
                        }
                    }, label: {
                        Image(menu.tabImageString)
                            .renderingMode(.template)
                            .foregroundStyle(menuItemColor(menu))
                            .frame(width: screenWidth / CGFloat(tabMenuItems.count))
                    })
                }
            }
            .frame(width: screenWidth, height: 90)
            .background(Color.theme.backgroundColor)
            .cornerRadius(30, corners: [.topLeft, .topRight])
            
            Capsule()
                .frame(width: menuBarWidth(), height: 4)
                .foregroundStyle(Color.theme.brandColor)
                .offset(x: menuBarOffsetX(), y: 5)
        }
        
    }
    
    func menuItemColor(_ menu: TabMenuItem) -> Color {
        return selectedItem == menu ? Color.theme.brandColor : Color.theme.secondaryTextColor
    }
    
    func menuBarOffsetX() -> CGFloat {
        switch selectedItem {
        case .history:
            return -screenWidth/3
        case .map:
            return 0
        case .menu:
            return screenWidth/3
        }
    }
    
    func menuBarWidth() -> CGFloat {
        let width = screenWidth / CGFloat(tabMenuItems.count)
        
        switch selectedItem {
        case .history:
            return width - 35
        case .map:
            return width
        case .menu:
            return width - 35
        }
    }
    
    
    
}

#Preview {
    MainTabView(selectedItem: .constant(.menu))
}
