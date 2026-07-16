//
//  Path + Extension.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 15.07.2026.
//

import SwiftUI

extension Path {
    /// Добавляет capsule-контур внутри заданного прямоугольника.
    ///
    /// - Parameter rect: ограничивающий прямоугольник capsule.
    mutating func addCapsule(in rect: CGRect) {
        let radius = min(rect.width, rect.height) / 2
        addRoundedRect(in: rect, cornerSize: CGSize(width: radius, height: radius))
    }
}
