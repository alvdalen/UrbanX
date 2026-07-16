//
//  UXMetrics.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 04.07.2026.
//

import SwiftUI

// MARK: - UXScaleAxis
/// Ось, по которой применяется множитель scale.
enum UXScaleAxis {
    /// Ширина экрана — frame width, горизонтальный font.
    case horizontal

    /// Высота экрана — frame height.
    case vertical
}

// MARK: - UXScreenSizeClass
/// Класс размера экрана относительно эталона iPhone 17 Pro.
enum UXScreenSizeClass: Equatable {
    /// Мелкий экран (SE и меньше эталона).
    case compact

    /// Эталон (iPhone 17 Pro).
    case etalon

    /// Крупный экран (Pro Max и выше эталона).
    case large
}

// MARK: - UXAdaptiveScale
/// Пара множителей scale для текущего размера экрана.
struct UXAdaptiveScale: Equatable {
    /// Множитель по ширине.
    let horizontal: CGFloat

    /// Множитель по высоте.
    let vertical: CGFloat

    /// Etalon pt × множитель текущего устройства.
    func scaled(_ base: CGFloat, axis: UXScaleAxis) -> CGFloat {
        let factor: CGFloat = switch axis {
        case .horizontal: horizontal
        case .vertical: vertical
        }

        return (base * factor).rounded(.toNearestOrAwayFromZero)
    }
}

// MARK: - UXMetrics
/// Расчёт scale по размеру экрана относительно эталона iPhone 17 Pro.
enum UXMetrics {
    /// Множитель etalon (iPhone 17 Pro и «не указано» для compact / large).
    static let etalonMultiplier: CGFloat = 1

    /// `nil` compact / large → etalon (1.0) для этой границы.
    static func resolvedMultipliers(
        compact: CGFloat?,
        large: CGFloat?
    ) -> (compact: CGFloat, large: CGFloat) {
        (compact ?? etalonMultiplier, large ?? etalonMultiplier)
    }

    /// Etalon: iPhone 17 Pro (multiplier 1.0).
    static let referenceSize = CGSize(width: 402, height: 852)

    /// Нижняя граница интерполяции: iPhone SE.
    static let compactSize = CGSize(width: 375, height: 667)

    /// Верхняя граница интерполяции: iPhone Pro Max.
    static let largeSize = CGSize(width: 440, height: 956)

    /// Класс размера экрана по высоте относительно SE / Pro / Max.
    ///
    /// - Parameter size: размер окна или экрана.
    ///
    /// - Returns: `.compact` ниже эталона, `.etalon` на эталоне, `.large` выше.
    static func sizeClass(for size: CGSize) -> UXScreenSizeClass {
        let height = size.height
        if height < referenceSize.height {
            return .compact
        }
        if height > referenceSize.height {
            return .large
        }
        return .etalon
    }

    /// Класс размера текущего экрана.
    static var screenSizeClass: UXScreenSizeClass {
        sizeClass(for: screenSize)
    }

    /// Линейная интерполяция множителя между SE → Pro → Max.
    static func adaptiveScale(
        for size: CGSize,
        compactMultiplier: CGFloat,
        largeMultiplier: CGFloat
    ) -> UXAdaptiveScale {
        UXAdaptiveScale(
            horizontal: interpolatedMultiplier(
                dimension: size.width,
                compact: compactSize.width,
                reference: referenceSize.width,
                large: largeSize.width,
                compactMultiplier: compactMultiplier,
                largeMultiplier: largeMultiplier
            ),
            vertical: interpolatedMultiplier(
                dimension: size.height,
                compact: compactSize.height,
                reference: referenceSize.height,
                large: largeSize.height,
                compactMultiplier: compactMultiplier,
                largeMultiplier: largeMultiplier
            )
        )
    }

    /// Размер key window активной foreground-сцены; fallback — `UIScreen.main`.
    static var screenSize: CGSize {
        guard
            let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let window = scene.windows.first(where: \.isKeyWindow)
        else {
            return UIScreen.main.bounds.size
        }
        return window.bounds.size
    }

    private static func interpolatedMultiplier(
        dimension: CGFloat,
        compact: CGFloat,
        reference: CGFloat,
        large: CGFloat,
        compactMultiplier: CGFloat,
        largeMultiplier: CGFloat
    ) -> CGFloat {
        guard dimension > 0, reference > 0 else { return 1 }

        if dimension <= reference {
            let span = reference - compact
            guard span > 0 else { return compactMultiplier }
            let progress = min(max((dimension - compact) / span, 0), 1)
            return compactMultiplier + progress * (1 - compactMultiplier)
        }

        let span = large - reference
        guard span > 0 else { return largeMultiplier }
        let progress = min(max((dimension - reference) / span, 0), 1)
        return 1 + progress * (largeMultiplier - 1)
    }
}

// MARK: - Scale refresh (только в DS-модификаторах)
extension View {
    /// Пересчитывает scale при появлении view с модификатором и при смене ориентации.
    ///
    /// Не вызывай во views — используется внутри DS-модификаторов.
    func uxOnScaleChange(_ action: @escaping () -> Void) -> some View {
        onAppear(perform: action)
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action()
            }
    }
}
