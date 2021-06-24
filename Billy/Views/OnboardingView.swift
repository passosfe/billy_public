//
//  OnboardingView.swift
//  Billy
//
//  Created by Felipe Passos on 10/11/20.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel = OnboardingViewModel()
    @State private var isActive = false
    @State private var index = 0
    
    var skip: some View {
        Button (action: {
            if index < viewModel.onboardingItems.count - 1 {
                withAnimation(.easeInOut) {
                    index = viewModel.onboardingItems.count - 1
                }
            }
        }) {
            HStack(alignment: VerticalAlignment.center, spacing: nextButtonIconSpacing) {
                Text(Strings.skip.toLocalizedString)
                    .fontWeight(.semibold)
            }
        }.foregroundColor(.secondary)
    }
    
    var nextButton: some View {
        Button (action: {
            if index < viewModel.onboardingItems.count - 1 {
                withAnimation(.easeInOut) {
                    index += 1
                }
            } else {
                viewModel.send(action: .createFirstEmptyBudget)
            }
        }) {
            HStack(alignment: VerticalAlignment.center, spacing: nextButtonIconSpacing) {
                if index < viewModel.onboardingItems.count - 1 {
                    Text(Strings.next.toLocalizedString)
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.forward")
                        .font(.subheadline)
                } else {
                    Text(Strings.start.toLocalizedString)
                        .fontWeight(.semibold)
                }
            }
        }
        .foregroundColor(.fintechGreen)
    }
    
    var alreadyUser: some View {
        HStack(spacing: 0) {
            Text(Strings.alreadyUser.toLocalizedString)
                .font(.footnote)
                .foregroundColor(.secondary)
            NavigationLink(
                destination: LoginSignupView(viewModel: .init(mode: .login, isPushed: $viewModel.isLoginPushed)),
                label: {
                    Text(Strings.here.toLocalizedString)
                        .font(.footnote)
                        .fontWeight(.semibold)
                })
        }
    }
    
    var mainContentView: some View {
        VStack {
            TabView(selection: $index){
                ForEach(viewModel.onboardingItems.indices) { itemIndex in
                    VStack {
                        Image(viewModel.onboardingItems[itemIndex].image)
                            .resizable()
                            .scaledToFit()
                        
                        Spacer()
                        VStack {
                            Text(viewModel.onboardingItems[itemIndex].title)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(viewModel.onboardingItems[itemIndex].description)
                                .font(.largeTitle)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, textBodyPadding)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: 800)
                        .tag(itemIndex)
                        Spacer()
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            Spacer()
            
            HStack {
                skip
                Spacer()
                IndexView(numberOfPages: viewModel.onboardingItems.count, currentIndex: index)
                Spacer()
                nextButton
            }.padding()
            
            alreadyUser
                .padding()
        }.padding([.horizontal, .bottom])
    }
    
    var body: some View {
        NavigationView {
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
//            .navigationBarHidden(true)
            .background(Color.appBackground.edgesIgnoringSafeArea(.all))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.fintechGreen)
    }
    
    // MARK: -Drawing Constants
    
    private let nextButtonIconSpacing: CGFloat = 5.0
    private let textAreaPadding: CGFloat = 0.01
    private let textBodyPadding: CGFloat = 0.01
    private let imageBackgroundOpacity: Double = 0.2
}

struct IndexView: View {
  let numberOfPages: Int
  let currentIndex: Int
  
  var body: some View {
    HStack(spacing: circleSpacing) {
      ForEach(0..<numberOfPages) { index in
        if shouldShowIndex(index) {
          Circle()
            .fill(currentIndex == index ? primaryColor : secondaryColor)
            .scaleEffect(currentIndex == index ? 1 : smallScale)
            .frame(width: circleSize, height: circleSize)
            .transition(AnyTransition.opacity.combined(with: .scale))
            .id(index)
        }
      }
    }
  }
    // MARK: - Drawing Constants
    
    private let circleSize: CGFloat = 16
    private let circleSpacing: CGFloat = 12
    
    private let primaryColor = Color.white
    private let secondaryColor = Color.white.opacity(0.6)
    
    private let smallScale: CGFloat = 0.6
  
  // MARK: - Private Methods
  
  func shouldShowIndex(_ index: Int) -> Bool {
    ((currentIndex - 1)...(currentIndex + 1)).contains(index)
  }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
