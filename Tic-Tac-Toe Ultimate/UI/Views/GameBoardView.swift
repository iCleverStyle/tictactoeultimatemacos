import SwiftUI

struct GameBoardView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.presentationMode) private var presentationMode
    var onExit: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                // Информация о текущем игроке
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Текущий ход:")
                            .font(.headline)
                        
                        HStack {
                            Text(viewModel.currentPlayer == .x ? "X" : "O")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(viewModel.currentPlayer == .x ? .blue : .red)
                            
                            if viewModel.gameMode == .singlePlayer {
                                Text(viewModel.currentPlayer == .x ? "(Игрок)" : "(Компьютер)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("(Игрок \(viewModel.currentPlayer == .x ? "1" : "2"))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Отображаем уровень сложности бота, если режим игры с 1 игроком
                    if viewModel.gameMode == .singlePlayer {
                        VStack(alignment: .center) {
                            Text("Сложность бота:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(viewModel.botDifficulty.description)
                                .font(.headline)
                                .foregroundColor(viewModel.botDifficulty == .easy ? .green : .red)
                        }
                        .padding(.trailing, 10)
                    }
                    
                    Button {
                        if let onExit = onExit {
                            onExit()
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Text("Выход")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Отображение глобальной доски
                VStack(spacing: 8) {
                    ForEach(0..<3) { boardRow in
                        HStack(spacing: 8) {
                            ForEach(0..<3) { boardCol in
                                let boardPosition = Position(row: boardRow, col: boardCol)
                                let isBoardActive = viewModel.gameBoard.currentBoardPosition == nil || 
                                                   (viewModel.gameBoard.currentBoardPosition?.row == boardRow && 
                                                    viewModel.gameBoard.currentBoardPosition?.col == boardCol)
                                
                                // Мини-доска
                                MiniBoardView(
                                    miniBoard: viewModel.gameBoard.boards[boardRow][boardCol],
                                    boardPosition: boardPosition,
                                    isActive: isBoardActive,
                                    onCellTap: viewModel.makeMove
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 5)
                
                Spacer()
            }
            .padding()
            .sheet(isPresented: $viewModel.showVictoryScreen) {
                VictoryView(
                    viewModel: viewModel,
                    onPlayAgain: {
                        viewModel.startNewGame(
                            mode: viewModel.gameMode,
                            firstMoveSelection: viewModel.firstMoveSelection,
                            firstPlayer: viewModel.selectedFirstPlayer,
                            difficulty: viewModel.botDifficulty
                        )
                    },
                    onMainMenu: {
                        viewModel.showVictoryScreen = false
                        if let onExit = onExit {
                            onExit()
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }
}

// Компонент для отображения мини-доски
struct MiniBoardView: View {
    let miniBoard: MiniBoard
    let boardPosition: Position
    let isActive: Bool
    let onCellTap: (Position, Position) -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<3) { row in
                HStack(spacing: 2) {
                    ForEach(0..<3) { col in
                        let cell = miniBoard.cells[row][col]
                        let cellPosition = Position(row: row, col: col)
                        
                        CellView(
                            cell: cell,
                            isEnabled: isActive && miniBoard.state == .inProgress,
                            onTap: {
                                onCellTap(boardPosition, cellPosition)
                            }
                        )
                    }
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? Color.blue : Color.gray, lineWidth: isActive ? 3 : 1)
        )
        .overlay(
            Group {
                if case .won(let mark) = miniBoard.state {
                    ZStack {
                        Color(NSColor.windowBackgroundColor)
                            .opacity(0.85)
                            .cornerRadius(8)
                        
                        Text(mark == .x ? "X" : "O")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(mark == .x ? .blue : .red)
                    }
                } else if case .draw = miniBoard.state {
                    ZStack {
                        Color(NSColor.windowBackgroundColor)
                            .opacity(0.85)
                            .cornerRadius(8)
                        
                        Text("Ничья")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.gray)
                    }
                }
            }
        )
    }
}

// Компонент для отображения ячейки
struct CellView: View {
    let cell: Cell
    let isEnabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            if isEnabled && cell.state.isEmpty {
                onTap()
            }
        }) {
            ZStack {
                Rectangle()
                    .fill(Color(NSColor.controlBackgroundColor))
                    .aspectRatio(1, contentMode: .fit)
                
                if case .marked(let mark) = cell.state {
                    Text(mark == .x ? "X" : "O")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(mark == .x ? .blue : .red)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled || !cell.state.isEmpty)
    }
}

struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        GameBoardView(viewModel: GameViewModel(), onExit: {})
    }
} 