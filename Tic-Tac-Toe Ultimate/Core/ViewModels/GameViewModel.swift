import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameBoard = GameBoard()
    @Published var gameMode: GameMode = .twoPlayers
    @Published var firstMoveSelection: FirstMoveSelection = .direct
    @Published var selectedFirstPlayer: PlayerMark = .x
    @Published var showVictoryScreen = false
    @Published var winningPlayer: PlayerMark?
    @Published var isGameDraw = false
    @Published var botDifficulty: BotDifficulty = .easy
    
    // Текущее состояние игры
    var currentPlayer: PlayerMark {
        gameBoard.currentPlayer
    }
    
    // Инициализируем игру
    func startNewGame(mode: GameMode, firstMoveSelection: FirstMoveSelection, firstPlayer: PlayerMark = .x, difficulty: BotDifficulty = .easy) {
        self.gameMode = mode
        self.firstMoveSelection = firstMoveSelection
        self.gameBoard = GameBoard()
        self.showVictoryScreen = false
        self.winningPlayer = nil
        self.isGameDraw = false
        
        if mode == .singlePlayer {
            self.botDifficulty = difficulty
        }
        
        // Определяем, кто ходит первым
        if firstMoveSelection == .direct {
            // Устанавливаем выбранного игрока как первого
            self.selectedFirstPlayer = firstPlayer
        } else {
            // Случайный выбор первого игрока
            self.selectedFirstPlayer = Bool.random() ? .x : .o
        }
        
        // Устанавливаем того, кто ходит первым
        gameBoard.currentPlayer = selectedFirstPlayer
        
        // Если игра против компьютера и бот должен ходить первым (бот всегда O)
        if mode == .singlePlayer && selectedFirstPlayer == .o {
            // Даем боту сделать ход с небольшой задержкой
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.makeBotMove()
            }
        }
    }
    
    // Функция для выполнения хода
    func makeMove(boardPosition: Position, cellPosition: Position) {
        // Проверяем, можно ли сделать ход в данную мини-доску
        guard canMakeMove(boardPosition: boardPosition) else { return }
        
        // Проверяем, что это не ход бота (игрок не может сделать ход за бота)
        if gameMode == .singlePlayer && gameBoard.currentPlayer == .o {
            return
        }
        
        // Получаем доступ к конкретной мини-доске
        let _ = boardPosition.row * 3 + boardPosition.col
        let board = gameBoard.boards[boardPosition.row][boardPosition.col]
        
        // Проверяем, можно ли сделать ход в данную ячейку
        let cell = board.cells[cellPosition.row][cellPosition.col]
        guard cell.state.isEmpty && board.state == .inProgress else { return }
        
        // Делаем ход
        gameBoard.boards[boardPosition.row][boardPosition.col].cells[cellPosition.row][cellPosition.col].state = .marked(currentPlayer)
        
        // Проверяем, выиграна ли мини-доска
        checkMiniBoardState(at: boardPosition)
        
        // Проверяем, выиграна ли вся игра
        checkGameState()
        
        // Если игра продолжается, переключаем игрока и определяем следующую активную мини-доску
        if gameBoard.gameState == .inProgress {
            // Определяем следующую активную мини-доску
            let nextBoardPosition = Position(row: cellPosition.row, col: cellPosition.col)
            
            // Если указанная доска уже выиграна или ничья, то следующий ход может быть в любую доску
            if gameBoard.boards[nextBoardPosition.row][nextBoardPosition.col].state != .inProgress {
                gameBoard.currentBoardPosition = nil
            } else {
                gameBoard.currentBoardPosition = nextBoardPosition
            }
            
            // Переключаем игрока
            gameBoard.currentPlayer = gameBoard.currentPlayer.opposite
            
            // Если игра против компьютера и сейчас ход компьютера
            if gameMode == .singlePlayer && gameBoard.currentPlayer == .o {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.makeBotMove()
                }
            }
        } else if case .won(let mark) = gameBoard.gameState {
            // Если есть победитель, показываем экран победы
            self.winningPlayer = mark
            self.showVictoryScreen = true
        } else if case .draw = gameBoard.gameState {
            // Если ничья
            self.isGameDraw = true
            self.showVictoryScreen = true
        }
    }
    
    // Проверяем, можно ли сделать ход в данную мини-доску
    private func canMakeMove(boardPosition: Position) -> Bool {
        // Если текущая доска не указана (первый ход или предыдущий ход был в завершенную доску),
        // то можно ходить в любую незавершенную доску
        if gameBoard.currentBoardPosition == nil {
            return gameBoard.boards[boardPosition.row][boardPosition.col].state == .inProgress
        }
        
        // Иначе можно ходить только в указанную доску
        return gameBoard.currentBoardPosition?.row == boardPosition.row &&
               gameBoard.currentBoardPosition?.col == boardPosition.col &&
               gameBoard.boards[boardPosition.row][boardPosition.col].state == .inProgress
    }
    
    // Проверяем, выиграна ли мини-доска
    private func checkMiniBoardState(at position: Position) {
        let board = gameBoard.boards[position.row][position.col]
        let cells = board.cells
        
        // Проверяем строки
        for row in 0..<3 {
            if let mark = cells[row][0].state.mark,
               cells[row][1].state.mark == mark,
               cells[row][2].state.mark == mark {
                gameBoard.boards[position.row][position.col].state = .won(mark)
                return
            }
        }
        
        // Проверяем столбцы
        for col in 0..<3 {
            if let mark = cells[0][col].state.mark,
               cells[1][col].state.mark == mark,
               cells[2][col].state.mark == mark {
                gameBoard.boards[position.row][position.col].state = .won(mark)
                return
            }
        }
        
        // Проверяем диагонали
        if let mark = cells[0][0].state.mark,
           cells[1][1].state.mark == mark,
           cells[2][2].state.mark == mark {
            gameBoard.boards[position.row][position.col].state = .won(mark)
            return
        }
        
        if let mark = cells[0][2].state.mark,
           cells[1][1].state.mark == mark,
           cells[2][0].state.mark == mark {
            gameBoard.boards[position.row][position.col].state = .won(mark)
            return
        }
        
        // Проверяем на ничью (все ячейки заполнены)
        var isFull = true
        for row in 0..<3 {
            for col in 0..<3 {
                if cells[row][col].state.isEmpty {
                    isFull = false
                    break
                }
            }
            if !isFull { break }
        }
        
        if isFull {
            gameBoard.boards[position.row][position.col].state = .draw
        }
    }
    
    // Проверяем, выиграна ли вся игра
    private func checkGameState() {
        let boards = gameBoard.boards
        
        // Проверяем строки
        for row in 0..<3 {
            if case .won(let mark) = boards[row][0].state,
               case .won(let mark2) = boards[row][1].state, mark == mark2,
               case .won(let mark3) = boards[row][2].state, mark == mark3 {
                gameBoard.gameState = .won(mark)
                return
            }
        }
        
        // Проверяем столбцы
        for col in 0..<3 {
            if case .won(let mark) = boards[0][col].state,
               case .won(let mark2) = boards[1][col].state, mark == mark2,
               case .won(let mark3) = boards[2][col].state, mark == mark3 {
                gameBoard.gameState = .won(mark)
                return
            }
        }
        
        // Проверяем диагонали
        if case .won(let mark) = boards[0][0].state,
           case .won(let mark2) = boards[1][1].state, mark == mark2,
           case .won(let mark3) = boards[2][2].state, mark == mark3 {
            gameBoard.gameState = .won(mark)
            return
        }
        
        if case .won(let mark) = boards[0][2].state,
           case .won(let mark2) = boards[1][1].state, mark == mark2,
           case .won(let mark3) = boards[2][0].state, mark == mark3 {
            gameBoard.gameState = .won(mark)
            return
        }
        
        // Проверяем на ничью (все мини-доски завершены)
        var allBoardsCompleted = true
        for row in 0..<3 {
            for col in 0..<3 {
                if boards[row][col].state == .inProgress {
                    allBoardsCompleted = false
                    break
                }
            }
            if !allBoardsCompleted { break }
        }
        
        if allBoardsCompleted {
            gameBoard.gameState = .draw
        }
    }
    
    // Логика для хода компьютера
    private func makeBotMove() {
        // Бот всегда играет за O
        guard gameBoard.gameState == .inProgress && gameBoard.currentPlayer == .o else { return }
        
        var boardPosition: Position
        var cellPosition: Position
        
        switch botDifficulty {
        case .easy:
            // Простая стратегия: выбираем случайную доступную ячейку
            let randomMove = findRandomMove()
            guard let move = randomMove else { return }
            boardPosition = move.boardPos
            cellPosition = move.cellPos
            
        case .hard:
            // Сложная стратегия: используем minimax с альфа-бета отсечением
            let bestMove = findBestMove()
            guard let move = bestMove else { return }
            boardPosition = move.boardPos
            cellPosition = move.cellPos
        }
        
        // Непосредственно делаем ход бота
        if canMakeMove(boardPosition: boardPosition) {
            // Получаем доступ к конкретной мини-доске
            let board = gameBoard.boards[boardPosition.row][boardPosition.col]
            
            // Проверяем, можно ли сделать ход в данную ячейку
            let cell = board.cells[cellPosition.row][cellPosition.col]
            if cell.state.isEmpty && board.state == .inProgress {
                // Делаем ход
                gameBoard.boards[boardPosition.row][boardPosition.col].cells[cellPosition.row][cellPosition.col].state = .marked(currentPlayer)
                
                // Проверяем, выиграна ли мини-доска
                checkMiniBoardState(at: boardPosition)
                
                // Проверяем, выиграна ли вся игра
                checkGameState()
                
                // Если игра продолжается, переключаем игрока и определяем следующую активную мини-доску
                if gameBoard.gameState == .inProgress {
                    // Определяем следующую активную мини-доску
                    let nextBoardPosition = Position(row: cellPosition.row, col: cellPosition.col)
                    
                    // Если указанная доска уже выиграна или ничья, то следующий ход может быть в любую доску
                    if gameBoard.boards[nextBoardPosition.row][nextBoardPosition.col].state != .inProgress {
                        gameBoard.currentBoardPosition = nil
                    } else {
                        gameBoard.currentBoardPosition = nextBoardPosition
                    }
                    
                    // Переключаем игрока
                    gameBoard.currentPlayer = gameBoard.currentPlayer.opposite
                } else if case .won(let mark) = gameBoard.gameState {
                    // Если есть победитель, показываем экран победы
                    self.winningPlayer = mark
                    self.showVictoryScreen = true
                } else if case .draw = gameBoard.gameState {
                    // Если ничья
                    self.isGameDraw = true
                    self.showVictoryScreen = true
                }
            }
        }
    }
    
    // Метод для поиска случайного хода (для лёгкого уровня)
    private func findRandomMove() -> (boardPos: Position, cellPos: Position)? {
        var availableMoves: [(boardPos: Position, cellPos: Position)] = []
        
        // Если текущая доска указана, ищем доступные ходы только в ней
        if let currentBoardPos = gameBoard.currentBoardPosition {
            let board = gameBoard.boards[currentBoardPos.row][currentBoardPos.col]
            if board.state == .inProgress {
                for row in 0..<3 {
                    for col in 0..<3 {
                        if board.cells[row][col].state.isEmpty {
                            availableMoves.append((currentBoardPos, Position(row: row, col: col)))
                        }
                    }
                }
            }
        } else {
            // Иначе ищем доступные ходы во всех незавершенных досках
            for boardRow in 0..<3 {
                for boardCol in 0..<3 {
                    let board = gameBoard.boards[boardRow][boardCol]
                    if board.state == .inProgress {
                        for cellRow in 0..<3 {
                            for cellCol in 0..<3 {
                                if board.cells[cellRow][cellCol].state.isEmpty {
                                    availableMoves.append((Position(row: boardRow, col: boardCol), 
                                                          Position(row: cellRow, col: cellCol)))
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Если есть доступные ходы, выбираем случайный
        return availableMoves.isEmpty ? nil : availableMoves.randomElement()
    }
    
    // Метод для поиска лучшего хода (для сложного уровня)
    private func findBestMove() -> (boardPos: Position, cellPos: Position)? {
        var bestScore = Int.min
        var bestMove: (boardPos: Position, cellPos: Position)?
        
        // Получаем все возможные ходы
        let availableMoves = getAllAvailableMoves()
        
        // Если нет доступных ходов, возвращаем nil
        if availableMoves.isEmpty {
            return nil
        }
        
        // Бот всегда играет за O
        let botMark: PlayerMark = .o
        
        // Создаем копию текущего состояния игры для симуляции
        var boardCopy = gameBoard
        
        // Перебираем все возможные ходы и выбираем лучший
        for move in availableMoves {
            let boardPos = move.boardPos
            let cellPos = move.cellPos
            
            // Симулируем ход
            boardCopy.boards[boardPos.row][boardPos.col].cells[cellPos.row][cellPos.col].state = .marked(botMark)
            
            // Проверяем, выиграна ли мини-доска после этого хода
            updateMiniBoardState(for: &boardCopy, at: boardPos)
            
            // Определяем следующую активную мини-доску
            let nextBoardPosition = Position(row: cellPos.row, col: cellPos.col)
            if boardCopy.boards[nextBoardPosition.row][nextBoardPosition.col].state != .inProgress {
                boardCopy.currentBoardPosition = nil
            } else {
                boardCopy.currentBoardPosition = nextBoardPosition
            }
            
            // Вызываем minimax с альфа-бета отсечением
            let score = minimax(board: boardCopy, depth: 3, isMaximizing: false, alpha: Int.min, beta: Int.max)
            
            // Отменяем симулированный ход
            boardCopy = gameBoard
            
            // Если текущий ход лучше предыдущего лучшего, обновляем лучший ход
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }
        
        return bestMove
    }
    
    // Алгоритм minimax с альфа-бета отсечением
    private func minimax(board: GameBoard, depth: Int, isMaximizing: Bool, alpha: Int, beta: Int) -> Int {
        // Проверяем, закончилась ли игра или достигнута максимальная глубина
        if depth == 0 || board.gameState != .inProgress {
            return evaluateBoard(board)
        }
        
        // Получаем все возможные ходы для текущего состояния
        let availableMoves = getAllAvailableMovesFor(board: board)
        
        // Если нет доступных ходов, оцениваем доску
        if availableMoves.isEmpty {
            return evaluateBoard(board)
        }
        
        if isMaximizing {
            // Ход бота (максимизируем оценку)
            var maxEval = Int.min
            var alphaValue = alpha
            
            for move in availableMoves {
                let boardPos = move.boardPos
                let cellPos = move.cellPos
                
                // Создаем копию доски для симуляции
                var boardCopy = board
                
                // Симулируем ход
                boardCopy.boards[boardPos.row][boardPos.col].cells[cellPos.row][cellPos.col].state = .marked(.o)
                
                // Проверяем, выиграна ли мини-доска после этого хода
                updateMiniBoardState(for: &boardCopy, at: boardPos)
                
                // Определяем следующую активную мини-доску
                let nextBoardPosition = Position(row: cellPos.row, col: cellPos.col)
                if boardCopy.boards[nextBoardPosition.row][nextBoardPosition.col].state != .inProgress {
                    boardCopy.currentBoardPosition = nil
                } else {
                    boardCopy.currentBoardPosition = nextBoardPosition
                }
                
                // Рекурсивно вызываем minimax для следующего уровня
                let eval = minimax(board: boardCopy, depth: depth - 1, isMaximizing: false, alpha: alphaValue, beta: beta)
                maxEval = max(maxEval, eval)
                
                // Альфа-бета отсечение
                alphaValue = max(alphaValue, eval)
                if beta <= alphaValue {
                    break
                }
            }
            
            return maxEval
        } else {
            // Ход игрока (минимизируем оценку)
            var minEval = Int.max
            var betaValue = beta
            
            for move in availableMoves {
                let boardPos = move.boardPos
                let cellPos = move.cellPos
                
                // Создаем копию доски для симуляции
                var boardCopy = board
                
                // Симулируем ход
                boardCopy.boards[boardPos.row][boardPos.col].cells[cellPos.row][cellPos.col].state = .marked(.x)
                
                // Проверяем, выиграна ли мини-доска после этого хода
                updateMiniBoardState(for: &boardCopy, at: boardPos)
                
                // Определяем следующую активную мини-доску
                let nextBoardPosition = Position(row: cellPos.row, col: cellPos.col)
                if boardCopy.boards[nextBoardPosition.row][nextBoardPosition.col].state != .inProgress {
                    boardCopy.currentBoardPosition = nil
                } else {
                    boardCopy.currentBoardPosition = nextBoardPosition
                }
                
                // Рекурсивно вызываем minimax для следующего уровня
                let eval = minimax(board: boardCopy, depth: depth - 1, isMaximizing: true, alpha: alpha, beta: betaValue)
                minEval = min(minEval, eval)
                
                // Альфа-бета отсечение
                betaValue = min(betaValue, eval)
                if betaValue <= alpha {
                    break
                }
            }
            
            return minEval
        }
    }
    
    // Вспомогательный метод для получения всех возможных ходов
    private func getAllAvailableMoves() -> [(boardPos: Position, cellPos: Position)] {
        return getAllAvailableMovesFor(board: gameBoard)
    }
    
    // Вспомогательный метод для получения всех возможных ходов для конкретной доски
    private func getAllAvailableMovesFor(board: GameBoard) -> [(boardPos: Position, cellPos: Position)] {
        var availableMoves: [(boardPos: Position, cellPos: Position)] = []
        
        // Если текущая доска указана, ищем доступные ходы только в ней
        if let currentBoardPos = board.currentBoardPosition {
            let miniBoard = board.boards[currentBoardPos.row][currentBoardPos.col]
            if miniBoard.state == .inProgress {
                for row in 0..<3 {
                    for col in 0..<3 {
                        if miniBoard.cells[row][col].state.isEmpty {
                            availableMoves.append((currentBoardPos, Position(row: row, col: col)))
                        }
                    }
                }
            }
        } else {
            // Иначе ищем доступные ходы во всех незавершенных досках
            for boardRow in 0..<3 {
                for boardCol in 0..<3 {
                    let miniBoard = board.boards[boardRow][boardCol]
                    if miniBoard.state == .inProgress {
                        for cellRow in 0..<3 {
                            for cellCol in 0..<3 {
                                if miniBoard.cells[cellRow][cellCol].state.isEmpty {
                                    availableMoves.append((Position(row: boardRow, col: boardCol), 
                                                          Position(row: cellRow, col: cellCol)))
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return availableMoves
    }
    
    // Метод для оценки текущего состояния доски (эвристическая функция)
    private func evaluateBoard(_ board: GameBoard) -> Int {
        // Проверяем, есть ли победитель в игре
        if case .won(let mark) = board.gameState {
            return mark == .o ? 1000 : -1000
        }
        
        // Если игра завершилась вничью
        if case .draw = board.gameState {
            return 0
        }
        
        // Оценка по мини-доскам
        var score = 0
        
        // Оцениваем каждую мини-доску
        for row in 0..<3 {
            for col in 0..<3 {
                let miniBoard = board.boards[row][col]
                
                if case .won(let mark) = miniBoard.state {
                    score += mark == .o ? 100 : -100
                }
                
                // Дополнительные очки за стратегически выгодные мини-доски (центр и углы)
                if case .won(.o) = miniBoard.state {
                    if (row == 1 && col == 1) { // Центр
                        score += 30
                    } else if (row == 0 || row == 2) && (col == 0 || col == 2) { // Углы
                        score += 20
                    }
                }
            }
        }
        
        return score
    }
    
    // Вспомогательный метод для обновления состояния мини-доски (для симуляции)
    private func updateMiniBoardState(for board: inout GameBoard, at position: Position) {
        let miniBoard = board.boards[position.row][position.col]
        let cells = miniBoard.cells
        
        // Проверяем строки
        for row in 0..<3 {
            if let mark = cells[row][0].state.mark,
               cells[row][1].state.mark == mark,
               cells[row][2].state.mark == mark {
                board.boards[position.row][position.col].state = .won(mark)
                return
            }
        }
        
        // Проверяем столбцы
        for col in 0..<3 {
            if let mark = cells[0][col].state.mark,
               cells[1][col].state.mark == mark,
               cells[2][col].state.mark == mark {
                board.boards[position.row][position.col].state = .won(mark)
                return
            }
        }
        
        // Проверяем диагонали
        if let mark = cells[0][0].state.mark,
           cells[1][1].state.mark == mark,
           cells[2][2].state.mark == mark {
            board.boards[position.row][position.col].state = .won(mark)
            return
        }
        
        if let mark = cells[0][2].state.mark,
           cells[1][1].state.mark == mark,
           cells[2][0].state.mark == mark {
            board.boards[position.row][position.col].state = .won(mark)
            return
        }
        
        // Проверяем на ничью (все ячейки заполнены)
        var isFull = true
        for row in 0..<3 {
            for col in 0..<3 {
                if cells[row][col].state.isEmpty {
                    isFull = false
                    break
                }
            }
            if !isFull { break }
        }
        
        if isFull {
            board.boards[position.row][position.col].state = .draw
        }
    }
} 
