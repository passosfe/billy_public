//
//  CreateCategoryLimitView.swift
//  Billy
//
//  Created by Felipe Passos on 09/12/20.
//

import SwiftUI

struct CreateCategoryLimitView: View {
    @ObservedObject var viewModel: CreateCategoryLimitViewModel
    @State private var isCategoriesExpanded = false
    @State private var showNumberPad = true
    
    var ammount: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(NumberFormatter.currencyFormatter.string(for: viewModel.maxMonthlyAvailableValue)!)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        self.showNumberPad = true
                        if isCategoriesExpanded {
                            isCategoriesExpanded.toggle()
                        }
                    }
                }
                .font(Font.system(size: 50, weight: .light))
                .multilineTextAlignment(.leading)
                .padding(.leading)
                .foregroundColor(.fintechGreen)
        }
        .padding()
    }
    
    var categoriesDropdown: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isCategoriesExpanded {
                Text(Strings.category.toLocalizedString)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding([.leading, .top])
                    .padding(.top)
                    .foregroundColor(.secondary)
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                        ForEach(viewModel.categoryTypes, id: \.self) { categoryType in
                            VStack {
                                Text(categoryType.icon)
                                Text(categoryType.toLocalizedString)
                                    .font(.footnote)
                                    .bold()
                            }
                            .foregroundColor(.fintechGreen)
                            .padding(.vertical)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.category = categoryType
                                withAnimation {
                                    isCategoriesExpanded.toggle()
                                }
                            }
                        }
                    }.padding()
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Text(Strings.category.toLocalizedString)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding([.leading, .bottom])
                        .foregroundColor(.secondary)
                    HStack {
                        Text(viewModel.category?.icon ?? StandardCategory.bills.icon)
                            .padding(.leading)
                            .frame(width: 50)
                        Text(viewModel.category?.toLocalizedString ?? StandardCategory.bills.toLocalizedString)
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                }
                .foregroundColor(.fintechGreen)
                .padding(.vertical)
                .contentShape(Rectangle())
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.125)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        isCategoriesExpanded.toggle()
                        if showNumberPad {
                            showNumberPad.toggle()
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .cardify(background: .clearerCardBackground2)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.75)
        .offset(y: (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!)
    }
    
    var submitButtonContainer: some View {
        VStack {
            Button(action: {
                viewModel.send(action: .saveCategoryLimit)
            }, label: {
                HStack {
                    Spacer(minLength: 0)
                    Text(viewModel.buttonText)
                    Spacer(minLength: 0)
                }
            })
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxHeight: 40)
            .padding(.vertical)
            .padding(.horizontal)
            .padding(.horizontal)
        }
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .cardify()
        .frame(width: UIScreen.main.bounds.width)
        .fixedSize(horizontal: false, vertical: true)
        .offset(y: (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!)
    }
    
    var mainContentView: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { _ in
                VStack {
                    Spacer()
                    ammount
                        .padding(.bottom, (UIScreen.main.bounds.height * 0.75) - 35)
                }
            }
            
            categoriesDropdown
            
            NumberPadView(show: self.$showNumberPad, txt: Binding<String>(
                get: { () -> String in
                    return NumberFormatter.currencyFormatter.string(for: viewModel.maxMonthlyAvailableValue)!
                }) { (s) in
                    var s = s
                    s.removeAll { (c) -> Bool in
                        !c.isNumber
                    }
                viewModel.maxMonthlyAvailable = s
            })
            .offset(y: self.showNumberPad ? (UIApplication.shared.windows.first?.safeAreaInsets.bottom)! - 40 : UIScreen.main.bounds.height - 40)
            
            submitButtonContainer
        }
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ZStack {
                    Color.appBackground.edgesIgnoringSafeArea(.all)
                    ProgressView()
                }
            } else {
                mainContentView
            }
        }.alert(isPresented: Binding<Bool>.constant($viewModel.error.wrappedValue != nil), content: { () -> Alert in
            Alert(title: Text("Error!"),
                  message: Text($viewModel.error.wrappedValue?.localizedDescription ?? ""),
                  dismissButton: .default(Text("OK"), action: {
                    viewModel.error = nil
                  }))
        })
        .accentColor(.fintechGreen)
        .background(Color.appBackground.edgesIgnoringSafeArea(.all)).dismissKeyboardOnTap()
    }
}

