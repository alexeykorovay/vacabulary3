//
//  ContentView.swift
//  VocabularyApp3.0
//
//  Created by The Weeknd on 25.10.2024.
//

import SwiftUI
import AVFoundation

// Model для слова
struct Word: Identifiable, Codable {
    var id = UUID()
    var text: String
    var translation: String
}

// Model для папки
struct Folder: Identifiable, Codable {
    var id = UUID()
    var name: String
    var words: [Word] = []
}

// ViewModel для управління даними
class FolderViewModel: ObservableObject {
    @Published var folders: [Folder] = []
    
    init() {
        loadFolders()
    }
    
    func addFolder(name: String) {
        folders.append(Folder(name: name))
        saveFolders()
    }
    
    func deleteFolder(at offsets: IndexSet) {
        folders.remove(atOffsets: offsets)
        saveFolders()
    }
    
    func renameFolder(folder: Folder, newName: String) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index].name = newName
            saveFolders()
        }
    }
    
    func addWord(to folder: Folder, word: Word) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index].words.append(word)
            saveFolders()
        }
    }
    
    func editWord(in folder: Folder, word: Word, newText: String, newTranslation: String) {
        if let folderIndex = folders.firstIndex(where: { $0.id == folder.id }),
           let wordIndex = folders[folderIndex].words.firstIndex(where: { $0.id == word.id }) {
            folders[folderIndex].words[wordIndex].text = newText
            folders[folderIndex].words[wordIndex].translation = newTranslation
            saveFolders()
        }
    }
    
    func deleteWord(from folder: Folder, at offsets: IndexSet) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index].words.remove(atOffsets: offsets)
            saveFolders()
        }
    }
    
    private func saveFolders() {
        if let data = try? JSONEncoder().encode(folders) {
            UserDefaults.standard.set(data, forKey: "folders")
        }
    }
    
    private func loadFolders() {
        if let data = UserDefaults.standard.data(forKey: "folders"),
           let savedFolders = try? JSONDecoder().decode([Folder].self, from: data) {
            folders = savedFolders
        }
    }
}

// AudioPlayer для відтворення слів
class AudioPlayer: ObservableObject {
    private var synthesizer = AVSpeechSynthesizer()
    
    func play(text: String, rate: Float, delay: TimeInterval) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        synthesizer.speak(utterance)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

// FolderView для управління папками
struct FolderView: View {
    @ObservedObject var viewModel = FolderViewModel()
    @State private var newFolderName = ""
    @State private var isEditingFolder = false
    @State private var selectedFolder: Folder?
    @State private var newFolderTitle = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.folders) { folder in
                    NavigationLink(destination: WordView(folder: folder, viewModel: viewModel)) {
                        Text(folder.name)
                    }
                    .contextMenu {
                        Button("Edit Folder") {
                            isEditingFolder = true
                            selectedFolder = folder
                            newFolderTitle = folder.name
                        }
                        Button("Delete Folder") {
                            if let index = viewModel.folders.firstIndex(where: { $0.id == folder.id }) {
                                viewModel.deleteFolder(at: IndexSet(integer: index))
                            }
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteFolder)
            }
            .navigationBarTitle("Folders")
            .navigationBarItems(trailing: HStack {
                TextField("Folder Name", text: $newFolderName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add Folder") {
                    if !newFolderName.isEmpty {
                        viewModel.addFolder(name: newFolderName)
                        newFolderName = ""
                    }
                }
            })
            .sheet(isPresented: $isEditingFolder) {
                VStack {
                    TextField("Folder Name", text: $newFolderTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Save") {
                        if let selectedFolder = selectedFolder {
                            viewModel.renameFolder(folder: selectedFolder, newName: newFolderTitle)
                        }
                        isEditingFolder = false
                    }
                    .padding()
                }
            }
        }
    }
}

// WordView для управління словами в папці
struct WordView: View {
    @State var folder: Folder
    @ObservedObject var viewModel: FolderViewModel
    @State private var newWordText = ""
    @State private var newTranslation = ""
    @ObservedObject var player = AudioPlayer()
    @State private var playRate: Float = 0.5
    @State private var interval: TimeInterval = 1.0
    
    var body: some View {
        VStack {
            List {
                ForEach(folder.words) { word in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(word.text).font(.headline)
                            Text(word.translation).font(.subheadline)
                        }
                        Spacer()
                        Button("Play") {
                            player.play(text: word.text, rate: playRate, delay: interval)
                        }
                        .padding(.leading, 5)
                        .contextMenu {
                            Button("Edit Word") {
                                newWordText = word.text
                                newTranslation = word.translation
                                viewModel.editWord(in: folder, word: word, newText: newWordText, newTranslation: newTranslation)
                            }
                            Button("Delete Word") {
                                if let index = folder.words.firstIndex(where: { $0.id == word.id }) {
                                    viewModel.deleteWord(from: folder, at: IndexSet(integer: index))
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(folder.name)
            .onAppear {
                if let index = viewModel.folders.firstIndex(where: { $0.id == folder.id }) {
                    folder = viewModel.folders[index]
                }
            }
            
            VStack {
                TextField("New Word", text: $newWordText)
                TextField("Translation", text: $newTranslation)
                HStack {
                    Button("Add Word") {
                        if !newWordText.isEmpty && !newTranslation.isEmpty {
                            let newWord = Word(text: newWordText, translation: newTranslation)
                            viewModel.addWord(to: folder, word: newWord)
                            newWordText = ""
                            newTranslation = ""
                        }
                    }
                    .padding()
                }
            }.padding()
        }
    }
}

