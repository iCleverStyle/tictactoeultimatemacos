import SwiftUI

struct FirstPlayerSelectionView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var gameViewModel: GameViewModel
    @State private var showGameBoard = false
    
    // Когда представление появляется, если это одиночный режим, 
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
                // Экран выбора первого игрока
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Назад")
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Text("Выбор первого хода")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Способ определения первого хода:")
                                .font(.headline)
                                .padding(.top, 5)
                            
                            Button {
                                gameViewModel.firstMoveSelection = .direct
                                // Если это одиночный режим, сразу выбираем бота первым игроком
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
                            
                            if gameViewModel.firstMoveSelection == .direct {
                                if gameViewModel.gameMode == .singlePlayer {
                                    // Для одиночного режима показываем информационное сообщение
                                    Text("Бот ходит первым (играет X):")
                                        .font(.headline)
                                        .padding(.top, 10)
                                        .padding(.bottom, 5)
                                } else {
                                    // Для режима с двумя игроками оставляем выбор
                                    Text("Кто ходит первым (всегда играет X):")
                                        .font(.headline)
                                        .padding(.top, 10)
                                        .padding(.bottom, 5)
                                }
                                
                                AdaptivePlayerSelection(
                                    selectedFirstPlayer: $gameViewModel.selectedFirstPlayer,
                                    gameMode: gameViewModel.gameMode,
                                    isSelectionEnabled: gameViewModel.gameMode != .singlePlayer // Отключаем выбор в режиме против бота
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        Spacer(minLength: 20)
                        
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
                        .padding(.bottom)
                    }
                    .padding()
                }
                .onAppear {
                    // При появлении экрана устанавливаем начальный выбор только в режиме одиночной игры
                    if gameViewModel.gameMode == .singlePlayer {
                        setupInitialPlayerSelection()
                    }
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

struct AdaptivePlayerSelection: View {
    @Binding var selectedFirstPlayer: PlayerMark
    let gameMode: GameMode
    let isSelectionEnabled: Bool // Добавляем параметр для управления возможностью выбора
    
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

struct FirstPlayerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        FirstPlayerSelectionView(gameViewModel: GameViewModel())
    }
} 