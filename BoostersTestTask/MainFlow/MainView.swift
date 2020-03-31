//
//  MainView.swift
//  BoostersTestTask
//
//  Created by Elias on 31.03.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject private var viewModel: MainViewModel
    @State private var presentingActionSheet = false
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            statusLabel.padding()
            Spacer()
            VStack {
                Divider()
                HStack {
                    Text("Sleep Timer").padding()
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Text("Sleep Timer")
                    }).padding()
                }
                Divider()
                HStack {
                    Text("Alarm").padding()
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Text("Alarm date text")
                    }).padding()
                }
                Divider()
            }
            HStack {
                Button(action: {
                    
                    }, label: {
                        Text("Pause")
                            .foregroundColor(Color.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                        .background(/*@START_MENU_TOKEN@*/Color.blue/*@END_MENU_TOKEN@*/)
                        .cornerRadius(/*@START_MENU_TOKEN@*/7.0/*@END_MENU_TOKEN@*/)
                })
                    .padding(.all)
            }
        }.padding()
    }
    
}

private extension MainView {
    
    var statusLabel: some View {
        Text(viewModel.statusString).font(.title).lineLimit(nil).padding(.top)
    }
    
    func sleepTimerActionSheet() -> ActionSheet {
       var buttons = viewModel.sleepTimerDurationsStrings.enumerated()
            .map { (offset: Int, element: String) in
                ActionSheet.Button.default(Text(element)) {
                    self.viewModel.timerDurationSelected(at: offset)
                }
        }
        buttons.append(Alert.Button.cancel())
    
        return ActionSheet(
            title: Text("Sleep timer").foregroundColor(.gray),
            buttons: buttons
        )
    }
    
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
#endif
