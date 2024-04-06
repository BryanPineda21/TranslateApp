//
//  ContentView.swift
//  Translate
//
//  Created by Bryan Pineda on 4/5/24.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    
    @Environment(AuthManager.self) var authManager
    
    @State private var inputText: String = ""
    @State private var translatedText: String = ""
    @State private var selectedLanguage: Language? // Selected language model
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter text to translate", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .navigationBarTitle("TranslationMe")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem {
                            Button("Sign out") {
                                authManager.signOut()
                            }
                        }
                    }
                
                Section(header: Text("Select Language")) {
                    Picker(selection: $selectedLanguage, label: Text("Select Language")) {
                        ForEach(supportedLanguages, id: \.code) { language in
                            Text(language.name)
                                .tag(language as Language?)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                }
                
                Button(action: translateText) {
                    Text("Translate")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                // Display translated text
                VStack(spacing: 20) {
                    Text("Translated Text")
                        .font(.title)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(height: 100)
                        .padding()
                        .overlay(
                            Text(translatedText)
                                .padding()
                                .multilineTextAlignment(.center)
                                .foregroundColor(.blue)
                        )
                }
                .padding()
                
                Spacer()
                
                // NavigationLink to TranslationHistoryView
                NavigationLink(destination: TranslationHistoryView()) {
                    Text("View Translation History")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .padding()
        }
    }
    
    func translateText() {
        guard !inputText.isEmpty, let targetLanguage = selectedLanguage else {
            return // Don't translate if input text is empty or no language is selected
        }
        
        isLoading = true
        
        let urlString = "https://api.mymemory.translated.net/get?q=\(inputText)&langpair=en|\(targetLanguage.code)"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                isLoading = false
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let translationResponse = try decoder.decode(TranslationResponse.self, from: data)
                
                DispatchQueue.main.async {
                    translatedText = translationResponse.responseData.translatedText
                    
                    // Store translation data in Firestore
                    let db = Firestore.firestore()
                    db.collection("translations").addDocument(data: [
                        "originalText": inputText,
                        "translatedText": translatedText,
                        "targetLanguage": targetLanguage.code, // Store target language code
                        "timestamp": Timestamp()
                    ]) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("Translation added to Firestore!")
                        }
                    }
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
