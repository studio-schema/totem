//
//  OnboardingView.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var animateContent = false

    private let totalPages = 4

    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)

                    WhyTotemPage()
                        .tag(1)

                    FeaturesPage()
                        .tag(2)

                    GetStartedPage(onComplete: completeOnboarding)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                // Bottom controls
                VStack(spacing: 20) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    // Navigation buttons
                    HStack {
                        if currentPage > 0 {
                            Button("Back") {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                            .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()

                        if currentPage < totalPages - 1 {
                            Button {
                                withAnimation {
                                    currentPage += 1
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Next")
                                    Image(systemName: "arrow.right")
                                }
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(.white.opacity(0.2))
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
        }
    }

    private var backgroundGradient: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ],
            colors: [
                .indigo, .purple, .indigo,
                .purple, .pink.opacity(0.8), .orange,
                .indigo, .purple, .pink
            ]
        )
    }

    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    @State private var animate = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Animated sun icon
            ZStack {
                // Glow effect
                Circle()
                    .fill(.yellow.opacity(0.3))
                    .frame(width: 160, height: 160)
                    .blur(radius: 30)
                    .scaleEffect(animate ? 1.2 : 1.0)

                Image(systemName: "sun.max.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.yellow)
                    .rotationEffect(.degrees(animate ? 10 : -10))
            }
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)

            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))

                Text("Totem")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Good news. Daily.")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.9))
            }

            Spacer()

            // Problem statement
            VStack(spacing: 12) {
                Text("The news is broken.")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Bad news dominates because fear gets clicks.\nBut good news exists—you're just not seeing it.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .onAppear { animate = true }
    }
}

// MARK: - Why Totem Page
struct WhyTotemPage: View {
    @State private var animate = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Totem icon representation
            VStack(spacing: 0) {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white.opacity(0.15 + Double(index) * 0.15))
                        .frame(width: CGFloat(100 - index * 10), height: 40)
                        .overlay(
                            Image(systemName: symbolForIndex(index))
                                .foregroundStyle(.white)
                        )
                        .offset(y: animate ? 0 : CGFloat(index * 10))
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7)
                                .delay(Double(index) * 0.1),
                            value: animate
                        )
                }
            }
            .padding(.bottom, 20)

            VStack(spacing: 16) {
                Text("Why \"Totem\"?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 20) {
                    WhyPoint(
                        icon: "person.3.fill",
                        title: "Collective Symbol",
                        description: "Each positive story becomes a symbol on our shared digital totem—a record of humanity's goodness."
                    )

                    WhyPoint(
                        icon: "arrow.up.circle.fill",
                        title: "Rising Energy",
                        description: "Like totem poles that grow upward, every story lifts you higher. Every day brings more reasons to believe."
                    )

                    WhyPoint(
                        icon: "sparkles",
                        title: "Ancient Wisdom, Modern Need",
                        description: "For thousands of years, totems reminded communities of their values. In an age of doom-scrolling, we need that reminder more than ever."
                    )
                }
                .padding(.horizontal, 24)
            }

            Spacer()
        }
        .onAppear { animate = true }
    }

    private func symbolForIndex(_ index: Int) -> String {
        switch index {
        case 0: return "heart.fill"
        case 1: return "star.fill"
        case 2: return "leaf.fill"
        case 3: return "sun.max.fill"
        default: return "circle.fill"
        }
    }
}

struct WhyPoint: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.yellow)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineSpacing(2)
            }
        }
    }
}

// MARK: - Features Page
struct FeaturesPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("What You'll Find")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            VStack(spacing: 16) {
                FeatureRow(
                    icon: "sun.max.fill",
                    iconColor: .yellow,
                    title: "Curated Positivity",
                    description: "Hand-selected stories from trusted sources. No clickbait. No agenda."
                )

                FeatureRow(
                    icon: "sparkles",
                    iconColor: .mint,
                    title: "AI-Verified Uplifting",
                    description: "Every story passes our positivity filter to ensure genuinely good news."
                )

                FeatureRow(
                    icon: "square.stack.fill",
                    iconColor: .orange,
                    title: "8 Categories",
                    description: "From inspiring stories to science breakthroughs, find news that matters to you."
                )

                FeatureRow(
                    icon: "bookmark.fill",
                    iconColor: .pink,
                    title: "Save & Revisit",
                    description: "Build your personal collection of stories that moved you."
                )

                FeatureRow(
                    icon: "safari.fill",
                    iconColor: .blue,
                    title: "Read Full Articles",
                    description: "Tap any story to read the complete article from the original source."
                )
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()
        }
    }
}

// MARK: - Get Started Page
struct GetStartedPage: View {
    let onComplete: () -> Void
    @State private var animate = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Rising sun animation
            ZStack {
                // Rays
                ForEach(0..<8, id: \.self) { index in
                    Rectangle()
                        .fill(.yellow.opacity(0.3))
                        .frame(width: 4, height: animate ? 60 : 30)
                        .offset(y: -80)
                        .rotationEffect(.degrees(Double(index) * 45))
                        .animation(
                            .easeInOut(duration: 1)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.1),
                            value: animate
                        )
                }

                Circle()
                    .fill(.yellow)
                    .frame(width: 100, height: 100)

                Image(systemName: "face.smiling.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.orange)
            }

            VStack(spacing: 16) {
                Text("Ready to Feel Better?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Join thousands who replaced\ndoom-scrolling with hope-scrolling.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()

            // Origin story quote
            VStack(spacing: 12) {
                Text("\"")
                    .font(.system(size: 60, weight: .bold, design: .serif))
                    .foregroundStyle(.white.opacity(0.3))
                    .offset(y: 20)

                Text("Good news exists. It just wasn't reaching me. Totem was born to change that.")
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 40)

            Spacer()

            // Get Started button
            Button(action: onComplete) {
                HStack(spacing: 8) {
                    Text("Start Reading Good News")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.indigo)
                .padding(.horizontal, 32)
                .padding(.vertical, 18)
                .background(.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            }
            .padding(.bottom, 20)
        }
        .onAppear { animate = true }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
