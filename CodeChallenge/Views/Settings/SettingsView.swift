//
//  SettingsView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 21/08/2022.
//

import Foundation
import SwiftUI

struct SettingsView: View, SettingsViewProps {
    @EnvironmentObject var store: Store
    let onNotificationsTap: () -> Void
    let onOpenUrl: (String) -> Void
    let onLogout: () -> Void
    @State private var showsLogoutAlert = false
    @State private var showsAlert = false
    @State private var isLogoutAlert = false
    @State private var displayUserExists = false

    var body: some View {
        DoodledView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    HStack {
                        Text("Settings")
                            .font(.pageNameH1)
                            .padding(.bottom, 10)
                        Spacer()
                    }

                                            buttonsView

                                            Spacer()

                    Text("App version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                        .font(.bodyText)
                        .foregroundColor(UIColor.lightGray)
                }
                .foregroundColor(.CodeChallenge.white)
            }
            .padding(.horizontal, 27)
        }
        .alert(isPresented: $showsAlert) {
            Alert(
                title: Text(isLogoutAlert ? "Are you sure you want to logout?" : "Are you sure you want to delete your account?"),
                message: Text(isLogoutAlert ? "" : "All account history and completed challenges will be deleted, and all your devices will be logged out. There won't be a way to recover your account in the future."),
                primaryButton: .destructive(Text("Yes")) {
                    store.dispatch(isLogoutAlert ? Logout() : DeleteAccount())
                },
                secondaryButton: .cancel()
            )
        }
        .onChange(of: userExists) { newValue in
            if !userExists && displayUserExists {
                onLogout()
            }
            displayUserExists = userExists
        }
        .onAppear {
            displayUserExists = userExists
        }
    }

    var buttonsView: some View {
        VStack(alignment: .leading, spacing: 30) {
            Button("Privacy Policy") {
                onOpenUrl("https://codehub.ninja/privacy/")
            }

            Button("Terms of Use") {
                onOpenUrl("https://codehub.ninja/privacy/")
            }

            Button("Notifications") {
                onNotificationsTap()
            }

            Button("Feedback") {
                onOpenUrl("https://www.surveymonkey.com/r/L9YR78L")
            }

            Button("Join Us") {
                onOpenUrl("https://discord.gg/xNZMEVvV")
            }

            if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
                Button("Delete Account") {
                    isLogoutAlert = false
                    showsAlert = true
                }

                Button("Log out") {
                    isLogoutAlert = true
                    showsAlert = true
                }
            }
        }
        .font(.h4)
    }
}
