//
//  StarFieldBackground.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 12.07.2026.
//

import SwiftUI

/// Анимированное звёздное небо с градиентом и мягким свечением для тёмной темы главного экрана.
struct StarFieldBackground: View {
    /// Предгенерированный набор звёзд с фиксированным seed для стабильного расположения.
    private let stars = StarGenerator.generate(count: LocalConstants.starCount)

    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            background(in: geo)
        }
        .ignoresSafeArea()
    }


    // MARK: - Корневая компоновка фона

    /// Собирает слои звёздного фона по размеру контейнера `GeometryReader`.
    ///
    /// - Parameter geo: геометрия контейнера фона.
    ///
    /// - Returns: корневой `ZStack` с градиентом, свечением и звёздами.
    private func background(in geo: GeometryProxy) -> some View {
        backgroundContent(
            width: geo.size.width,
            height: geo.size.height * LocalConstants.contentHeightRatio
        )
    }

    /// Чёрный фон, слои звёздного неба и обрезка по заданным размерам.
    ///
    /// - Parameters:
    ///   - width: ширина области отрисовки в pt.
    ///   - height: высота области отрисовки в pt.
    ///
    /// - Returns: вертикально выровненный стек слоёв фона.
    private func backgroundContent(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        ZStack(alignment: .top) {
            Color.black

            backgroundLayers
                .frame(width: width, height: height)
                .clipped()
        }
    }

    // MARK: - Слои фона

    /// Вертикальный градиент неба, свечение, поле звёзд и нижнее затемнение.
    private var backgroundLayers: some View {
        ZStack {
            backgroundGradient
            glowBackground
            starField
            fadeGradient
        }
    }

    // MARK: - Градиент неба

    /// Вертикальный градиент от тёмно-зелёного к чёрному в верхней части фона.
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                LocalConstants.gradientTop,
                LocalConstants.gradientMiddle,
                .black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Мягкое свечение

    /// Размытый круг мягкого зеленоватого свечения под звёздами.
    private var glowBackground: some View {
        Circle()
            .fill(LocalConstants.glowColor.opacity(LocalConstants.glowOpacity))
            .frame(
                width: LocalConstants.glowDiameter,
                height: LocalConstants.glowDiameter
            )
            .blur(radius: LocalConstants.glowBlurRadius)
            .offset(y: LocalConstants.glowOffsetY)
    }

    // MARK: - Поле звёзд

    /// Canvas со звёздами; `TimelineView` обновляет прозрачность хаотично по времени.
    private var starField: some View {
        TimelineView(.animation(minimumInterval: LocalConstants.twinkleFrameInterval)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                for star in stars {
                    let point = CGPoint(
                        x: star.x * size.width,
                        y: star.y * size.height
                    )

                    let rect = CGRect(
                        x: point.x - star.size / 2,
                        y: point.y - star.size / 2,
                        width: star.size,
                        height: star.size
                    )

                    context.opacity = twinkleOpacity(for: star, at: time)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(.white)
                    )
                }
            }
        }
    }

    /// Прозрачность звезды в момент `time` — сумма двух синусов с разными частотами.
    private func twinkleOpacity(for star: Star, at time: TimeInterval) -> Double {
        let primary = sin(time * star.twinkleSpeed + star.twinklePhase)
        let secondary = sin(time * star.twinkleSpeed * LocalConstants.twinkleSecondaryRatio
            + star.twinklePhase * LocalConstants.twinkleSecondaryPhaseRatio)
        let wave = 0.5 + 0.5 * (primary * LocalConstants.twinklePrimaryWeight
            + secondary * LocalConstants.twinkleSecondaryWeight)
        let shapedWave = pow(wave, LocalConstants.twinkleContrastExponent)

        let dimFactor = 1 - star.twinkleDepth
        let brightFactor = 1 + star.twinkleDepth * LocalConstants.twinkleBrightenRatio
        let factor = dimFactor + (brightFactor - dimFactor) * shapedWave
        return min(max(star.opacity * factor, 0), 1)
    }

    // MARK: - Нижнее затемнение

    /// Нижний градиент к чёрному — плавный переход к контенту экрана.
    private var fadeGradient: some View {
        LinearGradient(
            colors: [
                .clear,
                .clear,
                .black.opacity(LocalConstants.fadeMidOpacity),
                .black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private enum StarGenerator {
        /// Генерирует фиксированное количество звёзд с детерминированным расположением.
        ///
        /// - Parameter count: количество звёзд на фоне.
        ///
        /// - Returns: массив звёзд с нормализованными координатами и параметрами отрисовки.
        static func generate(count: Int) -> [Star] {
            var rng = SeededGenerator(seed: LocalConstants.randomSeed)

            return (0..<count).map { _ in
                makeStar(using: &rng)
            }
        }

        /// Создаёт одну звезду со случайными параметрами из заданного генератора.
        ///
        /// - Parameter rng: детерминированный генератор случайных чисел.
        ///
        /// - Returns: модель звезды с нормализованными координатами.
        private static func makeStar(
            using rng: inout SeededGenerator
        ) -> Star {
            Star(
                x: CGFloat.random(in: 0...1, using: &rng),
                y: randomY(using: &rng),
                size: randomSize(using: &rng),
                opacity: randomOpacity(using: &rng),
                twinklePhase: Double.random(
                    in: LocalConstants.twinklePhaseRange,
                    using: &rng
                ),
                twinkleSpeed: Double.random(
                    in: LocalConstants.twinkleSpeedRange,
                    using: &rng
                ),
                twinkleDepth: Double.random(
                    in: LocalConstants.twinkleDepthRange,
                    using: &rng
                )
            )
        }

        /// Случайная вертикальная позиция звезды с перекосом к верхней трети экрана.
        ///
        /// - Parameter rng: детерминированный генератор случайных чисел.
        ///
        /// - Returns: нормализованная координата Y от 0 до 1.
        private static func randomY(
            using rng: inout SeededGenerator
        ) -> CGFloat {
            switch CGFloat.random(in: 0...1, using: &rng) {
            case ..<LocalConstants.topStarBandUpperBound:
                return CGFloat.random(
                    in: LocalConstants.topStarYRange,
                    using: &rng
                )
            case ..<LocalConstants.middleStarBandUpperBound:
                return CGFloat.random(
                    in: LocalConstants.middleStarYRange,
                    using: &rng
                )
            default:
                return CGFloat.random(
                    in: LocalConstants.lowerStarYRange,
                    using: &rng
                )
            }
        }

        /// Случайный диаметр звезды: преимущественно мелкие, реже крупные.
        ///
        /// - Parameter rng: детерминированный генератор случайных чисел.
        ///
        /// - Returns: диаметр звезды в pt.
        private static func randomSize(
            using rng: inout SeededGenerator
        ) -> CGFloat {
            switch CGFloat.random(in: 0...1, using: &rng) {
            case ..<LocalConstants.smallStarSizeUpperBound:
                return CGFloat.random(
                    in: LocalConstants.smallStarSizeRange,
                    using: &rng
                )
            case ..<LocalConstants.mediumStarSizeUpperBound:
                return CGFloat.random(
                    in: LocalConstants.mediumStarSizeRange,
                    using: &rng
                )
            default:
                return CGFloat.random(
                    in: LocalConstants.largeStarSizeRange,
                    using: &rng
                )
            }
        }

        /// Случайная прозрачность звезды: преимущественно тусклые, реже яркие.
        ///
        /// - Parameter rng: детерминированный генератор случайных чисел.
        ///
        /// - Returns: прозрачность звезды от 0 до 1.
        private static func randomOpacity(
            using rng: inout SeededGenerator
        ) -> Double {
            switch Double.random(in: 0...1, using: &rng) {
            case ..<LocalConstants.dimStarOpacityUpperBound:
                return Double.random(
                    in: LocalConstants.dimStarOpacityRange,
                    using: &rng
                )
            case ..<LocalConstants.midStarOpacityUpperBound:
                return Double.random(
                    in: LocalConstants.midStarOpacityRange,
                    using: &rng
                )
            default:
                return Double.random(
                    in: LocalConstants.brightStarOpacityRange,
                    using: &rng
                )
            }
        }
    }
}

// MARK: - Constants
private extension StarFieldBackground {
    enum LocalConstants {
        /// Количество звёзд на фоне главного экрана.
        static let starCount = 450

        /// Доля высоты экрана, занимаемая слоями звёздного фона.
        static let contentHeightRatio: CGFloat = 0.9

        /// Seed генератора для стабильного расположения звёзд между запусками.
        static let randomSeed: UInt64 = 42

        /// Верхний цвет вертикального градиента фона.
        static let gradientTop = Color(red: 9 / 255, green: 26 / 255, blue: 22 / 255)

        /// Средний цвет вертикального градиента фона.
        static let gradientMiddle = Color(red: 4 / 255, green: 4 / 255, blue: 4 / 255)

        /// Цвет мягкого свечения под звёздами.
        static let glowColor = Color(red: 18 / 255, green: 60 / 255, blue: 48 / 255)

        /// Прозрачность мягкого свечения под звёздами.
        static let glowOpacity: Double = 0.18

        /// Диаметр размытого круга свечения под звёздами.
        static let glowDiameter: CGFloat = 520

        /// Радиус размытия круга свечения.
        static let glowBlurRadius: CGFloat = 140

        /// Вертикальный сдвиг круга свечения относительно верхнего края.
        static let glowOffsetY: CGFloat = -230

        /// Прозрачность средней точки нижнего затемняющего градиента.
        static let fadeMidOpacity: Double = 0.4

        /// Верхняя граница доли звёзд в верхней трети экрана.
        static let topStarBandUpperBound: CGFloat = 0.45

        /// Верхняя граница доли звёзд в средней зоне экрана.
        static let middleStarBandUpperBound: CGFloat = 0.80

        /// Диапазон Y для звёзд в верхней зоне.
        static let topStarYRange: ClosedRange<CGFloat> = 0...0.30

        /// Диапазон Y для звёзд в средней зоне.
        static let middleStarYRange: ClosedRange<CGFloat> = 0.30...0.60

        /// Диапазон Y для звёзд в нижней зоне.
        static let lowerStarYRange: ClosedRange<CGFloat> = 0.60...0.80

        /// Верхняя граница доли мелких звёзд.
        static let smallStarSizeUpperBound: CGFloat = 0.72

        /// Верхняя граница доли звёзд среднего размера.
        static let mediumStarSizeUpperBound: CGFloat = 0.94

        /// Диапазон размера мелких звёзд.
        static let smallStarSizeRange: ClosedRange<CGFloat> = 0.8...1.2

        /// Диапазон размера звёзд среднего размера.
        static let mediumStarSizeRange: ClosedRange<CGFloat> = 1.2...1.9

        /// Диапазон размера крупных звёзд.
        static let largeStarSizeRange: ClosedRange<CGFloat> = 2.0...2.8

        /// Верхняя граница доли тусклых звёзд.
        static let dimStarOpacityUpperBound: Double = 0.60

        /// Верхняя граница доли звёзд со средней яркостью.
        static let midStarOpacityUpperBound: Double = 0.90

        /// Диапазон прозрачности тусклых звёзд.
        static let dimStarOpacityRange: ClosedRange<Double> = 0.18...0.40

        /// Диапазон прозрачности звёзд со средней яркостью.
        static let midStarOpacityRange: ClosedRange<Double> = 0.45...0.75

        /// Диапазон прозрачности ярких звёзд.
        static let brightStarOpacityRange: ClosedRange<Double> = 0.80...1.0

        /// Интервал кадров мерцания (~30 fps) — достаточно плавно и легче для батареи.
        static let twinkleFrameInterval: TimeInterval = 1.0 / 30.0

        /// Фазовый сдвиг мерцания (радианы).
        static let twinklePhaseRange: ClosedRange<Double> = 0...(2 * .pi)

        /// Скорость основной волны мерцания (рад/с).
        static let twinkleSpeedRange: ClosedRange<Double> = 2.0...7.5

        /// Насколько сильно звезда тускнеет и вспыхивает при мерцании.
        static let twinkleDepthRange: ClosedRange<Double> = 0.65...0.95

        /// Насколько ярче базовой opacity звезда светится на пике мерцания.
        static let twinkleBrightenRatio: Double = 0.55

        /// < 1 — дольше держится в тусклой фазе, контраст заметнее.
        static let twinkleContrastExponent: Double = 0.55

        /// Отношение частоты второй волны к первой — для нерегулярного блеска.
        static let twinkleSecondaryRatio: Double = 1.73

        /// Смещение фазы второй волны относительно первой.
        static let twinkleSecondaryPhaseRatio: Double = 1.31

        /// Вес основной синусоиды в сумме волн мерцания.
        static let twinklePrimaryWeight: Double = 0.7

        /// Вес второй синусоиды в сумме волн мерцания.
        static let twinkleSecondaryWeight: Double = 0.3
    }
}
