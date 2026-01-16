//
//  SettingsView.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("refreshInterval") private var refreshInterval = 30

    var body: some View {
        NavigationStack {
            List {
                // About Section
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.yellow.gradient)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Totem")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Positive News for a Better Day")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Preferences Section
                Section("Preferences") {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)

                    Picker("Refresh Interval", selection: $refreshInterval) {
                        Text("15 minutes").tag(15)
                        Text("30 minutes").tag(30)
                        Text("1 hour").tag(60)
                        Text("Manual only").tag(0)
                    }
                }

                // Sources Section
                Section("News Sources") {
                    ForEach(NewsSource.defaultSources) { source in
                        HStack {
                            Image(systemName: source.icon)
                                .foregroundStyle(source.defaultCategory.primaryColor)
                                .frame(width: 24)

                            Text(source.name)

                            Spacer()

                            Image(systemName: "checkmark")
                                .foregroundStyle(.green)
                        }
                    }
                }

                // App Info Section
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "1")

                    Link(destination: URL(string: "https://github.com/studio-schema/totem")!) {
                        HStack {
                            Text("GitHub Repository")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }

                    Link(destination: URL(string: "https://www.goodnewsnetwork.org")!) {
                        HStack {
                            Text("Good News Network")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                }

                // Credits Section
                Section {
                    VStack(spacing: 8) {
                        Text("Made with positivity")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Totem aggregates uplifting news from trusted positive news sources and uses AI to verify content positivity.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
}
