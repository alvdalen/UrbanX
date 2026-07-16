// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Strings {
  internal enum Home {
    internal enum Navigation {
      /// Заголовок навигации на главном экране
      internal static let title = Strings.tr("Localizable", "home.navigation.title", fallback: "Good morning")
    }
    internal enum Start {
      /// Текст кнопки «Старт» в карточке программы
      internal static let button = Strings.tr("Localizable", "home.start.button", fallback: "START")
    }
  }
  internal enum NextLevel {
    /// Название ранга в promo-блоке (мелкая бронзовая подпись)
    internal static let rank = Strings.tr("Localizable", "nextLevel.rank", fallback: "GERKULES")
    /// Схема повторений под заголовком (превью)
    internal static let subtitle = Strings.tr("Localizable", "nextLevel.subtitle", fallback: "Reps: 3 - 5 - 7 - 9 - 6")
    /// Основная строка о количестве тренировок до следующего уровня
    internal static let title = Strings.tr("Localizable", "nextLevel.title", fallback: "Three workouts until the next level")
  }
  internal enum Preview {
    internal enum Program {
      internal enum Abs {
        /// Короткое название программы «Пресс» для чипа
        internal static let chip = Strings.tr("Localizable", "preview.program.abs.chip", fallback: "Core")
        /// Полное название программы «Пресс» для карточки
        internal static let title = Strings.tr("Localizable", "preview.program.abs.title", fallback: "Core")
      }
      internal enum Dips {
        /// Короткое название программы «Брусья» для чипа
        internal static let chip = Strings.tr("Localizable", "preview.program.dips.chip", fallback: "Dips")
        /// Полное название программы «Отжимания на брусьях» для карточки
        internal static let title = Strings.tr("Localizable", "preview.program.dips.title", fallback: "Dips")
      }
      internal enum Plank {
        /// Короткое название программы «Планка» для чипа
        internal static let chip = Strings.tr("Localizable", "preview.program.plank.chip", fallback: "Plank")
        /// Полное название программы «Планка» для карточки
        internal static let title = Strings.tr("Localizable", "preview.program.plank.title", fallback: "Plank")
      }
      internal enum Pullups {
        /// Короткое название программы «Турник» для чипа
        internal static let chip = Strings.tr("Localizable", "preview.program.pullups.chip", fallback: "Pullups")
        /// Полное название программы «Подтягивания на турнике» для карточки
        internal static let title = Strings.tr("Localizable", "preview.program.pullups.title", fallback: "Pullups")
      }
      internal enum Pushups {
        /// Короткое название программы «Отжимания» для чипа
        internal static let chip = Strings.tr("Localizable", "preview.program.pushups.chip", fallback: "Pushups")
        /// Полное название программы «Отжимания от пола» для карточки
        internal static let title = Strings.tr("Localizable", "preview.program.pushups.title", fallback: "Pushups")
      }
      internal enum Squats {
        /// Короткое название программы «Приседания» для чипа
        internal static let chip = Strings.tr("Localizable", "preview.program.squats.chip", fallback: "Squats")
        /// Полное название программы «Приседания» для карточки
        internal static let title = Strings.tr("Localizable", "preview.program.squats.title", fallback: "Squats")
      }
    }
  }
  internal enum Stats {
    internal enum MonthProgress {
      /// Подпись секции «Прогресс месяца» в правой карточке
      internal static let eyebrow = Strings.tr("Localizable", "stats.monthProgress.eyebrow", fallback: "June progress")
      /// Счётчик тренировок: %1$d — выполнено, %2$d — цель
      internal static func workouts(_ p1: Int, _ p2: Int) -> String {
        return Strings.tr("Localizable", "stats.monthProgress.workouts", p1, p2, fallback: "%1$d of %2$d workouts")
      }
    }
    internal enum PersonalRecord {
      /// Подпись «Лучший результат» в левой карточке
      internal static let bestResult = Strings.tr("Localizable", "stats.personalRecord.bestResult", fallback: "Best result")
      /// Название упражнения в левой карточке
      internal static let exercise = Strings.tr("Localizable", "stats.personalRecord.exercise", fallback: "Pullups")
      /// Подпись секции «Личный рекорд» в левой карточке
      internal static let eyebrow = Strings.tr("Localizable", "stats.personalRecord.eyebrow", fallback: "Personal record")
    }
    internal enum Section {
      /// Заголовок секции статистики между горизонтальными чертами
      internal static let title = Strings.tr("Localizable", "stats.section.title", fallback: "Statistics")
    }
  }
  internal enum Tab {
    /// Название вкладки «Главная»
    internal static let home = Strings.tr("Localizable", "tab.home", fallback: "Home")
    /// Название вкладки «Карта»
    internal static let map = Strings.tr("Localizable", "tab.map", fallback: "Map")
    /// Название вкладки «Профиль»
    internal static let profile = Strings.tr("Localizable", "tab.profile", fallback: "Profile")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Strings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
