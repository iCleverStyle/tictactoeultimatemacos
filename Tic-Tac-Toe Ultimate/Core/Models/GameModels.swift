import Foundation

// Отметка игрока (крестик или нолик)
enum PlayerMark: String, CaseIterable {
    case x = "X"
    case o = "O"
    
    var opposite: PlayerMark {
        self == .x ? .o : .x
    }
}

// Уровень сложности бота
enum BotDifficulty {
    case easy    // Случайные ходы
    case hard    // Алгоритм minimax
    
    var description: String {
        switch self {
        case .easy: return "Лёгкий"
        case .hard: return "Сложный"
        }
    }
}

// Режим игры
enum GameMode {
    case singlePlayer // Против бота
    case twoPlayers   // Двое игроков
}

// Способ определения первого хода
enum FirstMoveSelection {
    case direct     // Прямой выбор игрока
    case random     // Случайный выбор
}

// Состояние ячейки
enum CellState: Equatable {
    case empty
    case marked(PlayerMark)
    
    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }
    
    var mark: PlayerMark? {
        if case .marked(let mark) = self { return mark }
        return nil
    }
}

// Состояние мини-игры
enum BoardState: Equatable {
    case inProgress
    case won(PlayerMark)
    case draw
}

// Структура для хранения координат
struct Position: Hashable {
    let row: Int
    let col: Int
}

// Модель ячейки
struct Cell: Identifiable {
    let id = UUID()
    var state: CellState = .empty
    let position: Position
}

// Модель мини-доски
struct MiniBoard: Identifiable {
    let id = UUID()
    let position: Position
    var cells: [[Cell]]
    var state: BoardState = .inProgress
    
    init(position: Position) {
        self.position = position
        self.cells = (0..<3).map { row in
            (0..<3).map { col in
                Cell(position: Position(row: row, col: col))
            }
        }
    }
}

// Модель основной доски
struct GameBoard {
    var boards: [[MiniBoard]]
    var currentBoardPosition: Position? // Активная мини-доска для текущего хода
    var currentPlayer: PlayerMark = .x
    var gameState: BoardState = .inProgress
    
    init() {
        self.boards = (0..<3).map { row in
            (0..<3).map { col in
                MiniBoard(position: Position(row: row, col: col))
            }
        }
        self.currentBoardPosition = nil // Первый ход может быть в любую мини-доску
    }
} 