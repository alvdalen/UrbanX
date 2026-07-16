//
//  ProgressFillOutline.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 13.07.2026.
//

import SwiftUI

/// Обводка силуэта **только заполненной** части дорожки и кружков на ней.
///
/// Свечение — несколько контурных колец с плавным спадом: плотнее у обводки, мягче вдали.
struct ProgressFillOutline: View, Animatable {
    // MARK: - Internal Properties
    /// Текущая доля заполнения дорожки (0…1); анимируется через `animatableData`.
    var progress: CGFloat

    /// Номер текущего шага (1…`stepCount`) — влияет на пульсацию кругов в силуэте.
    let currentCircle: Int

    /// Толщина контурной обводки заполненной части.
    let lineWidth: CGFloat

    /// Высота серой полоски дорожки под кружками.
    let trackHeight: CGFloat

    /// Цвет контурной обводки.
    let color: Color

    /// Цвет контурного свечения вокруг заполненной части.
    let glowColor: Color

    /// Связка `progress` с протоколом `Animatable` для плавной анимации силуэта.
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    /// Горизонтальный запас overlay для выравнивания силуэта с дорожкой и кругами.
    ///
    /// - Parameter lineWidth: толщина контурной обводки.
    ///
    /// - Returns: отступ по X, равный половине диаметра круга плюс `lineWidth`.
    static func horizontalPadding(lineWidth: CGFloat) -> CGFloat {
        LocalConstants.circleSize / 2 + lineWidth
    }

    /// Полный запас overlay с учётом размытого свечения по краям.
    ///
    /// - Parameter lineWidth: толщина контурной обводки.
    ///
    /// - Returns: `horizontalPadding` плюс максимальный вынос слоёв `UXGlow.progressLayers`.
    static func overlayBleed(lineWidth: CGFloat) -> CGFloat {
        horizontalPadding(lineWidth: lineWidth) + UXGlow.maxExtent(for: UXGlow.progressLayers)
    }

    var body: some View {
        ZStack {
            glowLayers
            ringLayer
        }
        .compositingGroup()
        .allowsHitTesting(false)
    }


    // MARK: - Слои свечения

    /// Контурные кольца свечения с плавным спадом прозрачности.
    private var glowLayers: some View {
        ForEach(UXGlow.progressLayers.indices, id: \.self) { index in
            let layer = UXGlow.progressLayers[index]

            glowRing(
                spread: layer.spread,
                opacity: layer.opacity,
                blur: layer.blur
            )
        }
    }

    // MARK: - Контурная обводка

    /// Основной контур заполненной части дорожки и кругов через Canvas.
    private var ringLayer: some View {
        Canvas { context, size in
            guard progress > 0 else { return }

            let layout = layout(for: size)
            context.fill(layout.outerPath(inflate: lineWidth), with: .color(color))

            context.blendMode = .destinationOut
            context.fill(layout.innerPath, with: .color(.black))
        }
    }
}

private extension ProgressFillOutline {
    /// Одно размытое кольцо контурного свечения.
    ///
    /// - Parameters:
    ///   - spread: разброс кольца от контура в pt.
    ///   - opacity: прозрачность кольца.
    ///   - blur: радиус размытия кольца.
    func glowRing(spread: CGFloat, opacity: CGFloat, blur: CGFloat) -> some View {
        Canvas { context, size in
            guard progress > 0 else { return }

            let layout = layout(for: size)

            context.fill(
                layout.outerPath(inflate: spread),
                with: .color(glowColor.opacity(opacity))
            )

            context.blendMode = .destinationOut
            context.fill(layout.innerPath, with: .color(.black))
        }
        .blur(radius: blur)
    }

    /// Собирает геометрию силуэта заполненной части для текущего размера canvas.
    ///
    /// - Parameter size: размер области отрисовки overlay.
    ///
    /// - Returns: layout с путями дорожки и кругов.
    func layout(for size: CGSize) -> SilhouetteLayout {
        let layoutPad = Self.horizontalPadding(lineWidth: lineWidth)
        let edgePad = layoutPad + UXGlow.maxExtent(for: UXGlow.progressLayers)
        return SilhouetteLayout(
            trackWidth: size.width - edgePad * 2,
            horizontalPadding: edgePad,
            height: size.height,
            progress: progress,
            currentCircle: currentCircle,
            lineWidth: lineWidth,
            trackHeight: trackHeight
        )
    }
}

// MARK: - SilhouetteLayout
/// Геометрия силуэта заполненной части дорожки и кругов для Canvas-отрисовки.
private struct SilhouetteLayout {
    /// Ширина дорожки без боковых отступов overlay.
    let trackWidth: CGFloat

    /// Горизонтальный отступ силуэта от края canvas.
    let horizontalPadding: CGFloat

    /// Высота области отрисовки overlay.
    let height: CGFloat

    /// Текущая доля заполнения дорожки (0…1).
    let progress: CGFloat

    /// Номер текущего шага (1…`stepCount`).
    let currentCircle: Int

    /// Толщина контурной обводки.
    let lineWidth: CGFloat

    /// Высота серой полоски дорожки.
    let trackHeight: CGFloat

    /// Внешний контур силуэта с дополнительным разбросом `inflate`.
    ///
    /// - Parameter inflate: разброс контура от базового силуэта в pt.
    ///
    /// - Returns: объединённый путь дорожки и видимых кругов.
    func outerPath(inflate: CGFloat) -> Path {
        unionPath(inflate: inflate)
    }

    /// Внутренний контур для вырезания «дырки» в кольце свечения/обводки.
    var innerPath: Path {
        unionPath(inflate: 0)
    }

    /// Объединяет capsule-полоску и эллипсы кругов в один путь.
    ///
    /// - Parameter inflate: дополнительный разброс контура в pt.
    private func unionPath(inflate: CGFloat) -> Path {
        var path = Path()
        appendBar(to: &path, inflate: inflate)

        for index in 0..<ProgressFillOutline.LocalConstants.stepCount {
            let position = circlePosition(at: index)
            let diameter = circleDiameter(at: index, position: position)
            guard diameter > 0 else { continue }
            appendCircle(to: &path, at: position, diameter: diameter + inflate * 2)
        }

        return path
    }

    /// Добавляет горизонтальную capsule-полоску заполненной дорожки в путь.
    ///
    /// - Parameters:
    ///   - path: накапливаемый путь силуэта.
    ///   - inflate: дополнительный разброс контура полоски в pt.
    private func appendBar(to path: inout Path, inflate: CGFloat) {
        let fillWidth = trackWidth * progress + inflate * 2
        let barHeight = trackHeight + inflate * 2
        guard fillWidth > 0, barHeight > 0 else { return }

        let rect = CGRect(
            x: horizontalPadding - inflate,
            y: (height - barHeight) / 2,
            width: fillWidth,
            height: barHeight
        )
        path.addCapsule(in: rect)
    }

    /// Добавляет эллипс круга шага в путь силуэта.
    ///
    /// - Parameters:
    ///   - path: накапливаемый путь силуэта.
    ///   - position: доля длины дорожки (0…1), на которой стоит круг.
    ///   - diameter: диаметр круга в pt.
    private func appendCircle(to path: inout Path, at position: CGFloat, diameter: CGFloat) {
        let centerX = horizontalPadding + trackWidth * position
        let rect = CGRect(
            x: centerX - diameter / 2,
            y: height / 2 - diameter / 2,
            width: diameter,
            height: diameter
        )
        path.addEllipse(in: rect)
    }

    /// Доля длины дорожки (0…1), на которой стоит круг с индексом `index`.
    ///
    /// - Parameter index: индекс шага (0…`lastStepIndex`).
    ///
    /// - Returns: нормализованная позиция круга по X.
    private func circlePosition(at index: Int) -> CGFloat {
        CGFloat(index) / CGFloat(ProgressFillOutline.LocalConstants.lastStepIndex)
    }

    /// Диаметр круга с учётом заполнения и пульсации вокруг текущего шага.
    ///
    /// - Parameters:
    ///   - index: индекс шага (0…`lastStepIndex`).
    ///   - position: доля длины дорожки, на которой стоит круг.
    ///
    /// - Returns: диаметр в pt или `0`, если прогресс ещё не дошёл до круга.
    private func circleDiameter(at index: Int, position: CGFloat) -> CGFloat {
        guard progress >= position else { return 0 }

        let distance = abs(progress - position)
        let pulse = max(0, 1 - distance / ProgressFillOutline.LocalConstants.pulseWidth)
        let scale = index + 1 == currentCircle
            ? ProgressFillOutline.LocalConstants.activeCircleScale
            : ProgressFillOutline.LocalConstants.activeCircleScale
                + pulse * ProgressFillOutline.LocalConstants.pulseScaleBoost
        return ProgressFillOutline.LocalConstants.circleSize * scale
    }
}

// MARK: - Constants
fileprivate extension ProgressFillOutline {
    enum LocalConstants {
        /// Сколько кругов-шагов на дорожке (должно совпадать с `WorkoutProgressBar.stepCount`).
        static let stepCount = 6

        /// Диаметр одного круга шага на дорожке прогресса.
        static let circleSize: CGFloat = 20

        /// Ширина зоны пульсации вокруг текущего шага — доля длины дорожки от 0 до 1.
        static let pulseWidth: CGFloat = 0.06

        /// Насколько увеличиваются соседние круги при пульсации текущего шага (масштаб).
        static let pulseScaleBoost: CGFloat = 0.25

        /// Номер последнего шага на дорожке (шаги считаются с нуля).
        static var lastStepIndex: Int { stepCount - 1 }

        /// Базовый масштаб круга без пульсации соседей.
        static let activeCircleScale: CGFloat = 1
    }
}
