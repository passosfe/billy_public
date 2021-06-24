//
//  SplashView.swift
//  Billy
//
//  Created by Felipe Passos on 08/12/20.
//

import SwiftUI

struct SplashView: View {
//    @State var animate = false
//    @State var endAnimate = false
    
    var body: some View {
        ZStack {
            Color.fintechGreen
            Image("billyLogo")
//                .resizable()
                .renderingMode(.original)
//                .aspectRatio(contentMode: animate ? .fill :  .fit)
//                .frame(width: animate ? nil : 85, height: animate ? nil : 85, alignment: .center)
//                .scaleEffect(animate ? 3 : 1)
//                .frame(width: UIScreen.main.bounds.width)
        }
        .ignoresSafeArea(.all, edges: .all)
//        .onAppear {
//            withAnimation(Animation.easeOut(duration: 0.45)) {
//                animate.toggle()
//            }
//        }
//        .opacity(isShowingSplashScreen ? 0 : 1)
    }
}
