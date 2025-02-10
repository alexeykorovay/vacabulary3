import SwiftUI
import SwiftData

struct PlayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PlayerViewModel
    
    init(folders: [Folder]) {
        _viewModel = StateObject(wrappedValue: PlayerViewModel(folders: folders))
    }
    
    var body: some View {
        VStack {
            if let currentWord = viewModel.words.indices.contains(viewModel.currentWordIndex) ? viewModel.words[viewModel.currentWordIndex] : nil {
                Text(currentWord.original)
                    .font(.largeTitle)
                    .padding()
                
                Text(currentWord.translation)
                    .font(.title2)
                    .foregroundColor(.secondary)
            } else {
                Text("Немає слів для відтворення")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 40) {
                Button(action: viewModel.previousWord) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                }
                .disabled(viewModel.currentWordIndex == 0 || viewModel.words.isEmpty)
                
                Button(action: viewModel.togglePlayback) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                }
                .disabled(viewModel.words.isEmpty)
                
                Button(action: viewModel.nextWord) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                }
                .disabled(viewModel.currentWordIndex >= viewModel.words.count - 1 || viewModel.words.isEmpty)
            }
            .padding()
            
            VStack {
                HStack {
                    Text("Швидкість: \(String(format: "%.1f", viewModel.playbackSpeed))x")
                    Slider(value: $viewModel.playbackSpeed, in: 0.5...2.0, step: 0.1)
                }
                
                Toggle("Перемішати", isOn: Binding(
                    get: { viewModel.isShuffled },
                    set: { newValue in
                        viewModel.isShuffled = newValue
                        if newValue {
                            viewModel.shuffleWords()
                        }
                    }
                ))
                
                Button("Позначити як вивчене") {
                    viewModel.markCurrentWordAsLearned()
                    if viewModel.words.isEmpty {
                        dismiss()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.words.isEmpty)
            }
            .padding()
        }
        .padding()
        .navigationTitle("Програвач")
        .onDisappear {
            viewModel.stopPlaying()
        }
    }
} 