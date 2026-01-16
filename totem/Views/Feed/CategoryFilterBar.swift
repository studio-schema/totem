//
//  CategoryFilterBar.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import SwiftUI

struct CategoryFilterBar: View {
    @Binding var selectedCategory: ArticleCategory
    var onCategoryChange: (ArticleCategory) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ArticleCategory.allCases) { category in
                    CategoryPill(
                        category: category,
                        isSelected: selectedCategory == category
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                        onCategoryChange(category)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct CategoryPill: View {
    let category: ArticleCategory
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.caption)

            Text(category.displayName)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            isSelected
                ? AnyShapeStyle(
                    LinearGradient(
                        colors: category.gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                : AnyShapeStyle(Color(.systemGray6))
        )
        .foregroundStyle(isSelected ? .white : .primary)
        .clipShape(Capsule())
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

#Preview {
    VStack {
        CategoryFilterBar(
            selectedCategory: .constant(.forYou),
            onCategoryChange: { _ in }
        )
    }
    .padding()
}
