//
//  HomeFeature+Navigation.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 01.07.2026.
//

import ComposableArchitecture
import Foundation

// MARK: - Constants
private enum PinLayoutCancelID {
    /// Ключ effect'а снятия удержания layout после открепления программы.
    ///
    /// - Parameter programID: идентификатор программы.
    ///
    /// - Returns: строковый id для `.cancellable`.
    static func release(_ programID: UUID) -> String {
        "pinLayoutRelease-\(programID.uuidString)"
    }
}

extension HomeFeature {
    // MARK: - Internal Methods
    /// Обрабатывает все `Action` главного экрана.
    ///
    /// - Parameters:
    ///   - state: текущее mutable-состояние reducer.
    ///   - action: входящее действие.
    ///
    /// - Returns: side effect для асинхронных действий или `.none`.
    func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        switch action {
        case .startTapped:
            print("START")
            return .none

        case let .programChipTapped(chipIndex, programID):
            selectProgram(&state, at: chipIndex, programID: programID)
            playPageChangeHaptic(&state)
            return .none

        case let .programPinToggled(program):
            return handleProgramPinToggled(&state, program: program)

        case let .pinLayoutReleased(programID):
            state.pinLayoutHeldIDs.remove(programID)
            return .none

        case .syncPageOrderToCanonical:
            syncPageOrderToCanonical(&state)
            return .none

        case let .applyImmediateScroll(page):
            state.scrollPosition = page
            state.selectedPage = page
            state.scrollIntent = nil
            return .none

        case .clearScrollIntent:
            state.scrollIntent = nil
            return .none

        case let .scrollPositionChanged(newPage):
            state.scrollPosition = newPage
            handleUserSwipe(&state, to: newPage)
            playPageChangeHapticIfNeeded(&state, newPage: newPage)
            if state.pageTransition == .idle,
               let newPage,
               state.pageOrder.indices.contains(newPage) {
                state.selectedPage = newPage
            }
            return .none

        case let .carouselScrollPhaseChanged(from, to):
            handleCarouselScrollPhaseChanged(&state, from: from, to: to)
            return .none

        case .carouselScrolledToIdle:
            return handleCarouselScrolledToIdle(&state)

        case let .progressAnimationCompleted(programID):
            state.animatedProgramIDs.insert(programID)
            return .none
        }
    }

    /// Инкрементирует триггер haptic при смене страницы.
    ///
    /// - Parameter state: mutable-состояние reducer.
    func playPageChangeHaptic(_ state: inout State) {
        state.pageChangeHapticTick &+= 1
    }

    /// Инкрементирует триггер haptic при закреплении / откреплении чипа.
    ///
    /// - Parameter state: mutable-состояние reducer.
    func playPinHaptic(_ state: inout State) {
        state.pinHapticTick &+= 1
    }

    /// Сыграть haptic смены страницы один раз за жест свайпа, если переход в idle.
    ///
    /// - Parameters:
    ///   - state: mutable-состояние reducer.
    ///   - newPage: новая позиция карусели или `nil`.
    func playPageChangeHapticIfNeeded(
        _ state: inout State,
        newPage: Int?
    ) {
        guard state.pageTransition == .idle,
              let newPage,
              !state.hasPlayedHapticForCurrentGesture else { return }

        let anchor = state.hapticAnchorPage ?? state.selectedPage
        guard newPage != anchor else { return }

        tryPlaySwipeHaptic(&state)
    }

    /// Обновляет фазу карусели и сбрасывает haptic-якорь при начале нового жеста.
    ///
    /// - Parameters:
    ///   - state: mutable-состояние reducer.
    ///   - oldPhase: предыдущая фаза скролла.
    ///   - newPhase: новая фаза скролла.
    func handleCarouselScrollPhaseChanged(
        _ state: inout State,
        from oldPhase: CarouselScrollPhase,
        to newPhase: CarouselScrollPhase
    ) {
        state.carouselScrollPhase = newPhase

        guard isStartingCarouselGesture(from: oldPhase, to: newPhase) else { return }

        state.hasPlayedHapticForCurrentGesture = false
        state.hapticAnchorPage = state.selectedPage
    }

    /// Сыграть haptic свайпа, если переход idle и haptic ещё не был за жест.
    ///
    /// - Parameter state: mutable-состояние reducer.
    func tryPlaySwipeHaptic(_ state: inout State) {
        guard state.pageTransition == .idle,
              !state.hasPlayedHapticForCurrentGesture else { return }
        state.hasPlayedHapticForCurrentGesture = true
        playPageChangeHaptic(&state)
    }
}

// MARK: - Private Methods
private extension HomeFeature {
    /// Закрепляет или открепляет программу, переставляет чипы и планирует снятие pin layout.
    ///
    /// - Parameters:
    ///   - state: mutable-состояние reducer.
    ///   - program: программа, для которой переключили pin long press.
    ///
    /// - Returns: effect с задержкой `pinReorderDuration` после открепления или `.none`.
    func handleProgramPinToggled(_ state: inout State, program: Program) -> Effect<Action> {
        let wasPinned = state.pinnedPrograms.contains(program.id)
        if wasPinned {
            state.pinnedPrograms.remove(program.id)
            state.pinLayoutHeldIDs.insert(program.id)
        } else {
            state.pinLayoutHeldIDs.remove(program.id)
            state.pinnedPrograms.insert(program.id)
        }
        sortProgramsWithPinnedFirst(&state)
        playPinHaptic(&state)
        guard wasPinned else { return .none }
        return .run { send in
            try await Task.sleep(for: HomeConstants.pinReorderDuration)
            await send(.pinLayoutReleased(program.id))
        }
        .cancellable(id: PinLayoutCancelID.release(program.id), cancelInFlight: true)
    }

    /// Фиксирует остановку карусели: обновляет `selectedPage` и завершает `pageTransition`.
    ///
    /// - Parameter state: mutable-состояние reducer.
    ///
    /// - Returns: `.none`.
    func handleCarouselScrolledToIdle(_ state: inout State) -> Effect<Action> {
        guard let page = state.scrollPosition,
              state.pageOrder.indices.contains(page) else { return .none }
        state.selectedPage = page
        state.hasPlayedHapticForCurrentGesture = false
        state.hapticAnchorPage = nil
        completePageTransitionIfNeeded(&state, at: page)
        return .none
    }

    /// Начался ли новый жест прокрутки карусели — для сброса haptic-якоря.
    ///
    /// - Parameters:
    ///   - oldPhase: предыдущая фаза скролла.
    ///   - newPhase: новая фаза скролла.
    ///
    /// - Returns: `true`, если жест только что стартовал.
    func isStartingCarouselGesture(
        from oldPhase: CarouselScrollPhase,
        to newPhase: CarouselScrollPhase
    ) -> Bool {
        (oldPhase == .idle && (newPhase == .interacting || newPhase == .tracking || newPhase == .decelerating))
            || (oldPhase == .decelerating && newPhase == .interacting)
            || (oldPhase == .tracking && newPhase == .interacting)
    }

    /// Переключает программу по тапу на чип: native swipe для соседей или jump для остальных.
    ///
    /// - Parameters:
    ///   - state: mutable-состояние reducer.
    ///   - chipIndex: индекс чипа в `programs`.
    ///   - programID: идентификатор выбранной программы.
    func selectProgram(
        _ state: inout State,
        at chipIndex: Int,
        programID: UUID
    ) {
        let currentChipIndex = state.selectedChipIndex
        guard chipIndex != currentChipIndex else { return }

        state.pageTransition = .selectingFromChip

        if shouldAnimatePageNatively(state, from: currentChipIndex, to: chipIndex) {
            selectAdjacentProgram(&state, programID: programID, chipIndex: chipIndex)
        } else {
            jumpToProgram(&state, targetID: programID, targetChipIndex: chipIndex)
        }
    }

    /// Обновляет `selectedProgramID` при пользовательском свайпе карусели.
    ///
    /// - Parameters:
    ///   - state: mutable-состояние reducer.
    ///   - newPage: новый индекс страницы в `pageOrder`.
    func handleUserSwipe(_ state: inout State, to newPage: Int?) {
        guard let newPage, state.pageOrder.indices.contains(newPage) else { return }
        guard state.pageTransition == .idle else { return }
        state.selectedProgramID = state.pageOrder[newPage]
        normalizePageOrderIfSwipeDesynced(&state)
    }

    /// Завершает сценарий `pageTransition`, когда карусель остановилась на `page`.
    ///
    /// - Parameters:
    ///   - state: mutable-состояние reducer.
    ///   - page: индекс остановившейся страницы.
    func completePageTransitionIfNeeded(_ state: inout State, at page: Int) {
        switch state.pageTransition {
        case .idle:
            break
        case .selectingFromChip:
            guard state.pageOrder[page] == state.selectedProgramID else { return }
            state.pageTransition = .idle
        case let .jumping(targetID, expectedPage):
            guard page == expectedPage else { return }
            syncPageOrderToCanonical(&state, keeping: targetID)
            state.pageTransition = .idle
        }
    }

    /// Переставляет `programs`: закреплённые первыми, остальные следом.
    ///
    /// - Parameter state: mutable-состояние reducer.
    func sortProgramsWithPinnedFirst(_ state: inout State) {
        state.programs = state.programs.filter { state.pinnedPrograms.contains($0.id) }
            + state.programs.filter { !state.pinnedPrograms.contains($0.id) }
    }

    /// Приводит `pageOrder` к каноническому и скроллит к `programID` без анимации.
    ///
    /// - Parameters:
    ///   - state: mutable-состояние reducer.
    ///   - programID: программа, которую нужно оставить выбранной; по умолчанию `selectedProgramID`.
    func syncPageOrderToCanonical(_ state: inout State, keeping programID: UUID? = nil) {
        let canonical = state.canonicalPageOrder
        guard state.pageOrder != canonical else { return }

        let targetID = programID ?? state.selectedProgramID
        let page = canonical.firstIndex(of: targetID) ?? state.selectedPage

        state.pageOrder = canonical
        state.selectedProgramID = targetID
        state.scrollIntent = .immediate(page)
    }

    /// Выбор соседней программы с нативной paging-анимацией карусели.
    ///
    /// - Parameters:
    ///   - state: mutable-состояние reducer.
    ///   - programID: идентификатор целевой программы.
    ///   - chipIndex: индекс чипа целевой программы.
    func selectAdjacentProgram(_ state: inout State, programID: UUID, chipIndex: Int) {
        state.selectedProgramID = programID
        let page = state.pageOrder.firstIndex(of: programID) ?? chipIndex
        if state.scrollPosition == page {
            state.pageTransition = .idle
            return
        }
        applyPageSelection(&state, page: page, animated: true)
    }

    /// Прыжок на не соседнюю программу через временную перестройку `pageOrder`.
    ///
    /// - Parameters:
    ///   - state: mutable-состояние reducer.
    ///   - targetID: идентификатор целевой программы.
    ///   - targetChipIndex: индекс её чипа в `programs`.
    func jumpToProgram(_ state: inout State, targetID: UUID, targetChipIndex: Int) {
        resetPageOrderIfDesynced(&state)

        guard let adjacentPageIndex = adjacentPageIndex(forTargetChipIndex: targetChipIndex, in: state) else {
            state.pageTransition = .idle
            return
        }

        state.pageTransition = .jumping(targetID: targetID, expectedPage: adjacentPageIndex)
        reorderPageOrder(&state, inserting: targetID, at: adjacentPageIndex)
        state.selectedProgramID = targetID
        applyPageSelection(&state, page: adjacentPageIndex, animated: true)
    }

    /// Устанавливает выбранную страницу карусели — анимированно или мгновенно.
    ///
    /// - Parameters:
    ///   - state: mutable-состояние reducer.
    ///   - page: индекс страницы в `pageOrder`.
    ///   - animated: `true` — через `scrollIntent`, `false` — прямое обновление позиции.
    func applyPageSelection(_ state: inout State, page: Int, animated: Bool) {
        guard state.pageOrder.indices.contains(page) else { return }

        if animated {
            state.scrollIntent = .animated(page)
        } else {
            state.scrollPosition = page
            state.selectedPage = page
        }
    }

    /// Сбрасывает `pageOrder` к каноническому, если он рассинхронизирован и swipe sync не сохранён.
    ///
    /// - Parameter state: mutable-состояние reducer.
    func resetPageOrderIfDesynced(_ state: inout State) {
        guard state.pageOrder != state.canonicalPageOrder,
              !isPageOrderSwipeSynced(state, for: state.selectedProgramID) else { return }
        state.pageOrder = state.canonicalPageOrder
    }

    /// Индекс соседней страницы карусели для jump к `targetChipIndex`.
    ///
    /// - Parameters:
    ///   - targetChipIndex: индекс целевого чипа.
    ///   - state: текущее состояние reducer.
    ///
    /// - Returns: индекс страницы на одну позицию вперёд или назад от текущей.
    func adjacentPageIndex(forTargetChipIndex targetChipIndex: Int, in state: State) -> Int? {
        let isForward = targetChipIndex > state.selectedChipIndex
        let pageIndex = isForward ? state.selectedPage + 1 : state.selectedPage - 1
        guard state.pageOrder.indices.contains(pageIndex) else { return nil }
        return pageIndex
    }

    /// Вставляет `targetID` в `pageOrder` на позицию `index`, удалив прежнее вхождение.
    ///
    /// - Parameters:
    ///   - state: mutable-состояние reducer.
    ///   - targetID: идентификатор перемещаемой программы.
    ///   - index: целевой индекс в `pageOrder`.
    func reorderPageOrder(_ state: inout State, inserting targetID: UUID, at index: Int) {
        var reordered = state.pageOrder
        reordered.removeAll { $0 == targetID }
        reordered.insert(targetID, at: index)
        state.pageOrder = reordered
    }

    /// Синхронизирует `pageOrder` после свайпа, если порядок временно отличался от канонического.
    ///
    /// - Parameter state: mutable-состояние reducer.
    func normalizePageOrderIfSwipeDesynced(_ state: inout State) {
        guard state.pageOrder != state.canonicalPageOrder,
              !isPageOrderSwipeSynced(state, for: state.selectedProgramID) else { return }
        syncPageOrderToCanonical(&state)
    }

    /// Можно ли перейти на соседний чип нативной paging-анимацией без jump.
    ///
    /// - Parameters:
    ///   - state: текущее состояние reducer.
    ///   - currentChipIndex: индекс текущего чипа.
    ///   - targetChipIndex: индекс целевого чипа.
    ///
    /// - Returns: `true`, если чипы соседние и `pageOrder` готов к native scroll.
    func shouldAnimatePageNatively(
        _ state: State,
        from currentChipIndex: Int,
        to targetChipIndex: Int
    ) -> Bool {
        let isAdjacent = abs(targetChipIndex - currentChipIndex) == 1
        let isPageOrderReady = state.pageOrder == state.canonicalPageOrder
            || isPageOrderSwipeSynced(state, for: state.selectedProgramID)
        return isAdjacent && isPageOrderReady
    }

    /// Проверяет, совпадают ли соседи программы в `pageOrder` и `canonicalPageOrder` после свайпа.
    ///
    /// - Parameters:
    ///   - state: текущее состояние reducer.
    ///   - programID: идентификатор программы на текущей странице.
    ///
    /// - Returns: `true`, если локальная перестройка `pageOrder` согласована с каноном.
    func isPageOrderSwipeSynced(_ state: State, for programID: UUID) -> Bool {
        let canonical = state.canonicalPageOrder
        guard state.pageOrder != canonical,
              let chipIndex = canonical.firstIndex(of: programID),
              let pageIndex = state.pageOrder.firstIndex(of: programID) else { return true }

        return neighborMatchesCanonical(
            pageOrder: state.pageOrder,
            canonical: canonical,
            chipIndex: chipIndex,
            pageIndex: pageIndex,
            offset: 1
        ) && neighborMatchesCanonical(
            pageOrder: state.pageOrder,
            canonical: canonical,
            chipIndex: chipIndex,
            pageIndex: pageIndex,
            offset: -1
        )
    }

    /// Сравнивает соседа программы в `pageOrder` с ожидаемым соседом из `canonical`.
    ///
    /// - Parameters:
    ///   - pageOrder: текущий порядок страниц карусели.
    ///   - canonical: канонический порядок по `programs`.
    ///   - chipIndex: индекс программы в `canonical`.
    ///   - pageIndex: индекс программы в `pageOrder`.
    ///   - offset: смещение соседа (+1 / −1).
    ///
    /// - Returns: `true`, если сосед совпадает или выходит за границы списка.
    func neighborMatchesCanonical(
        pageOrder: [UUID],
        canonical: [UUID],
        chipIndex: Int,
        pageIndex: Int,
        offset: Int
    ) -> Bool {
        let neighborChipIndex = chipIndex + offset
        guard canonical.indices.contains(neighborChipIndex) else { return true }

        let neighborPageIndex = pageIndex + offset
        let expectedNeighbor = canonical[neighborChipIndex]
        let actualNeighbor = pageOrder.indices.contains(neighborPageIndex)
            ? pageOrder[neighborPageIndex]
            : nil
        return actualNeighbor == expectedNeighbor
    }
}
