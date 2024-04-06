//
//  TranslationHistoryView.swift
//  Translate
//
//  Created by Bryan Pineda on 4/6/24.
//


import SwiftUI
import FirebaseFirestore

struct TranslationHistoryView: View {
    @State private var translationHistory: [String] = []

    var body: some View {
        VStack {
            List {
                ForEach(translationHistory, id: \.self) { translation in
                    HStack {
                        Text(translation)
                            .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            deleteTranslation(translation)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            Button("Clear All", action: clearAllTranslations)
                .foregroundColor(.red)
                .padding()
        }
        .onAppear {
            loadTranslationHistory() // Load translation history when view appears
        }
    }

    private func loadTranslationHistory() {
        let db = Firestore.firestore()
        db.collection("translations")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No documents")
                    return
                }

                translationHistory = documents.compactMap { document -> String? in
                    let data = document.data()
                    guard let translatedText = data["translatedText"] as? String else {
                        return nil
                    }
                    return translatedText
                }
            }
    }

    private func deleteTranslation(_ translation: String) {
        let db = Firestore.firestore()
        db.collection("translations")
            .whereField("translatedText", isEqualTo: translation)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("Translation not found")
                    return
                }

                for document in documents {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error removing translation: \(error)")
                        } else {
                            // Update the local translationHistory after deletion
                            translationHistory.removeAll(where: { $0 == translation })
                        }
                    }
                }
            }
    }

    private func clearAllTranslations() {
        let db = Firestore.firestore()
        db.collection("translations")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No documents to delete")
                    return
                }

                for document in documents {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error removing translation: \(error)")
                        }
                    }
                }

                // Clear local translationHistory after deleting all documents
                translationHistory.removeAll()
            }
    }
}

#Preview {
    TranslationHistoryView()
}
