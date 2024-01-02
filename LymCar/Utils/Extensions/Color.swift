//
//  Color.swift
//  LymCar
//
//  Created by 이은재 on 12/21/23.
//

import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let backgroundColor = Color("BackgroundColor")
    let secondaryBackgroundColor = Color("SecondaryBackgroundColor")
    let primaryTextColor = Color("PrimaryTextColor")
    let secondaryTextColor = Color("SecondaryTextColor")
    let brandColor = Color("BrandColor")
    let red = Color("Red")
}
