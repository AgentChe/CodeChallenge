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
    let onOpenCompletedChallenges: () -> Void
    @State private var showingImagePicker = false
    @State private var showingRequestPhotoAccess = false
    @GestureState var press = false
    @State private var inputImage: UIImage?
    private let photos = PHPhotoLibrary.authorizationStatus()

    var body: some View {
        content
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
        .onAppear {
            self.store.objectWillChange.send()
        }
    }

    @ViewBuilder
    private var content: some View {
        if account?.isPremium == true {
            ZStack {
                VStack(spacing: 0) {
                    ZStack {
                        HStack {
                            Image("account_premium_doodle")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200)
                            Spacer()
                        }
                    }
                    .frame(width: .screenWidth, height: .navbarBackgroundHeight, alignment: .center)
                    .clipped()
                    .background(.CodeChallenge.dark)
                    Spacer()
                }
                .edgesIgnoringSafeArea(.top)
                .padding(.top, -50)
                .background(.CodeChallenge.dark)

                if isLoading {
                    SkeletonAccountView()
                } else if let account = account {
                    content(account: account)
                }
            }
        } else {
            DoodledView {
                if isLoading {
                    SkeletonAccountView()
                } else if let account = account {
                    content(account: account)
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
                    if account.isPremium == true {
                        LottieView(lottieFile: "account_premium_stars")
                            .frame(width: .screenWidth, height: 160)
                        Image("premium_image_background")
                            .resizable()
                            .frame(width: 140, height: 140)
                    }
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
                                .frame(width: UIScreen.main.bounds.width/2 + 20)
                            if account.isPremium == true {
                                AccountPremiumXPView(xpText: "\(account.xp ?? 0)")
                            } else {
                                XPView(xpText: "\(account.xp ?? 0)", backgroundColor: .CodeChallenge.dark, xpIconColor: "white", strokeColor: .CodeChallenge.blue1)
                            }
                            Spacer()
                        }
                        Spacer()
                            .frame(height: account.isPremium == true ? 26 : 4)
                    }
                }
                .frame(height: 120)
                Text(account.name ?? "")
                    .foregroundColor(.white)
                    .font(.h3)
                    .padding(.top, -20)
                Text(account.username != nil ? "@\(account.username ?? "")" : "My Profile")
                    .foregroundColor(.white)
                    .font(.h3)
                Text("\(account.solvedChallenges ?? 0) challenge\(account.solvedChallenges == 1 ? "" : "s")")
                .font(.regular(size: 14))
                .foregroundColor(.CodeChallenge.purple)
                .onTapGesture {
                    onOpenCompletedChallenges()
                }

                if UserDefaults.standard.bool(forKey: "isLoggedIn") == false {
                    Button("Sign in") {
                        onLogin()
                    }
                    .buttonStyle(PrimaryButton())
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                }

                Spacer()
                    .frame(height: 1)
                
                if account.isPremium == true {
                    streakView(account: account)
                        .modifier(PremiumGradientModifier(changeStrokeColor: true, cornerRadius: 10))
                        .padding(.horizontal, UIDevice.hasSmallScreen ? 10 : 20)
                } else {
                    streakView(account: account)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.CodeChallenge.dustyBlue), lineWidth: 1.5)
                        }
                        .padding(.horizontal, UIDevice.hasSmallScreen ? 10 : 20)
                }

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
        VStack(alignment: .leading, spacing: 16) {
            Text("Continue Your in Progress Challenges")
                .padding(.bottom, 5)
                .foregroundColor(.white)
                .font(.bodyText)

            ForEach(inProgressChallenges, id: \.id) { challenge in
                UniversalCodeChallengeView(codeChallenge: challenge)
                    .onTapGesture {
                        self.onOpenChallengeDetails(challenge)
                        store.dispatch(TrackAnalyticsEvent(event: .challengeSelected(challenge, "Profile", store.state.programmingLanguage)))
                    }
            }
        }
    }

    private func streakView(account: Account) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("You're on a ")
                    .foregroundColor(UIColor.lightGray)
                    .font(.regular(size: 18))
                Text("\(account.streak ?? 0)-Day Streak")
                    .foregroundColor(.white)
                    .font(.bold(size: 18))
                Spacer()
            }
                .padding(.bottom, 15)
            HStack(alignment: .center, spacing: (.screenWidth - (UIDevice.hasSmallScreen ? 44 : 70)) / 7 - 30) {
                ForEach(account.streaktoKeyValueTuple(from: account.streak ?? 0), id: \.self) { item in
                    ZStack {
                        if item.value {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(account.isPremium == true ? .CodeChallenge.purple : .CodeChallenge.blue1))
                                .frame(width: 32, height: 32)
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(account.isPremium == true ? .CodeChallenge.purple : .CodeChallenge.blue1), lineWidth: 1)
                                .frame(width: 32, height: 32)
                        }

                        Text(item.key)
                            .foregroundColor(item.value ? .CodeChallenge.white : (account.isPremium == true ? .CodeChallenge.purple : .CodeChallenge.blue1))
                            .font(.regular(size: 16))
                    }
                }
            }
        }
        .padding(UIDevice.hasSmallScreen ? 12 : 15)
        .foregroundColor(.white)
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
                .font(.systemFont(ofSize: 24, weight: .semibold))

            Text("My Challenges")
            .font(.systemFont(ofSize: 14, weight: .semibold))
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
