import SwiftUI

struct GameStartView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var showingFirstPlayerSelection = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(NSColor.windowBackgroundColor)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Text("Ultimate Tic-Tac-Toe")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("Выберите режим игры")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Button {
                            gameViewModel.gameMode = .singlePlayer
                            showingFirstPlayerSelection = true
                        } label: {
                            GameModeButton(title: "1 игрок", subtitle: "Играть против компьютера", isSelected: gameViewModel.gameMode == .singlePlayer)
                        }
                        
                        Button {
                            gameViewModel.gameMode = .twoPlayers
                            showingFirstPlayerSelection = true
                        } label: {
                            GameModeButton(title: "2 игрока", subtitle: "Играть с другом", isSelected: gameViewModel.gameMode == .twoPlayers)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .sheet(isPresented: $showingFirstPlayerSelection) {
                FirstPlayerSelectionView(gameViewModel: gameViewModel)
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
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
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

struct GameStartView_Previews: PreviewProvider {
    static var previews: some View {
        GameStartView()
    }
} 