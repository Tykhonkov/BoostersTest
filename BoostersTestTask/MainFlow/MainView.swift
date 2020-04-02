//
//  MainView.swift
//  BoostersTestTask
//
//  Created by Elias on 31.03.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject private var viewModel: MainViewModel
    @State private var presentingActionSheet = false
    @State private var presentingDatePicker = false
    @State private var isRecordingEnabled = false
    @State private var startDate = Calendar.current.startOfDay(for: Date())
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Spacer()
            statusLabel.padding()
            Spacer()
            VStack {
                Divider()
                HStack {
                    Toggle(isOn: $isRecordingEnabled) {
                        Text("Enable recoording")
                    }.padding()
                }
                Divider()
                HStack {
                    Text("Sleep Timer").padding()
                    Spacer()
                    Button(action: {
                        self.presentingActionSheet = true
                    }, label: {
                        Text("Sleep Timer")
                    })
                        .padding()
                        .actionSheet(isPresented: $presentingActionSheet, content: sleepTimerActionSheet)
                }
                Divider()
                HStack {
                    Text("Alarm").padding()
                    Spacer()
                    Button(action: {
                        self.presentingDatePicker = true
                    }, label: {
                        Text(self.viewModel.alarmTimeString)
                    })
                        .padding()
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
                        .background(Color.blue)
                        .cornerRadius(7.0)
                })
                    .padding(.all)
            }
        }
        .padding()
        .sheet(isPresented: $presentingDatePicker, onDismiss: {
            self.startDate = self.viewModel.alarmTime
        },content: datePickerSheet)
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
    
    func datePickerSheet() -> some View {
        return VStack {
            HStack {
                Button(action: {
                    self.presentingDatePicker = false
                    self.startDate = self.viewModel.alarmTime
                }, label: {
                    Text("Cancel")
                })
                Spacer()
                Text("Alarm")
                Spacer()
                Button(action: {
                    self.presentingDatePicker = false
                    self.viewModel.alarmTime = self.startDate
                }, label: {
                    Text("Done")
                })
            }
            .padding()
            Spacer()
            DatePicker(
                "",
                selection: self.$startDate,
                displayedComponents: .hourAndMinute
            )
                .labelsHidden()
            Spacer()
        }
    }
    
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
#endif
