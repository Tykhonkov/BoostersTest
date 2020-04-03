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
    @State private var isPresentingActionSheet = false
    @State private var isPresentingDatePicker = false
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
                recordingTogglerRow
                Divider()
                sleepTimerRow
                Divider()
                alarmTimeRow
                Divider()
                
            }
            .disabled(viewModel.isControlsDissabled)
            stateSwitcherButton
        }
        .padding()
        .sheet(
            isPresented: $isPresentingDatePicker,
            onDismiss: {
                self.startDate = self.viewModel.alarmTime ?? Calendar.current.startOfDay(for: Date())
        },
            content: datePickerSheet
        )
    }
    
}

private extension MainView {
    
    var stateSwitcherButton: some View {
        Button(action: {
            self.viewModel.stateSwitcherButtonAction()
        }, label: {
            Text(viewModel.stateButtonSwitcherTitle)
                .foregroundColor(Color.white)
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(7.0)
        })
            .padding(.all)
    }
    var recordingTogglerRow: some View {
        HStack {
            Toggle(isOn: $viewModel.isRecordingEnabled) {
                Text("Enable recoording")
            }
            .padding()
        }
    }
    var sleepTimerRow: some View {
        HStack {
            Text("Sleep Timer").padding()
            Spacer()
            Button(action: {
                self.isPresentingActionSheet = true
            }, label: {
                Text(viewModel.currentSleepTimerDurationString)
            })
                .padding()
                .actionSheet(isPresented: $isPresentingActionSheet, content: sleepTimerActionSheet)
        }
    }
    var alarmTimeRow: some View {
        HStack {
            Text("Alarm").padding()
            Spacer()
            Button(action: {
                self.isPresentingDatePicker = true
            }, label: {
                Text(self.viewModel.alarmTimeString)
            })
                .padding()
        }
    }
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
        VStack {
            HStack {
                Button(action: {
                    self.isPresentingDatePicker = false
                    self.startDate = self.viewModel.alarmTime ?? Calendar.current.startOfDay(for: Date())
                }, label: {
                    Text("Cancel")
                })
                Spacer()
                Text("Alarm")
                Spacer()
                Button(action: {
                    self.isPresentingDatePicker = false
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
        let soundPath = Bundle.main.path(forResource: "nature.mp4", ofType: nil)!
        let soundFileURL = URL(fileURLWithPath: soundPath)
        
        let configuration = BoostersWorkflowCoordinator.BoostersCoordinatorConfiguration(
            audioSession: AudioSession(),
            audioPlayer: BoostersAudioPlayer(),
            audioRecorder: BoostersAudioRecorder(),
            notificationsManager: NotificationsManager(),
            soundFileURL: soundFileURL,
            alarmSoundName: "alarm.mp4",
            sleepSoundDuratioon: 20*60,
            shouldPlayNatureSound: true,
            isRecordingEnabled: true
        )
        
        let viewModel = MainViewModel(workflowCoordinator: BoostersWorkflowCoordinator(configuration: configuration))
        return MainView(viewModel: viewModel)
    }
}
#endif
