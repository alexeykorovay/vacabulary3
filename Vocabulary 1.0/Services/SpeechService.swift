import AVFoundation

class SpeechService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(text: String, language: String = "en-US", rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate
        synthesizer.speak(utterance)
    }
    
    func speakWordWithTranslation(word: Word, speed: Double) {
        stopSpeaking()
        
        let originalUtterance = AVSpeechUtterance(string: word.original)
        originalUtterance.rate = Float(speed) * AVSpeechUtteranceDefaultSpeechRate
        originalUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let translationUtterance = AVSpeechUtterance(string: word.translation)
        translationUtterance.rate = Float(speed) * AVSpeechUtteranceDefaultSpeechRate
        translationUtterance.voice = AVSpeechSynthesisVoice(language: "uk-UA")
        
        originalUtterance.postUtteranceDelay = 1.0
        translationUtterance.postUtteranceDelay = 1.0
        
        synthesizer.speak(originalUtterance)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.synthesizer.speak(translationUtterance)
        }
    }
    
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
} 