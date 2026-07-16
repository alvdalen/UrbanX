//
//  ProgramChipsSection.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 18.06.2026.
//

import SwiftUI
import ComposableArchitecture

/// Горизонтальный ряд чипов программ: tap, long press для pin, разделитель закреплённых.
struct ProgramChipsSection: View {
    // MARK: - Internal Properties
    /// Store главного экрана — программы, выбор, закрепление и порядок чипов.
    @Bindable var store: StoreOf<HomeFeature>

    // MARK: - Body
    var body: some View {
        chipsScrollView
    }


    // MARK: - Горизонтальный скролл чипов

    /// Горизонтальный скролл чипов с автопрокруткой к выбранной программе.
    private var chipsScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                programChipsRow
            }
            .onChange(of: store.selectedProgramID) { _, newValue in
                scrollToSelectedProgram(newValue, using: proxy)
            }
        }
    }

    // MARK: - Ряд чипов

    /// Ряд чипов с фиксированной высотой секции и боковыми отступами. Без UX scale.
    private var programChipsRow: some View {
        HStack(spacing: LocalConstants.blockSpacing) {
            ForEach(Array(store.programs.enumerated()), id: \.element.id) { index, program in
                programChip(at: index, program: program)
            }
        }
        .padding(.horizontal, LocalConstants.horizontalInset)
        .frame(height: LocalConstants.programsSectionHeight)
    }

    // MARK: - Чип программы

    /// Чип программы и опциональный разделитель после последнего закреплённого.
    ///
    /// - Parameters:
    ///   - index: индекс программы в `store.programs`.
    ///   - program: модель программы для чипа.
    @ViewBuilder
    private func programChip(at index: Int, program: Program) -> some View {
        programChipButton(at: index, program: program)

        if shouldShowDivider(after: index) {
            pinnedProgramsDivider
        }
    }

    /// Кнопка-чип: tap переключает программу, long press закрепляет или открепляет.
    ///
    /// - Parameters:
    ///   - index: индекс программы в `store.programs`.
    ///   - program: модель программы для чипа.
    private func programChipButton(
        at index: Int,
        program: Program
    ) -> some View {
        Button {
            handleProgramTap(at: index, program: program)
        } label: {
            programChipView(for: program)
        }
        .buttonStyle(.plain)
    }

    /// Визуальное представление чипа с long press для закрепления программы.
    ///
    /// - Parameter program: модель программы для отображения в чипе.
    ///
    /// - Returns: `ProgramChipView` с привязкой к `program.id` для `ScrollViewReader`.
    private func programChipView(for program: Program) -> some View {
        ProgramChipView(
            title: program.chip,
            isSelected: store.selectedProgramID == program.id,
            isPinned: store.pinnedPrograms.contains(program.id)
        )
        .id(program.id)
        .onLongPressGesture(
            minimumDuration: LocalConstants.pinLongPressDuration,
            maximumDistance: LocalConstants.pinLongPressMaximumDistance,
            perform: {
                handleProgramLongPress(program)
            }
        )
    }

    // MARK: - Разделитель закреплённых чипов

    /// Точка-разделитель между закреплёнными и обычными чипами.
    private var pinnedProgramsDivider: some View {
        Circle()
            .fill(UXColor.chipDotSeparator)
            .frame(
                width: LocalConstants.pinnedDividerDiameter,
                height: LocalConstants.pinnedDividerDiameter
            )
    }
}

// MARK: - Private Methods
private extension ProgramChipsSection {
    /// Обрабатывает tap по чипу программы.
    func handleProgramTap(
        at index: Int,
        program: Program
    ) {
        _ = store.send(
            .programChipTapped(
                chipIndex: index,
                programID: program.id
            )
        )
    }

    /// Обрабатывает long press по чипу: закрепление и синхронизация порядка страниц.
    func handleProgramLongPress(_ program: Program) {
        withAnimation(.snappy(duration: HomeConstants.pinAnimationDuration)) {
            _ = store.send(.programPinToggled(program))
        }

        withoutAnimation {
            _ = store.send(.syncPageOrderToCanonical)
        }
    }

    /// Показывать ли разделитель сразу после последнего закреплённого чипа.
    ///
    /// - Parameter index: индекс программы в `store.programs`.
    ///
    /// - Returns: `true`, если после этого чипа нужна точка-разделитель.
    func shouldShowDivider(after index: Int) -> Bool {
        guard !store.pinnedPrograms.isEmpty,
              store.pinnedPrograms.count < store.programs.count else { return false }
        let current = store.programs[index]
        return store.pinnedPrograms.contains(current.id) && index == store.pinnedPrograms.count - 1
    }

    /// Прокручивает горизонтальный ряд чипов к выбранной программе.
    ///
    /// - Parameters:
    ///   - programID: идентификатор программы, к которой нужно проскроллить.
    ///   - proxy: `ScrollViewProxy` горизонтального `ScrollView` чипов.
    func scrollToSelectedProgram(_ programID: UUID, using proxy: ScrollViewProxy) {
        withAnimation(.snappy) {
            proxy.scrollTo(programID, anchor: .center)
        }
    }

    /// Выполняет обновления без системной анимации SwiftUI.
    ///
    /// - Parameter updates: блок изменений состояния (например, синхронизация порядка страниц после pin).
    func withoutAnimation(_ updates: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction, updates)
    }
}

// MARK: - Constants
private extension ProgramChipsSection {
    enum LocalConstants {
        /// Отступ ряда чипов от левого и правого края экрана.
        static let horizontalInset: CGFloat = 20

        /// Между соседними чипами программ в горизонтальном ряду.
        static let blockSpacing: CGFloat = 12

        /// Вертикальный отступ внутри чипа программы — дублирует `ProgramChipView.verticalPadding`
        /// только для расчёта высоты секции чипов (`programsSectionHeight`).
        static let chipVerticalPadding: CGFloat = 12

        /// Высота видимой части чипа программы без тени — для расчёта `programsSectionHeight`.
        static let chipRowHeight: CGFloat = 40

        /// Диаметр серой точки-разделителя между закреплёнными и обычными чипами в ряду.
        static let pinnedDividerDiameter: CGFloat = 4

        /// Сколько секунд нужно удерживать палец на чипе, чтобы закрепить или открепить программу.
        static let pinLongPressDuration: TimeInterval = 0.28

        /// Высота секции с чипами: видимая высота чипа + верхний и нижний внутренний отступ.
        static var programsSectionHeight: CGFloat {
            chipRowHeight + chipVerticalPadding * 2
        }

        /// На сколько пикселей палец может сдвинуться при долгом нажатии, не отменяя закрепление.
        static var pinLongPressMaximumDistance: CGFloat {
            blockSpacing
        }
    }
}
