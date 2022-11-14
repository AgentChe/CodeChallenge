//
//  AccountView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 17/06/2022.
//

import Foundation
import SwiftUI
import Photos

struct AccountView: View, AccountViewProps {
    @EnvironmentObject var store: Store
    let onLogin: () -> Void
    let onOpenSettings: () -> Void
    let onOpenChallengeDetails: (Challenge) -> Void
    @State var displayAccount: Account?
    @State var displayInProgressChallenges: [Challenge] = []
    @State private var showingImagePicker = false
    @State private var showingRequestPhotoAccess = false
    @GestureState var press = false
    @State private var inputImage: UIImage?
    private let photos = PHPhotoLibrary.authorizationStatus()

    var body: some View {
        DoodledView {
            if isLoading {
                SkeletonAccountView()
            } else if let account = displayAccount {
                content(account: account)
            }
        }
        .onChange(of: account) { newValue in
            displayAccount = newValue
        }
        .onAppear {
            displayAccount = account
            displayInProgressChallenges = inProgressChallenges
        }
        .onChange(of: inProgressChallenges) { newValue in
            displayInProgressChallenges = newValue
        }
        .onChange(of: inputImage) { _ in loadImage() }
        .onChange(of: showingRequestPhotoAccess) { _ in
            if photos == .notDetermined {
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized{
                        showingImagePicker = true
                    }
                })
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("settings").onTapGesture {
                    onOpenSettings()
                }
            }
        }
    }

    func loadImage() {
        guard let inputImage = inputImage, let data = inputImage.jpegData(compressionQuality: 0.2) else { return }
        store.dispatch(UploadImage(image: data))
    }

    private func content(account: Account) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                ZStack {
                    NetworkImage(
                        viewModel: .init(url: account.imageUrl,
                                         store: store,
                                         placeholder: .init(named: "placeholder_image"),
                                         showsPlaceholderInitially: true,
                                         cacheEnabled: false),
                        animated: false,
                        size: .init(width: 120, height: 120)
                    )
                        .cornerRadius(60)
                        .gesture(
                            LongPressGesture(minimumDuration: 1).onEnded { _ in
                                guard account.username != nil else { return }
                                if photos == .notDetermined {
                                    showingRequestPhotoAccess = true
                                } else {
                                    showingImagePicker = true
                                }
                            }
                        )
                    VStack {
                        Spacer()
                        HStack(spacing: 0) {
                            Spacer()
                                .frame(width: UIScreen.main.bounds.width/2 + 40)
                            XPView(xpText: "\(account.xp ?? 0)", backgroundColor: .CodeChallenge.dark, xpIconColor: "white", strokeColor: .CodeChallenge.blue1)
                            Spacer()
                        }
                        Spacer()
                            .frame(height: 4)
                    }
                }
                .frame(height: 120)
                Text(account.name ?? "")
                    .foregroundColor(.white)
                    .font(.boldSystemFont(ofSize: 25))
                    .padding(.top, -20)
                Text(account.username != nil ? "@\(account.username ?? "")" : "My Profile")
                    .foregroundColor(.white)
                    .font(.systemFont(ofSize: 24, weight: .bold))
//                HStack(spacing: 50) {
//                    VStack {
//                        Text("\(account.solvedChallenges ?? 0)")
//                            .font(.systemFont(ofSize: 18))
//                        Text("Challenges")
//                            .font(.systemFont(ofSize: 14))
//                    }
//                    VStack {
//                        Text("\(account.followersCount ?? 0)")
//                            .font(.systemFont(ofSize: 18))
//                        Text("Followers")
//                            .font(.systemFont(ofSize: 14))
//                    }
//                    VStack {
//                        Text("\(account.followingsCount ?? 0)")
//                            .font(.systemFont(ofSize: 18))
//                        Text("Following")
//                            .font(.systemFont(ofSize: 14))
//                    }
//                }
                Text("\(account.solvedChallenges ?? 0) challenge\(account.solvedChallenges == 1 ? "" : "s")")
                .font(.systemFont(ofSize: 16))
                .foregroundColor(.white)

                if UserDefaults.standard.bool(forKey: "isLoggedIn") == false {
                    Button("Sign in") {
                        onLogin()
                    }
                    .buttonStyle(PrimaryButton())
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                }
                
                streakView(account: account)
                    .padding(.top, 20)

                if !inProgressChallenges.isEmpty {
                    inProgressChallengesView
                        .padding(.vertical, 20)
                        .padding(.horizontal, UIDevice.hasSmallScreen ? 10 : 20)
                }
            }
        }
        .background(.clear)
    }

    private var inProgressChallengesView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Continue Your in Progress Challenges")
                .padding(.bottom, 5)
                .foregroundColor(.white)
                .font(.systemFont(ofSize: 14))

            ForEach(displayInProgressChallenges, id: \.id) { challenge in
                UniversalCodeChallengeView(codeChallenge: challenge)
                    .onTapGesture {
                        self.onOpenChallengeDetails(challenge)
                        store.dispatch(TrackAnalyticsEvent(event: .challengeSelected(challenge, nil, "Profile")))
                    }
            }
        }
    }

    private func streakView(account: Account) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.CodeChallenge.background))
            VStack(alignment: .leading, spacing: 0) {
                Text("You're on a")
                    .font(.systemFont(ofSize: 16))
                Text("\(account.streak ?? 0)-Day Streak")
                    .font(.boldSystemFont(ofSize: 30))
                    .padding(.bottom, 30)
                HStack(spacing: (.screenWidth - 50)/7 - 30) {
                    ForEach(account.streaktoKeyValueTuple(from: account.streak ?? 0), id: \.self) { item in
                        ZStack {
                            if item.value {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.CodeChallenge.blue1))
                                    .frame(width: 30, height: 30)
                            } else {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(.CodeChallenge.blue1), lineWidth: 1)
                                    .frame(width: 30, height: 30)
                            }

                            Text(item.key)
                                .foregroundColor(item.value ? .CodeChallenge.white : .CodeChallenge.blue1)
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
            .padding(UIDevice.hasSmallScreen ? 12 : 20)
            .foregroundColor(.white)
        }
        .padding(.horizontal, UIDevice.hasSmallScreen ? 10 : 20)
    }
}

struct SkeletonAccountView: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 60)
                .foregroundColor(.CodeChallenge.tabBar)
                .frame(width: 120, height: 120)

            Text("My Profile")
                .foregroundColor(.white)
                .font(.systemFont(ofSize: 24, weight: .bold))

            Text("My Challenges")
            .font(.systemFont(ofSize: 16))
            .foregroundColor(.white)
            .padding(.bottom, 20)

            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.CodeChallenge.background))
                .frame(height: 167)
                .padding(.horizontal, 25)

            Spacer()
        }
        .redacted(reason: .placeholder)
    }
}
