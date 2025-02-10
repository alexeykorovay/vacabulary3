import SwiftUI
import SwiftData

struct FolderDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var folder: Folder
    @StateObject private var speechService = SpeechService()
    
    @State private var showingAddWord = false
    @State private var newWordOriginal = ""
    @State private var newWordTranslation = ""
    @State private var isPlayingAll = false
    @State private var currentPlayingIndex = 0
    @State private var showLearnedWords = false
    
    var sortedWords: [Word] {
        let words = folder.words.sorted { $0.order < $1.order }
        return showLearnedWords ? words : words.filter { !$0.isLearned }
    }
    
    var body: some View {
        List {
            if !sortedWords.isEmpty {
                Section {
                    Button {
                        playAllWords()
                    } label: {
                        HStack {
                            Image(systemName: isPlayingAll ? "pause.circle.fill" : "play.circle.fill")
                                .font(.title2)
                            Text(isPlayingAll ? "Зупинити" : "Відтворити всі")
                            Spacer()
                            Text("\(currentPlayingIndex + 1)/\(sortedWords.count)")
                                .foregroundColor(.secondary)
                                .opacity(isPlayingAll ? 1 : 0)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            
            ForEach(sortedWords) { word in
                HStack {
                    VStack(alignment: .leading) {
                        Text(word.original)
                            .font(.headline)
                        Text(word.translation)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button {
                            speechService.speakWordWithTranslation(word: word, speed: 1.0)
                        } label: {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        Button {
                            withAnimation {
                                word.isLearned.toggle()
                            }
                        } label: {
                            Image(systemName: word.isLearned ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(word.isLearned ? .green : .gray)
                        }
                    }
                }
                .background(
                    currentPlayingIndex < sortedWords.count && 
                    sortedWords[currentPlayingIndex].id == word.id && 
                    isPlayingAll ? Color.blue.opacity(0.1) : Color.clear
                )
            }
            .onDelete(perform: deleteWords)
        }
        .navigationTitle(folder.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddWord = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    withAnimation {
                        showLearnedWords.toggle()
                    }
                } label: {
                    Image(systemName: showLearnedWords ? "eye.slash" : "eye")
                }
            }
        }
        .sheet(isPresented: $showingAddWord) {
            NavigationStack {
                Form {
                    TextField("Слово", text: $newWordOriginal)
                    TextField("Переклад", text: $newWordTranslation)
                }
                .navigationTitle("Нове слово")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Скасувати") {
                            showingAddWord = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Додати") {
                            addWord()
                        }
                        .disabled(newWordOriginal.isEmpty || newWordTranslation.isEmpty)
                    }
                }
            }
            .presentationDetents([.height(200)])
        }
        .onDisappear {
            stopPlayingAll()
        }
    }
    
    private func playAllWords() {
        if isPlayingAll {
            stopPlayingAll()
        } else {
            isPlayingAll = true
            currentPlayingIndex = 0
            playNextWord()
        }
    }
    
    private func playNextWord() {
        guard isPlayingAll, currentPlayingIndex < sortedWords.count else {
            stopPlayingAll()
            return
        }
        
        let word = sortedWords[currentPlayingIndex]
        speechService.speakWordWithTranslation(word: word, speed: 1.0)
        
        // 4 секунди = 1с (оригінал) + 1с (пауза) + 1с (переклад) + 1с (пауза перед наступним словом)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            currentPlayingIndex += 1
            playNextWord()
        }
    }
    
    private func stopPlayingAll() {
        isPlayingAll = false
        currentPlayingIndex = 0
        speechService.stopSpeaking()
    }
    
    private func addWord() {
        let word = Word(original: newWordOriginal, translation: newWordTranslation)
        word.order = folder.words.count
        modelContext.insert(word)
        folder.words.append(word)
        
        newWordOriginal = ""
        newWordTranslation = ""
        showingAddWord = false
    }
    
    private func deleteWords(at offsets: IndexSet) {
        for index in offsets {
            let word = sortedWords[index]
            if let wordIndex = folder.words.firstIndex(where: { $0.id == word.id }) {
                folder.words.remove(at: wordIndex)
                modelContext.delete(word)
            }
        }
    }
} 