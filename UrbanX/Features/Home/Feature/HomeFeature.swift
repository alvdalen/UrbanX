//
//  HomeFeature.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 18.06.2026.
//

import ComposableArchitecture
import Foundation

/// Состояние и логика главного экрана: программы, карусель, закрепление чипов.
@Reducer
struct HomeFeature {
    // MARK: - Body
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            reduce(into: &state, action: action)
        }
    }
}

// MARK: - State
extension HomeFeature {
    /// Тип активного перехода между страницами карусели.
    enum PageTransition: Equatable {
        /// Нет программного перехода — пользователь может свайпать и запускать анимации прогресса.
        case idle

        /// Переход начат тапом по чипу программы.
        case selectingFromChip

        /// Прыжок на не соседнюю программу: карусель сначала едет на соседнюю страницу, затем перестраивает `pageOrder`.
        ///
        /// - Parameters:
        ///   - targetID: идентификатор целевой программы.
        ///   - expectedPage: индекс промежуточной страницы, на которой карусель должна остановиться.
        case jumping(targetID: UUID, expectedPage: Int)
    }

    /// Программный скролл карусели к странице `Int`.
    enum ScrollIntent: Equatable {
        /// Плавный скролл с анимацией.
        ///
        /// - Parameter page: индекс целевой страницы в `pageOrder`.
        case animated(Int)

        /// Мгновенная установка позиции без анимации.
        ///
        /// - Parameter page: индекс целевой страницы в `pageOrder`.
        case immediate(Int)
    }

    /// Фаза горизонтального скролла карусели — зеркало `ScrollPhase` для reducer.
    enum CarouselScrollPhase: Equatable {
        /// Карусель неподвижна.
        case idle

        /// Палец на экране, скролл ещё не начался.
        case tracking

        /// Активный жест прокрутки.
        case interacting

        /// Инерционное замедление после отпускания.
        case decelerating

        /// Программная анимация `scrollPosition`.
        case animating
    }

    @ObservableState
    struct State: Equatable {
        /// Список программ на главном экране; закреплённые идут первыми.
        var programs: [Program]

        /// Идентификатор выбранной программы — синхронизирует чип и карусель.
        var selectedProgramID: UUID

        /// Индекс текущей страницы в `pageOrder`.
        var selectedPage: Int

        /// Текущая позиция paging-карусели; `nil` до первого layout.
        var scrollPosition: Int?

        /// Порядок страниц в карусели; может временно отличаться от `canonicalPageOrder` при jump.
        var pageOrder: [UUID]

        /// Идентификаторы закреплённых программ.
        var pinnedPrograms: Set<UUID>

        /// Активный сценарий перехода между страницами.
        var pageTransition: PageTransition

        /// Ожидающий intent программного скролла карусели.
        var scrollIntent: ScrollIntent?

        /// Программы, для которых анимация прогресса уже проиграна в текущем запуске.
        var animatedProgramIDs: Set<UUID>

        /// Текущая фаза скролла карусели.
        var carouselScrollPhase: CarouselScrollPhase

        /// Haptic смены страницы уже сыграл за текущий жест свайпа.
        var hasPlayedHapticForCurrentGesture: Bool

        /// Страница-якорь для haptic при свайпе; сбрасывается в `.carouselScrolledToIdle`.
        var hapticAnchorPage: Int?

        /// Счётчик триггера haptic при смене страницы.
        var pageChangeHapticTick: Int

        /// Счётчик триггера haptic при закреплении / откреплении чипа.
        var pinHapticTick: Int

        /// После открепления чип ещё держит ширину под иконку закрепления, пока доезжает на новое место.
        var pinLayoutHeldIDs: Set<UUID>

        /// Создаёт начальное состояние с первой программой выбранной по умолчанию.
        ///
        /// - Parameter programs: список программ главного экрана.
        init(programs: [Program]) {
            self.programs = programs
            selectedProgramID = programs[0].id
            selectedPage = .zero
            scrollPosition = .zero
            pageOrder = programs.map(\.id)
            pinnedPrograms = []
            pageTransition = .idle
            scrollIntent = nil
            animatedProgramIDs = []
            carouselScrollPhase = .idle
            hasPlayedHapticForCurrentGesture = false
            hapticAnchorPage = nil
            pageChangeHapticTick = 0
            pinHapticTick = 0
            pinLayoutHeldIDs = []
        }

        /// Показывать ли иконку pin у чипа — закреплён сейчас или удерживается layout после открепления.
        ///
        /// - Parameter programID: идентификатор программы.
        ///
        /// - Returns: `true`, если у чипа должна отображаться иконка закрепления.
        func showsPin(for programID: UUID) -> Bool {
            pinnedPrograms.contains(programID) || pinLayoutHeldIDs.contains(programID)
        }

        /// Проигрывалась ли анимация прогресса для программы в текущем запуске.
        ///
        /// - Parameter programID: идентификатор программы.
        ///
        /// - Returns: `true`, если анимация уже была.
        func hasAnimatedProgress(for programID: UUID) -> Bool {
            animatedProgramIDs.contains(programID)
        }

        /// Можно ли запускать анимацию прогресса на странице программы.
        var canAnimateProgress: Bool {
            pageTransition == .idle
        }

        /// Канонический порядок страниц по `programs`.
        var canonicalPageOrder: [UUID] {
            programs.map(\.id)
        }

        /// Индекс выбранной программы в `programs` — для `WormPageIndicator`.
        var selectedChipIndex: Int {
            programs.firstIndex(where: { $0.id == selectedProgramID }) ?? .zero
        }

        /// Находит программу по идентификатору.
        ///
        /// - Parameter id: идентификатор программы.
        ///
        /// - Returns: модель программы или `nil`.
        func program(for id: UUID) -> Program? {
            programs.first(where: { $0.id == id })
        }

        /// Показывать ли разделитель после последнего закреплённого чипа.
        ///
        /// - Parameter index: индекс программы в `programs`.
        ///
        /// - Returns: `true`, если после чипа нужна точка-разделитель.
        func shouldShowDivider(after index: Int) -> Bool {
            guard !pinnedPrograms.isEmpty, pinnedPrograms.count < programs.count else { return false }
            let current = programs[index]
            return pinnedPrograms.contains(current.id) && index == pinnedPrograms.count - 1
        }
    }
}

// MARK: - Action
extension HomeFeature {
    /// События главного экрана.
    enum Action: Equatable {
        /// Нажата кнопка «Старт» в карточке программы.
        case startTapped

        /// Тап по чипу программы.
        ///
        /// - Parameters:
        ///   - chipIndex: индекс чипа в `programs`.
        ///   - programID: идентификатор выбранной программы.
        case programChipTapped(chipIndex: Int, programID: UUID)

        /// Long press по чипу — закрепить или открепить программу.
        ///
        /// - Parameter program: программа, для которой переключили pin.
        case programPinToggled(Program)

        /// Синхронизировать `pageOrder` с каноническим порядком после pin без анимации layout.
        case syncPageOrderToCanonical

        /// Мгновенно установить позицию карусели без анимации.
        ///
        /// - Parameter page: индекс страницы в `pageOrder`.
        case applyImmediateScroll(Int)

        /// Сбросить `scrollIntent` после выполнения анимированного скролла.
        case clearScrollIntent

        /// Изменилась позиция paging-карусели (свайп или programmatic scroll).
        ///
        /// - Parameter newPage: новый индекс страницы или `nil` до первого layout.
        case scrollPositionChanged(Int?)

        /// Изменилась фаза скролла карусели.
        ///
        /// - Parameters:
        ///   - from: предыдущая фаза скролла.
        ///   - to: новая фаза скролла.
        case carouselScrollPhaseChanged(from: CarouselScrollPhase, to: CarouselScrollPhase)

        /// Карусель остановилась после жеста или анимации.
        case carouselScrolledToIdle

        /// Анимация прогресса на странице программы завершилась.
        ///
        /// - Parameter programID: идентификатор программы, чья анимация завершилась.
        case progressAnimationCompleted(UUID)

        /// Истёк таймер удержания layout pin после открепления программы.
        ///
        /// - Parameter programID: идентификатор программы, для которой сняли удержание layout.
        case pinLayoutReleased(UUID)
    }
}
