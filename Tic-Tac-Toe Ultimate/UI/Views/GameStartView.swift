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
        NavigationView {
            ZStack {
                Color(NSColor.windowBackgroundColor)
                    .edgesIgnoringSafeArea(.all)
                
                if !showGameBoard {
                    ScrollView {
                        VStack(spacing: 25) {
                            Text("Ultimate Tic-Tac-Toe")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 30)
                            
                            // Секция выбора режима игры
                            VStack(spacing: 15) {
                                Text("Выберите режим игры")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                
                                Button {
                                    gameViewModel.gameMode = .singlePlayer
                                    setupInitialPlayerSelection()
                                } label: {
                                    GameModeButton(title: "1 игрок", subtitle: "Играть против компьютера", isSelected: gameViewModel.gameMode == .singlePlayer)
                                }
                                
                                Button {
                                    gameViewModel.gameMode = .twoPlayers
                                    // Сбрасываем выбор первого игрока при смене режима
                                    gameViewModel.selectedFirstPlayer = .x
                                } label: {
                                    GameModeButton(title: "2 игрока", subtitle: "Играть с другом", isSelected: gameViewModel.gameMode == .twoPlayers)
                                }
                            }
                            
                            // Секция выбора первого хода
                            VStack(spacing: 15) {
                                Text("Выбор первого хода")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                
                                Button {
                                    gameViewModel.firstMoveSelection = .direct
                                    if gameViewModel.gameMode == .singlePlayer {
                                        setupInitialPlayerSelection()
                                    }
                                } label: {
                                    SelectionButton(
                                        title: "Прямой выбор",
                                        subtitle: "Вы выбираете, кто ходит первым",
                                        isSelected: gameViewModel.firstMoveSelection == .direct
                                    )
                                }
                                
                                Button {
                                    gameViewModel.firstMoveSelection = .random
                                } label: {
                                    SelectionButton(
                                        title: "Случайный выбор",
                                        subtitle: "Первый игрок выбирается случайно",
                                        isSelected: gameViewModel.firstMoveSelection == .random
                                    )
                                }
                                
                                // Выбор первого игрока (если прямой выбор)
                                if gameViewModel.firstMoveSelection == .direct {
                                    VStack(spacing: 10) {
                                        if gameViewModel.gameMode == .singlePlayer {
                                            // Для одиночного режима показываем информационное сообщение
                                            Text("Бот ходит первым (играет X):")
                                                .font(.headline)
                                                .padding(.top, 5)
                                        } else {
                                            // Для режима с двумя игроками оставляем выбор
                                            Text("Кто ходит первым (всегда играет X):")
                                                .font(.headline)
                                                .padding(.top, 5)
                                        }
                                        
                                        AdaptivePlayerSelection(
                                            selectedFirstPlayer: $gameViewModel.selectedFirstPlayer,
                                            gameMode: gameViewModel.gameMode,
                                            isSelectionEnabled: gameViewModel.gameMode != .singlePlayer
                                        )
                                    }
                                    .padding(.top, 5)
                                }
                            }
                            
                            Spacer()
                            
                            // Кнопка старта игры
                            Button {
                                // Начинаем новую игру
                                gameViewModel.startNewGame(
                                    mode: gameViewModel.gameMode,
                                    firstMoveSelection: gameViewModel.firstMoveSelection,
                                    firstPlayer: gameViewModel.selectedFirstPlayer
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
}

struct GameModeButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    
    var body: some View {
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
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

struct SelectionButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    
    var body: some View {
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
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
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
                Button {
                    selectedFirstPlayer = .x
                } label: {
                    PlayerSelectionButton(
                        title: "Игрок 1",
                        symbol: selectedFirstPlayer == .x ? "X" : "O",
                        symbolColor: selectedFirstPlayer == .x ? .blue : .red,
                        isSelected: selectedFirstPlayer == .x,
                        info: selectedFirstPlayer == .x ? "Ходит первым" : "Ходит вторым",
                        size: buttonSize
                    )
                }
                .disabled(!isSelectionEnabled)
                
                Button {
                    selectedFirstPlayer = .o
                } label: {
                    PlayerSelectionButton(
                        title: gameMode == .singlePlayer ? "Бот" : "Игрок 2",
                        symbol: selectedFirstPlayer == .o ? "X" : "O",
                        symbolColor: selectedFirstPlayer == .o ? .blue : .red,
                        isSelected: selectedFirstPlayer == .o,
                        info: selectedFirstPlayer == .o ? "Ходит первым" : "Ходит вторым",
                        size: buttonSize
                    )
                }
                .disabled(!isSelectionEnabled)
                
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
    
    init(title: String, 
         symbol: String, 
         symbolColor: Color = .blue,
         isSelected: Bool, 
         info: String = "", 
         size: CGFloat = 100) {
        self.title = title
        self.symbol = symbol
        self.symbolColor = symbolColor
        self.isSelected = isSelected
        self.info = info
        self.size = size
    }
    
    var body: some View {
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
        SpriteView(scene: GameScene(size: CGSize(width: 800, height: 600)))
            .frame(width: 800, height: 600)
    }
} 