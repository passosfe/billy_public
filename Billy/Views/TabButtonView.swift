//
//  TabButton.swift
//  Billy
//
//  Created by Felipe Passos on 08/11/20.
//

import SwiftUI

struct MainChartTabs: View {
    var tab: Binding<TabButton.TabButtonTitle>
    @Namespace var animation
    
    var body: some View {
        HStack(spacing: tabButtonSpacing) {
            TabButton(selected: tab, title: TabButton.TabButtonTitle.week, animation: animation)
            TabButton(selected: tab, title: TabButton.TabButtonTitle.month, animation: animation)
            TabButton(selected: tab, title: TabButton.TabButtonTitle.year, animation: animation)
        }
        .background(Color.secondary.opacity(tabButtonBackgroundOpacity))
        .clipShape(Capsule())
        .frame(height: tabButtonHeightFrame)
        .padding(.horizontal, tabButtonHorizontalPadding)
    }
    
    // MARK: - Drawing Constants
    
    private let tabButtonSpacing: CGFloat = 0
    private let tabButtonBackgroundOpacity: Double = 0.2
    private let tabButtonHeightFrame: CGFloat = 29.0
    private let tabButtonHorizontalPadding: CGFloat = 90.0
}

struct TabButton: View {
    @Binding var selected: TabButtonTitle
    @Environment(\.colorScheme) var colorScheme
    var title: TabButtonTitle
    var animation: Namespace.ID
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                selected = title
            }
        }) {
            
            ZStack {
                Capsule()
                    .fill(Color.clear)
                
                if selected == title {
                    Capsule()
                        .fill(colorScheme == .dark ? Color.gray : Color.white)
                        .frame(height: capsuleHeight)
                        .matchedGeometryEffect(id: "Tab", in: animation)
                        .padding(capsulePadding)
                }
                
                Text(title.getTitleName())
                    .foregroundColor(selected == title ? .primary : .secondary)
                    .fontWeight(selected == title ? .bold : .regular)
                    .font(.footnote)
            }
        }
    }
    
    // MARK: -Drawing Constants
    
    private let capsuleHeight: CGFloat = 25.0
    private let capsulePadding: CGFloat = 2.0
    
    enum TabButtonTitle {
        case week
        case month
        case year
        
        func getTitleName() -> String {
            switch self {
            case .week:
                return Strings.week.toLocalizedString
            case .month:
                return Strings.month.toLocalizedString
            case .year:
                return Strings.year.toLocalizedString
            }
        }
        
        func getTitleAdverb() -> String {
            switch self {
            case .week:
                return Strings.weekSpendings.toLocalizedString
            case .month:
                return Strings.monthSpendings.toLocalizedString
            case .year:
                return Strings.yearSpendings.toLocalizedString
            }
        }
    }
}
