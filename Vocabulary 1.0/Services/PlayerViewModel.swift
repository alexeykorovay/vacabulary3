import SwiftUI
import AVFoundation

class PlayerViewModel: ObservableObject {
    private let speechService = SpeechService()
    
    @Published var currentWordIndex = 0
    @Published var isPlaying = false
    @Published var playbackSpeed: Double = 1.0
    @Published var isShuffled = false
    @Published var words: [Word] = []
    
    init(folders: [Folder]) {
        words = folders.flatMap { folder in
            folder.words.filter { !$0.isLearned }
        }
    }
    
    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            playCurrentWord()
        }
    }
    
    func nextWord() {
        if currentWordIndex < words.count - 1 {
            currentWordIndex += 1
            if isPlaying {
                playCurrentWord()
            }
        } else {
            isPlaying = false
        }
    }
    
    func previousWord() {
        if currentWordIndex > 0 {
            currentWordIndex -= 1
            if isPlaying {
                playCurrentWord()
            }
        }
    }
    
    func playCurrentWord() {
        guard words.indices.contains(currentWordIndex) else { return }
        
        let word = words[currentWordIndex]
        speechService.speakWordWithTranslation(word: word, speed: playbackSpeed)
        
        let delay = (2.0 / playbackSpeed)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self, self.isPlaying else { return }
            self.nextWord()
        }
    }
    
    func shuffleWords() {
        words.shuffle()
        currentWordIndex = 0
    }
    
    func markCurrentWordAsLearned() {
        guard words.indices.contains(currentWordIndex) else { return }
        
        words[currentWordIndex].isLearned = true
        words.remove(at: currentWordIndex)
        
        if currentWordIndex >= words.count {
            currentWordIndex = max(0, words.count - 1)
        }
    }
    
    func stopPlaying() {
        isPlaying = false
        speechService.stopSpeaking()
    }
} 