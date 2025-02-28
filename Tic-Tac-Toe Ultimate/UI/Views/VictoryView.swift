import SwiftUI

struct VictoryView: View {
    @ObservedObject var viewModel: GameViewModel
    let onPlayAgain: () -> Void
    let onMainMenu: () -> Void
    
    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                if let winningPlayer = viewModel.winningPlayer {
                    Text(winningPlayer == .x ? "X" : "O")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(winningPlayer == .x ? .blue : .red)
                    
                    Text("Победа!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Group {
                        if viewModel.gameMode == .singlePlayer {
                            if (winningPlayer == .x) {
                                Text("Поздравляем, вы выиграли!")
                                    .font(.title2)
                            } else {
                                Text("Компьютер выиграл!")
                                    .font(.title2)
                            }
                        } else {
                            Text("Игрок \(winningPlayer == .x ? "1" : "2") выиграл!")
                                .font(.title2)
                        }
                    }
                    .padding(.top, 5)
                } else if viewModel.isGameDraw {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 100))
                        .foregroundColor(.gray)
                    
                    Text("Ничья!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Нет победителя")
                        .font(.title2)
                        .padding(.top, 5)
                }
                
                Spacer()
                
                // Анимированный фон с конфетти
                ConfettiView()
                    .frame(height: 10)
                
                Spacer()
                
                VStack(spacing: 5) {
                    // Кнопка "Играть снова" без подсветки активности
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Играть снова")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onPlayAgain()
                    }
                    
                    // Кнопка "Главное меню" без подсветки активности
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Главное меню")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onMainMenu()
                    }
                }
            }
            .padding()
        }
    }
}

// Анимация конфетти для экрана победы
struct ConfettiView: View {
    @State private var isAnimating = false
    private let screenWidth = NSScreen.main?.frame.width ?? 800
    
    var body: some View {
        ZStack {
            ForEach(0..<30) { index in
                ConfettiPiece(
                    color: [.blue, .red, .green, .yellow, .orange, .purple].randomElement()!,
                    position: CGPoint(
                        x: CGFloat.random(in: 0...1),
                        y: isAnimating ? 1.1 : -0.2
                    ),
                    rotation: isAnimating ? Double.random(in: 0...360) : 0,
                    size: CGFloat.random(in: 5...15),
                    screenWidth: screenWidth
                )
                .animation(
                    Animation.linear(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: false)
                        .delay(Double.random(in: 0...1)),
                    value: isAnimating
                )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let position: CGPoint
    let rotation: Double
    let size: CGFloat
    let screenWidth: CGFloat
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .position(x: position.x * screenWidth, y: position.y * 200)
    }
}

struct VictoryView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = GameViewModel()
        viewModel.winningPlayer = .x
        
        return VictoryView(
            viewModel: viewModel,
            onPlayAgain: {},
            onMainMenu: {}
        )
    }
} 
