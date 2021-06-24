//
//  SubscriptionView.swift
//  Billy
//
//  Created by Felipe Passos on 29/12/20.
//

import SwiftUI
import Purchases

struct SubscriptionView: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @Environment(\.colorScheme) var colorScheme
    @State var index = 0
    
    var heading: some View {
        VStack {
            HStack {
                Text(Strings.unlockFullAccess.toLocalizedString)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding([.horizontal, .top])
            
            Image("subscription")
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
                .padding(.horizontal)
        }
    }
    
    var subscriptionBenefits: some View {
        VStack {
            HStack {
                Text(Strings.checkAllIncluded.toLocalizedString)
                Spacer()
            }
            .font(.headline)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            
            
            HStack {
                VStack(alignment: HorizontalAlignment.leading) {
                    Text(Strings.feature.toLocalizedString)
                        .font(.headline)
                        .padding(.leading)
                        .frame(height: 40)
                    
                    ForEach(viewModel.subscriptionBenefits.titles, id: \.self) { title in
                        Text(title)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                            .frame(height: 40)
                    }
                }.padding(.vertical)
                
                Spacer()
                Divider()
                
                VStack {
                    Text(Strings.free.toLocalizedString)
                        .font(.headline)
                        .padding(.horizontal, 3)
                        .frame(height: 40)
                    
                    ForEach(viewModel.subscriptionBenefits.freeLimits, id: \.self) { freeLimit in
                        Text(String(freeLimit))
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 3)
                            .frame(height: 40)
                    }
                }.padding(.vertical)
                
                Divider()
                
                VStack {
                    Text(Strings.premium.toLocalizedString)
                        .font(.headline)
                        .padding(.leading, 3)
                        .padding(.trailing)
                        .frame(height: 40)
                    
                    ForEach(viewModel.subscriptionBenefits.freeLimits, id: \.self) { _ in
                        Image(systemName: "infinity")
                            .font(Font.system(size: 20, weight: .bold))
                            .padding(.leading, 3)
                            .padding(.trailing)
                            .frame(height: 40)
                    }
                }
                .padding(.vertical)
                .foregroundColor(.fintechGreen)
            }
            .cardify()
            
            HStack {
                Image(systemName: "infinity")
                    .font(Font.system(size: 20, weight: .bold))
                    .foregroundColor(.fintechGreen)
                    .padding(.leading, 3)
                    .padding(.trailing, 3)
                    .frame(height: 40)
                
                Text(Strings.unlimited.toLocalizedString)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .cardify()
            .fixedSize()
        }
        .padding([.horizontal, .bottom])
    }
    
    var purchaseAcknowledgementText: some View {
        Text(Strings.purchaseAcknowledgementText.toLocalizedString)
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
    }
    
    var termsOfService: some View {
        HStack {
            Spacer()
            Link(Strings.termsOfUse.toLocalizedString, destination: URL(string: "https://passosfe.github.io/billyapp/termsconditions/")!)
            Spacer()
            Link(Strings.privacyPolicy.toLocalizedString, destination: URL(string: "https://passosfe.github.io/billyapp/privacypolicy/")!)
            Spacer()
        }
        .padding()
        .font(.caption)
    }
    
    var redemptionCode: some View {
        Button(action: {
            viewModel.send(action: .restorePurchases)
        }, label: {
            Text("Resgatar código de oferta")
                .font(.caption)
        })
        .padding(.bottom)
    }
    
//    var restorePurchases: some View {
//        Button(action: {
//            viewModel.send(action: .restorePurchases)
//        }, label: {
//            Text(Strings.restorePurchases.toLocalizedString)
//                .font(.caption)
//        })
//        .padding(.bottom)
//    }
    
    var subscribeButton: some View {
        Button(action: {
            viewModel.send(action: .makePurchase)
        }, label: {
            HStack {
                Spacer()
                Text(Strings.subscribe.toLocalizedString)
                Spacer()
            }
        })
        .buttonStyle(PrimaryButtonStyle())
        .padding()
        .padding(.horizontal)
    }
    
    func savingProduct(package: Purchases.Package) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(Strings.spare.toLocalizedString) \(viewModel.savingPercentage(for: package.product.price as Decimal, in: package.product.subscriptionPeriod?.unit.rawValue))%")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal)
                .padding(.vertical, 5)
                .padding(.top, 5)
            HStack(spacing: 0) {
                VStack {
                    Spacer(minLength: 0)
                    Image(systemName: package == viewModel.selectedProduct ? "checkmark.circle.fill" : "checkmark.circle")
                        .foregroundColor(package == viewModel.selectedProduct ? .fintechGreen : .secondary)
                        .font(.title)
                    Spacer(minLength: 0)
                }.padding(.trailing)
                
                VStack(alignment: .leading) {
                    Text("\(viewModel.subscriptionItemTitle(for: package.product.price as Decimal, in: package.product.subscriptionPeriod?.unit.rawValue, at: package.product.priceLocale))")
                        .fontWeight(.bold)
                    Text(viewModel.subscriptionItemSubtitle(for: package.product.price as Decimal, in: package.product.subscriptionPeriod?.unit.rawValue, at: package.product.priceLocale))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding()
            .cardify()
            .padding(4)
            .fixedSize(horizontal: false, vertical: true)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.fintechGreen, lineWidth: package == viewModel.selectedProduct ? 4 : 0)
            )
        }
        .cardify(background: package == viewModel.selectedProduct ? .fintechGreen : .secondary)
        .fixedSize(horizontal: false, vertical: true)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.fintechGreen, lineWidth: package == viewModel.selectedProduct ? 4 : 0)
        )
        .onTapGesture {
            viewModel.send(action: .selectProduct(package))
        }
        .padding(.horizontal)
    }
    
    func normalProduct(package: Purchases.Package) -> some View {
        HStack(spacing: 0) {
            VStack {
                Spacer(minLength: 0)
                Image(systemName: package == viewModel.selectedProduct ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundColor(package == viewModel.selectedProduct ? .fintechGreen : .secondary)
                    .font(.title)
                Spacer(minLength: 0)
            }.padding(.trailing)
            
            VStack(alignment: .leading) {
                Text("\(viewModel.subscriptionItemTitle(for: package.product.price as Decimal, in: package.product.subscriptionPeriod?.unit.rawValue, at: package.product.priceLocale))")
                    .fontWeight(.bold)
                Text(viewModel.subscriptionItemSubtitle(for: package.product.price as Decimal, in: package.product.subscriptionPeriod?.unit.rawValue, at: package.product.priceLocale))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .cardify()
        .fixedSize(horizontal: false, vertical: true)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.fintechGreen, lineWidth: package == viewModel.selectedProduct ? 4 : 0)
        )
        .onTapGesture {
            viewModel.send(action: .selectProduct(package))
        }
        .padding(.horizontal)
        .padding(4)
    }
    
    var subscriptionItems: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.products.indices) { index in
                if viewModel.savingPercentage(for: viewModel.products[index].product.price as Decimal, in: viewModel.products[index].product.subscriptionPeriod?.unit.rawValue) > 0 {
                    savingProduct(package: viewModel.products[index])
                } else {
                    normalProduct(package: viewModel.products[index])
                }
            }
        }.padding(.vertical)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ZStack {
                        Color.appBackground
                        ProgressView()
                    }
                } else {
//                    ZStack {
//                        Color.fintechGreen.opacity(0.2)
//                            .clipShape(Circle())
//                            .scaledToFit()
//                            .frame(width: UIScreen.main.bounds.size.width * 2)
//                            .edgesIgnoringSafeArea(.all)
//                            .offset(y: -UIScreen.main.bounds.size.width)
                        
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            heading
                            if let introductoryPriceText = viewModel.introductoryPriceText {
                                Text(introductoryPriceText)
                                    .fontWeight(.semibold)
                                    .padding([.horizontal, .top])
                            }
                            subscriptionItems
                            subscribeButton
                            redemptionCode
                            
                            subscriptionBenefits
                            
                            // TODO
//                            restorePurchases
                            
                            Spacer()
                            
                            purchaseAcknowledgementText
                            termsOfService
                        }
                    }
//                    }
                }
            }
            .accentColor(.fintechGreen)
            .background(Color.appBackground.edgesIgnoringSafeArea(.all))
            .navigationBarTitle(Strings.subscription.toLocalizedString)
            .navigationBarItems(trailing: Button(action: {
                viewModel.send(action: .close)
            }, label: {
                Image(systemName: "xmark")
                    .font(.body)
                    .foregroundColor(.fintechGreen)
                    .padding()
            }))
            .alert(isPresented: Binding<Bool>.constant($viewModel.error.wrappedValue != nil), content: { () -> Alert in
                Alert(title: Text("Error!"),
                      message: Text($viewModel.error.wrappedValue?.localizedDescription ?? ""),
                      dismissButton: .default(Text("OK"), action: {
                        viewModel.error = nil
                      }))
            })
        }
    }
}
