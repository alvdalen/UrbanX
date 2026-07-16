//
//  Program+Preview.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 01.07.2026.
//

import Foundation

extension Program {
    /// Набор превью-программ для запуска приложения и SwiftUI previews.
    static let previewPrograms: [Program] = [
        .init(
            chip: Strings.Preview.Program.Pullups.chip,
            cardTitle: Strings.Preview.Program.Pullups.title,
            currentStep: 2,
            progress: 18.0 / 25.0,
            percentText: "72%"
        ),
        .init(
            chip: Strings.Preview.Program.Dips.chip,
            cardTitle: Strings.Preview.Program.Dips.title,
            currentStep: 4,
            progress: 12.0 / 25.0,
            percentText: "48%"
        ),
        .init(
            chip: Strings.Preview.Program.Pushups.chip,
            cardTitle: Strings.Preview.Program.Pushups.title,
            currentStep: 5,
            progress: 20.0 / 25.0,
            percentText: "80%"
        ),
        .init(
            chip: Strings.Preview.Program.Squats.chip,
            cardTitle: Strings.Preview.Program.Squats.title,
            currentStep: 3,
            progress: 5.0 / 25.0,
            percentText: "20%"
        ),
        .init(
            chip: Strings.Preview.Program.Plank.chip,
            cardTitle: Strings.Preview.Program.Plank.title,
            currentStep: 5,
            progress: 24.0 / 25.0,
            percentText: "96%"
        ),
        .init(
            chip: Strings.Preview.Program.Abs.chip,
            cardTitle: Strings.Preview.Program.Abs.title,
            currentStep: 3,
            progress: 15.0 / 25.0,
            percentText: "60%"
        )
    ]
}
