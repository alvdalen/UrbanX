//
//  ProgramPageView.swift
//  UrbanX
//
//  Created by Adam Mirzakanov on 01.07.2026.
//

import SwiftUI

/// Одна вертикальная страница внутри горизонтальной карусели программ:
/// карточка прогресса, promo-блок следующего уровня, две карточки статистики.
struct ProgramPageView: View {
    // MARK: - Internal Properties
    /// Данные программы для карточки прогресса и блока статистики на странице.
    let program: Program
    
    /// Выбрана ли в карусели страница программы с этими карточками.
    let isSelected: Bool
    
    /// Можно ли запускать анимацию.
    let canAnimate: Bool
    
    /// Проигрывалась ли анимация заполнения для этой страницы в текущем запуске приложения.
    let hasAnimatedBefore: Bool
    
    /// Вызывается по завершении анимации прогресса на карточке программы.
    let onProgressAnimationCompleted: () -> Void
    
    // MARK: - Body
    var body: some View {
        pageContent
    }
    

    // MARK: - Корневая компоновка страницы

    /// Вертикальная компоновка страницы программы с боковыми отступами.
    private var pageContent: some View {
        pageSections
            .padding(.top, LocalConstants.topPadding)
            .padding(.horizontal, LocalConstants.horizontalInset)
    }

    /// Вертикальный стек секций прогресса и статистики на странице программы.
    private var pageSections: some View {
        VStack(alignment: .center, spacing: LocalConstants.sectionsSpacing) {
            progressSection
            statisticsSection
        }
    }

    // MARK: - Секция прогресса

    /// Карточка прогресса и promo-блок следующего уровня.
    private var progressSection: some View {
        VStack(spacing: LocalConstants.sectionSpacing) {
            progressCard
            nextLevelSection
                .padding(.horizontal, LocalConstants.nextLevelHorizontalPadding)
        }
    }

    // MARK: - Секция статистики

    /// Заголовок «Статистика» и пара карточек под ним.
    private var statisticsSection: some View {
        VStack(spacing: LocalConstants.sectionSpacing) {
            statsSectionHeader
            statsSection
        }
    }

    // MARK: - Заголовок блока статистики

    /// Горизонтальные черты и заголовок секции статистики.
    private var statsSectionHeader: some View {
        HStack(spacing: LocalConstants.statsHeaderSpacing) {
            leadingDivider
            statsSectionTitle
            trailingDivider
        }
    }
    
    /// Локализованный заголовок секции статистики между чертами.
    private var statsSectionTitle: some View {
        Text(Strings.Stats.Section.title)
            .uxFont(.statistic, large: LocalConstants.fontLargeScale)
            .foregroundStyle(UXColor.statisticTextColor)
    }
    
    /// Горизонтальная черта слева от заголовка «Статистика».
    private var leadingDivider: some View {
        VStack {
            Divider()
                .padding(.leading, LocalConstants.dividerHorizontalPadding)
        }
    }

    /// Горизонтальная черта справа от заголовка «Статистика».
    private var trailingDivider: some View {
        VStack {
            Divider()
                .padding(.trailing, LocalConstants.dividerHorizontalPadding)
        }
    }
    
    /// Верхняя карточка с названием программы, дорожкой прогресса и кнопкой «Старт».
    private var progressCard: some View {
        ProgressCardView(
            title: program.cardTitle,
            currentStep: program.currentStep,
            programID: program.id,
            isSelected: isSelected,
            hasAnimatedBefore: hasAnimatedBefore,
            canAnimate: canAnimate,
            onAnimationPlayed: onProgressAnimationCompleted
        )
    }
    
    /// Promo-полоска «До следующего уровня» под блоком прогресса.
    private var nextLevelSection: some View {
        NextLevelView()
    }
    
    /// Пара карточек «Личный рекорд» и «Прогресс июня».
    private var statsSection: some View {
        StatsView(
            isSelected: isSelected,
            progress: program.progress,
            programID: program.id,
            percentText: program.percentText,
            hasAnimatedBefore: hasAnimatedBefore,
            canAnimate: canAnimate
        )
        .padding(.bottom, LocalConstants.bottomPadding)
    }
}

// MARK: - Constants
private extension ProgramPageView {
    enum LocalConstants {
        /// Отступ всего содержимого страницы от верхнего края карусели.
        static let topPadding: CGFloat = 10
        
        /// Отступ всего содержимого страницы от ниженго края карусели.
        static let bottomPadding: CGFloat = 50

        /// Отступ всего содержимого страницы от левого и правого края карусели карточек.
        static let horizontalInset: CGFloat = 20

        /// Между блоком прогресса и блоком статистики на странице программы.
        static let sectionsSpacing: CGFloat = 35

        /// Между карточкой прогресса и заголовком статистики внутри своих секций.
        static let sectionSpacing: CGFloat = 22

        /// Дополнительный горизонтальный отступ полоски «До следующего уровня».
        static let nextLevelHorizontalPadding: CGFloat = 16

        /// Между чертами и заголовком секции статистики в шапке блока.
        static let statsHeaderSpacing: CGFloat = 12

        /// Горизонтальный отступ горизонтальных черт от края заголовка секции статистики.
        static let dividerHorizontalPadding: CGFloat = 20

        /// Множитель размера шрифта заголовка секции статистики на больших экранах (`uxFont`).
        static let fontLargeScale: CGFloat = 1.1
    }
}
