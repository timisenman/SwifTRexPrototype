//
//  ContentView.swift
//  TyranosaurusRex
//
//  Created by Tim Isenman on 2021/04/28.
//

import SwiftUI
import Combine
import CombineRex

struct ContentView: View {
    @ObservedObject var viewModel: ObservableViewModel<RoomViewModel.RoomViewAction, RoomViewModel.RoomViewState>
    @State private var nameText = ""
    @State var cancellables = Set<AnyCancellable>()
    @State var isPresenting = false
    
    var body: some View {
        VStack {
            Text("Your name is \(nameText)")
                .padding()
            
            Button(action: {
                store.dispatch(.changeName)
                store.statePublisher.sink { (state) in
                    nameText = state.roomName
                }
                .store(in: &cancellables)
                
            }, label: {
                Text("Change Name")
            })
            
            Button(action: {
                store.dispatch(.restoreOriginal)
            }, label: {
                Text("Restore Name")
            })
            
            Button(action: {
                store.dispatch(.presentView)
                
                store.statePublisher.sink { (state) in
                    self.isPresenting = state.isPresenting
                }
                .store(in: &cancellables)
                
            }, label: {
                Text("Present View")
            })
        }
        .onAppear(perform: {
            store.statePublisher.sink { (state) in
                nameText = state.roomName
            }
            .store(in: &cancellables)
        })
        .sheet(isPresented: $isPresenting, content: {
            OpenedRoom(fakeRoomModel: viewModel)
        })
    }
}

struct OpenedRoom: View {
    @ObservedObject var fakeRoomModel: ObservableViewModel<RoomViewModel.RoomViewAction, RoomViewModel.RoomViewState>
    
    var body: some View {
        VStack(spacing: 30) {
            Text("You're in the concept of a room")
            Button(action: {
                fakeRoomModel.dispatch(.restoreName)
            }, label: {
                Text("Change room name")
            })
            
            Button(action: {
                
            }, label: {
                Text("Open Settings")
            })
        }
        .onDisappear {
            store.dispatch(.closeView)
        }
        .sheet(isPresented: fakeRoomModel.state.$isShowingSettings, content: {
            SettingsView(viewModel: SettingsViewModel())
        })
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}


struct SettingsView: View {
    var viewModel: ObservableViewModel<SettingsViewModel.SettingsViewAction, SettingsViewModel.SettingsViewState>
    var body: some View {
        VStack {
            Text("Fake Settings View")
            
            Button(action: {
                
            }, label: {
                Text("Change a Setting")
            })
        }
    }
}
