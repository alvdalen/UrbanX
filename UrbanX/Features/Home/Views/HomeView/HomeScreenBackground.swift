//
//  HomeScreenBackground.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 17.06.2026.
//

import SwiftUI

/// Фон главного экрана: звёздное поле под полупрозрачной тематической заливкой `UXColor.homeScreenFill`.
struct HomeScreenBackground: View {
    // MARK: - Body
    var body: some View {
        ZStack {
            starFieldBackground
            themeFillOverlay
        }
    }


    // MARK: - Звёздное поле

    /// Звёздное небо — видно сквозь полупрозрачную заливку в тёмной теме.
    private var starFieldBackground: some View {
        StarFieldBackground()
    }

    // MARK: - Тематическая заливка

    /// Полупрозрачная заливка поверх звёзд: скрывает их в светлой теме, смягчает в тёмной.
    private var themeFillOverlay: some View {
        Rectangle()
            .fill(UXColor.homeScreenFill)
            .ignoresSafeArea()
    }
}
