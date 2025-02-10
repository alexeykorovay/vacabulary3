import SwiftUI

struct TranslatorView: View {
    @State private var sourceText = ""
    @State private var translatedText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Введіть текст для перекладу", text: $sourceText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(5)
                
                if !translatedText.isEmpty {
                    Text(translatedText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Перекладач")
            .onChange(of: sourceText) {
                // Тут буде логіка перекладу
                translatedText = "Переклад: \(sourceText)"
            }
        }
    }
} 