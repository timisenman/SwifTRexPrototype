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
    
    var body: some View {
        VStack {
            Text("Your name is \(viewModel.state.currentName)")
                .padding()
            
            Button(action: {
                viewModel.dispatch(.viewChangeName)
            }, label: {
                Text("Change Name")
            })
            
            Button(action: {
                viewModel.dispatch(.restoreName("hello"))
            }, label: {
                Text("Restore Name")
            })
            
            Button(action: {
                viewModel.dispatch(.beginPresenting)
            }, label: {
                Text("Present View")
            })
        }
        .sheet(isPresented: viewModel.binding[\.isCurrentlyPresenting], content: {
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
                fakeRoomModel.dispatch(.restoreName("goodbye"))
            }, label: {
                Text("Change room name")
            })
            
            Button(action: {
                fakeRoomModel.dispatch(.showSettings)
            }, label: {
                Text("Open Settings")
            })
        }
        .onDisappear {
            store.dispatch(.closeView)
        }
        
        .sheet(isPresented: fakeRoomModel.binding[\.isShowingSettings], content: {
            SettingsView(viewModel: SettingsViewModel.viewModel(from: store))
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
