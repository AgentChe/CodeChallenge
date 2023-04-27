//
//  TryAIView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 15/03/2023.
//

import Foundation
import SwiftUI

//struct TryAIView: View {
//    @EnvironmentObject var store: Store
//    @Environment(\.presentationMode) var presentationMode
//    let onTryAI: (Challenge) -> Void
//    let goProductHunt: (String) -> Void
//
//    var challengeToSolve: Challenge? {
//        return store.state.recommendedChallenges.value?.filter { !$0.isPremium }.randomElement()
//    }
//
//    var body: some View {
//        DoodledView {
//            VStack(spacing: 0) {
//                HStack {
//                    Spacer()
//                        .frame(width: 16)
//                    Button {
//                        presentationMode.wrappedValue.dismiss()
//                    } label: {
//                        Image("back")
//                    }
//
//                    Spacer()
//                }
//                .padding(.top, 20)
//                VStack(spacing: UIDevice.hasSmallScreen ? 10 : 18) {
//                    Image("bear_logo")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .padding(.vertical, 10)
//                    Text("Introducing Codehub AI: Personalized Code Learning")
//                        .multilineTextAlignment(.center)
//                        .font(.bold(size: 24))
//                    Text("Boost your skills, conquer challenges, and learn like a pro.")
//                        .multilineTextAlignment(.center)
//
//                    VStack(alignment: .center, spacing: 20) {
//                        HStack(spacing: 12) {
//                            Image("try_ai_icon1")
//                                .resizable()
//                                .frame(width: 40, height: 40)
//                            VStack(alignment: .leading) {
//                                HStack(spacing: 12) {
//                                    Text("Explain My Mistake")
//                                        .font(.semibold(size: 17))
//                                        .multilineTextAlignment(.leading)
//                                    Image("new")
//                                }
//                                Text("Get AI Powered feedback on your code and understand mistakes better.")
//                                    .font(.regular(size: 14))
//                                    .multilineTextAlignment(.leading)
//                            }
//                            Spacer()
//                        }
//                        HStack(spacing: 12) {
//                            Image("try_ai_icon2")
//                                .resizable()
//                                .frame(width: 40, height: 40)
//                            VStack(alignment: .leading) {
//                                HStack(spacing: 12) {
//                                    Text("Ask AI")
//                                        .font(.semibold(size: 17))
//                                        .multilineTextAlignment(.leading)
//                                    Image("new")
//                                }
//                                Text("Enlist AI to decode coding challenges and guide your triumph.")
//                                    .multilineTextAlignment(.leading)
//                                    .font(.regular(size: 14))
//                            }
//                            Spacer()
//                        }
//                    }
//                    .padding(.vertical, 20)
//                    .padding(.horizontal, 16)
//                    .background {
//                        RoundedCornersShape(corners: [.topRight, .topLeft], radius: 16)
//                            .fill(Color(UIColor.CodeChallenge.background))
//                    }
//                }
//                .padding(.horizontal, 16)
//                VStack(spacing: 20) {
//                    if let productHunt = store.state.maintenance?.prdoductHunt {
//                        Image("product_hunt_banner")
//                            .resizable()
//                            .frame(width: .screenWidth - 50, height: 56)
//                            .aspectRatio(contentMode: .fit)
//                            .onTapGesture {
//                                goProductHunt(productHunt)
//                            }
//                    }
//                    Button("Try It Now") {
//                        presentationMode.wrappedValue.dismiss()
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            if let challengeToSolve = challengeToSolve {
//                                onTryAI(challengeToSolve)
//                            }
//                        }
//                    }
//                    .buttonStyle(PrimaryButton())
//                }
//                .padding(.horizontal, 25)
//                .padding(.top, 25)
//                .background(Color(UIColor(red: 0.064, green: 0.068, blue: 0.118, alpha: 1)))
//            }
//        }
//    }
//}
