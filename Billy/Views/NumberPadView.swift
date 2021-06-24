//
//  NumberPadView.swift
//  Billy
//
//  Created by Felipe Passos on 07/01/21.
//

import SwiftUI

struct NumberPadView: View {
    @Binding var show : Bool
    @Binding var txt : String
    
    let numbers = [7,8,9,4,5,6,1,2,3,0]
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private func key(for number: Int) -> some View {
        Button(action: {
            self.txt += String(number)
        }, label: {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(String(number))
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    Spacer()
                }
                Spacer()
            }.frame(maxHeight: .infinity)
        }).frame(maxHeight: .infinity)
    }
    
    var numberKeys: some View {
        ForEach(numbers, id: \.self) { number in
            if number == 0 {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        self.show.toggle()
                    }
                }, label: {
                    Image(systemName: "checkmark")
                        .font(Font.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                })
                .padding()
                .cardify(with: .circle, background: .fintechGreen)
                .padding()
            }
            
            key(for: number)
            
            if number == 0 {
                Button(action: {
                    self.txt.removeLast()
                }, label: {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.left")
                                .font(Font.system(size: 22, weight: .bold))
                                .padding(.bottom)
                            Spacer()
                        }
                        Spacer()
                    }
                })
            }
        }
    }
      
    var body : some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 0) {
                numberKeys
            }
            .padding([.horizontal, .top])
            .padding(.horizontal)
        }
        .padding(.bottom, (UIApplication.shared.windows.first?.safeAreaInsets.bottom)! + 40)
        .cardify()
        .frame(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height / 2) - 40)
        .accentColor(.fintechGreen)
    }
  }
    
struct NumberPadView_Previews: PreviewProvider {
    static var previews: some View {
        NumberPadView(show: .constant(true), txt: .constant(""))
    }
}
