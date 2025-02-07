class WordPlayer: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentWord: Word?
    @Published var playbackSpeed: Float = 1.0
    @Published var isShuffled: Bool = false
    
    private var words: [Word] = []
    private var currentIndex: Int = 0
    
    func setWords(from folders: [Folder], shuffled: Bool = false) {
        words = folders.flatMap { $0.words }
            .filter { !$0.isLearned }
        
        if shuffled {
            words.shuffle()
        } else {
            words.sort { $0.order < $1.order }
        }
    }
    
    func play() {
        isPlaying = true
        playNext()
    }
    
    func pause() {
        isPlaying = false
    }
    
    private func playNext() {
        guard currentIndex < words.count else {
            isPlaying = false
            return
        }
        
        currentWord = words[currentIndex]
        currentIndex += 1
    }
    
    func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = speed
    }
} 