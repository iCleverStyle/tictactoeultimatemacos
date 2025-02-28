import SwiftUI
import SpriteKit

struct GameStartView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var showGameBoard = false
    
    // Когда представление появляется и выбран одиночный режим, 
    // автоматически устанавливаем бота как первого игрока
    private func setupInitialPlayerSelection() {
        if gameViewModel.gameMode == .singlePlayer {
            gameViewModel.selectedFirstPlayer = .o // Устанавливаем, что бот (.o) ходит первым
        }
    }
    
    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)
                .edgesIgnoringSafeArea(.all)
            
            if !showGameBoard {
                ScrollView {
                    VStack(spacing: 25) {
                        Text("Ultimate Tic-Tac-Toe")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        
                        // Секция выбора режима игры
                        VStack(spacing: 20) {
                            Text("Выберите режим игры")
                                .font(.title2)
                                .fontWeight(.medium)
                            HStack {
                                SelectionButton(
                                    title: "1 игрок",
                                    subtitle: "Играть против компьютера",
                                    isSelected: gameViewModel.gameMode == .singlePlayer,
                                    action: {
                                        gameViewModel.gameMode = .singlePlayer
                                    }
                                )
                                
                                SelectionButton(
                                    title: "2 игрока",
                                    subtitle: "Играть с другом",
                                    isSelected: gameViewModel.gameMode == .twoPlayers,
                                    action: {
                                        gameViewModel.gameMode = .twoPlayers
                                        gameViewModel.selectedFirstPlayer = .x
                                    }
                                )
                            }
                        }
                        
                        // Секция выбора сложности бота (только для одиночного режима)
                        if gameViewModel.gameMode == .singlePlayer {
                            VStack(spacing: 15) {
                                Text("Уровень сложности")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                HStack {
                                    SelectionButton(
                                        title: "Лёгкий",
                                        subtitle: "Случайные ходы",
                                        isSelected: gameViewModel.botDifficulty == .easy,
                                        action: {
                                            gameViewModel.botDifficulty = .easy
                                        }
                                    )
                                    
                                    SelectionButton(
                                        title: "Сложный",
                                        subtitle: "Стратегические ходы",
                                        isSelected: gameViewModel.botDifficulty == .hard,
                                        action: {
                                            gameViewModel.botDifficulty = .hard
                                        }
                                    )
                                }
                            }
                        }
                        
                        // Секция выбора первого хода
                        VStack(spacing: 15) {
                            Text("Выбор первого хода")
                                .font(.title2)
                                .fontWeight(.medium)
                            HStack {
                                SelectionButton(
                                    title: "Прямой выбор",
                                    subtitle: "Вы выбираете, кто ходит первым",
                                    isSelected: gameViewModel.firstMoveSelection == .direct,
                                    action: {
                                        gameViewModel.firstMoveSelection = .direct
                                        if gameViewModel.gameMode == .singlePlayer {
                                            setupInitialPlayerSelection()
                                        }
                                    }
                                )
                                
                                SelectionButton(
                                    title: "Случайный выбор",
                                    subtitle: "Первый игрок выбирается случайно",
                                    isSelected: gameViewModel.firstMoveSelection == .random,
                                    action: {
                                        gameViewModel.firstMoveSelection = .random
                                    }
                                )
                            }

                            // Выбор первого игрока (если прямой выбор)
                            if gameViewModel.firstMoveSelection == .direct {
                                VStack(spacing: 10) {

                                    Text("Кто ходит первым?")
                                        .font(.headline)
                                        .padding(.top, 5)

                                    
                                    AdaptivePlayerSelection(
                                        selectedFirstPlayer: $gameViewModel.selectedFirstPlayer,
                                        gameMode: gameViewModel.gameMode//,
                                        //isSelectionEnabled: gameViewModel.gameMode != .singlePlayer
                                    )
                                }
                                .padding(.top, 5)
                            }
                        }
                        

                        
                        // Кнопка старта игры
                        Button {
                            // Начинаем новую игру
                            gameViewModel.startNewGame(
                                mode: gameViewModel.gameMode,
                                firstMoveSelection: gameViewModel.firstMoveSelection,
                                firstPlayer: gameViewModel.selectedFirstPlayer,
                                difficulty: gameViewModel.botDifficulty
                            )
                            
                            // Показываем игровое поле
                            showGameBoard = true
                        } label: {
                            Text("Начать игру")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.top, 20)
                    }
                    .padding()
                    .frame(maxWidth: 600) // Ограничиваем максимальную ширину для лучшего внешнего вида
                    .frame(maxWidth: .infinity) // Центрируем содержимое
                }
            } else {
                // Экран игры
                GameBoardView(viewModel: gameViewModel, onExit: {
                    showGameBoard = false
                })
            }
        }
    }
}

struct GameModeButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Фон с границей
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
                
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 2)
                }
                // Содержимое
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "person")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SelectionButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Фон с границей
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
                
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 2)
                }
                // Содержимое
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AdaptivePlayerSelection: View {
    @Binding var selectedFirstPlayer: PlayerMark
    let gameMode: GameMode
    let isSelectionEnabled: Bool
    
    init(selectedFirstPlayer: Binding<PlayerMark>, gameMode: GameMode, isSelectionEnabled: Bool = true) {
        self._selectedFirstPlayer = selectedFirstPlayer
        self.gameMode = gameMode
        self.isSelectionEnabled = isSelectionEnabled
    }
    
    var body: some View {
        GeometryReader { geometry in
            let buttonSize = min(140, (geometry.size.width - 30) / 2)
            
            HStack(spacing: 15) {
                PlayerSelectionButton(
                    title: "Игрок 1",
                    symbol: "X",
                    symbolColor: .blue,
                    isSelected: selectedFirstPlayer == .x,
                    info: selectedFirstPlayer == .x ? "Ходит первым" : "Ходит вторым",
                    size: buttonSize,
                    isEnabled: isSelectionEnabled,
                    action: {
                        selectedFirstPlayer = .x
                    }
                )
                
                PlayerSelectionButton(
                    title: gameMode == .singlePlayer ? "Бот" : "Игрок 2",
                    symbol: "O",
                    symbolColor: .red,
                    isSelected: selectedFirstPlayer == .o,
                    info: selectedFirstPlayer == .o ? "Ходит первым" : "Ходит вторым",
                    size: buttonSize,
                    isEnabled: isSelectionEnabled,
                    action: {
                        selectedFirstPlayer = .o
                    }
                )
                
                Spacer()
            }
        }
        .frame(height: 160)
    }
}

struct PlayerSelectionButton: View {
    let title: String
    let symbol: String
    let symbolColor: Color
    let isSelected: Bool
    let info: String
    let size: CGFloat
    let isEnabled: Bool
    let action: () -> Void
    
    init(title: String, 
         symbol: String, 
         symbolColor: Color = .blue,
         isSelected: Bool, 
         info: String = "", 
         size: CGFloat = 100,
         isEnabled: Bool = true,
         action: @escaping () -> Void) {
        self.title = title
        self.symbol = symbol
        self.symbolColor = symbolColor
        self.isSelected = isSelected
        self.info = info
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(symbol)
                    .font(.system(size: size * 0.3))
                    .fontWeight(.bold)
                    .foregroundColor(symbolColor)
                    .frame(width: size, height: size * 0.5)
                
                if !info.isEmpty {
                    HStack {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "clock")
                            .foregroundColor(isSelected ? .green : .gray)
                            .font(.system(size: 12))
                        
                        Text(info)
                            .font(.caption)
                            .foregroundColor(isSelected ? .green : .gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.vertical, 8)
            .frame(width: size)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }
}

struct GameStartView_Previews: PreviewProvider {
    static var previews: some View {
        GameStartView()
    }
}

struct SpriteView: NSViewRepresentable {
    var scene: SKScene
    
    func makeNSView(context: Context) -> SKView {
        let view = SKView()
        view.presentScene(scene)
        return view
    }
    
    func updateNSView(_ nsView: SKView, context: Context) {
        // Обновление при необходимости
    }
}

struct GameView: View {
    var body: some View {
        SpriteView(scene: GameScene(size: CGSize(width: 1000, height: 1000)))
            .frame(width: 1000, height: 1000)
    }
} 
