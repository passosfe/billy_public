//
//  CategoriesBoxView.swift
//  Billy
//
//  Created by Felipe Passos on 10/11/20.
//

import SwiftUI

struct CategoriesPageView: View {
    @ObservedObject private(set) var categoriesListViewModel: CategoriesListViewModel
    @EnvironmentObject var settings: UserSettings
    private(set) var availableCategories: [StandardCategory]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground.edgesIgnoringSafeArea(.all)
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: categoriesListViewModel.itemViewModels.count > 0 ? columns : [.init(.flexible())]) {
                        CategoriesListView(viewModel: categoriesListViewModel, bigItems: true)
                    }
                    .padding(.vertical)
                    .padding(.bottom)
                }
            }.navigationBarTitle(Strings.categories.toLocalizedString)
        }
        .sheet(isPresented: $categoriesListViewModel.showingEdit) {
            CreateCategoryLimitView(viewModel: .init(budgetId: settings.mainBudgetId!, availableCategories: availableCategories, isShowing: $categoriesListViewModel.showingEdit, editCategoryLimit: categoriesListViewModel.categoryToEdit))
        }
    }
}

struct CategoriesBoxView: View {
    private(set) var categoriesListViewModel: CategoriesListViewModel
    
    @ViewBuilder
    private func content() -> some View {
        if categoriesListViewModel.itemViewModels.count > 0 {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: itemsHorizontalSpacing) {
                    CategoriesListView(viewModel: categoriesListViewModel)
                }
                .padding(.vertical, itemsVerticalPadding)
                .padding(.horizontal, itemsHorizontalSpacing)
            }
        } else {
            CategoriesListView(viewModel: categoriesListViewModel)
        }
    }
    
    var body: some View {
        content()
    }
    
    // MARK: - Drawing Constants
    
    private let itemsHorizontalSpacing: CGFloat = 20.0
    private let itemsVerticalPadding: CGFloat = 30.0
}

struct CategoriesListView: View {
    private(set) var viewModel: CategoriesListViewModel
    private(set) var bigItems: Bool = false
    
    @ViewBuilder
    func categoryItems() -> some View {
        if bigItems {
            ForEach(viewModel.itemViewModels) { itemViewModel in
                CategoryItemView(viewModel: itemViewModel, bigItem: bigItems)
                    .padding()
                    .cardify()
                    .onTapGesture {
                        self.viewModel.send(action: .editLimit, itemViewModel: itemViewModel)
                    }
                    .padding()
            }
        } else {
            ForEach(viewModel.itemViewModels.prefix(5)) { itemViewModel in
                CategoryItemView(viewModel: itemViewModel)
                    .padding()
                    .cardify()
                    .onTapGesture {
                        self.viewModel.send(action: .editLimit, itemViewModel: itemViewModel)
                    }
            }
        }
    }
        
    var noItemsToShowView: some View {
        Text(Strings.defineYourLimits.toLocalizedString)
            .font(.callout)
            .foregroundColor(.secondary)
            .padding(.vertical, itemsVerticalPadding * 2)
            .padding(.horizontal, itemsHorizontalSpacing)
    }
    
    @ViewBuilder
    private func content() -> some View {
        if viewModel.itemViewModels.count > 0 {
            categoryItems()
        } else {
            noItemsToShowView
        }
    }
    
    var body: some View {
        content()
    }
    
    // MARK: - Drawing Constants
    
    private let itemsHorizontalSpacing: CGFloat = 20.0
    private let itemsVerticalPadding: CGFloat = 30.0
}

struct CategoryItemView: View {
    @ObservedObject private(set) var viewModel: CategoryItemViewModel
    private(set) var bigItem: Bool = false
    
    var body: some View {
        VStack {
            ProgressCircleView(viewModel: viewModel.progressCircleViewModel)
            Text(viewModel.title())
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            if bigItem {
                VStack(spacing: spendingValuesSpacing) {
                    Text(NumberFormatter.currencyFormatter.string(for: Double(viewModel.category.currentSpent ?? 0) / 100)!)
                        .font(.callout)
                        .fontWeight(.bold)
                    Text("/ \(NumberFormatter.currencyFormatter.string(for: (Double(viewModel.category.maxAvailable) / 100))!)")
                        .font(.caption2)
                }
            }
        }
    }
    
    // MARK: -Drawing Constants
    
    private let spendingValuesSpacing: CGFloat = 2.0
}
