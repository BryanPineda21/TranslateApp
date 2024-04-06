//
//  TranslateApp.swift
//  Translate
//
//  Created by Bryan Pineda on 4/5/24.
//

import SwiftUI
import FirebaseCore


@main
struct TranslateApp: App {
    @State private var authManager: AuthManager // <-- Create a state managed authManager property

    
    init()
    {
        FirebaseApp.configure()
        authManager = AuthManager() // <-- Initialize the authManager property (needs to be done after FirebaseApp.configure())

    }
    
    var body: some Scene {
        WindowGroup {
            
            if authManager.user != nil { // <-- Check if you have a non-nil user (means there is a logged in user)

                    // We have a logged in user, go to ChatView
                    
                ContentView()// <-- Add ChatView
                            .environment(authManager)
                    
                } else {

                    // No logged in user, go to LoginView
                    LoginView()
                        .environment(authManager)
                }
            }
    }
}
