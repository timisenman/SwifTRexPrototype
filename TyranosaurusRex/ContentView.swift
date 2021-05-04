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
                store.dispatch(.restoreOriginal)
            }, label: {
                Text("Restore Name")
            })
            
            Button(action: {
                store.dispatch(.presentView)
            }, label: {
                Text("Present View")
            })
        }
        .sheet(isPresented: self.viewModel.binding[\.isCurrentlyPresenting], content: {
            OpenedRoom(fakeRoomModel: viewModel)
        })
    }
}

public struct BindableViewModel<Action, State> {
    private var viewModel: ObservableViewModel<Action, State>

    public init(_ viewModel: ObservableViewModel<Action, State>) {
        self.viewModel = viewModel
    }

    /// Creates a lens binding to the viewModel, dispatching the action returned by the closure to the store on `set`,
    /// The  returned binding includes a local cache that will return the `set` value until the store updates.
    public subscript<Value>(
        path: KeyPath<State, Value>,
        changeModifier: ChangeModifier = .notAnimated,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        action: ((Value) -> Action?)? = nil) -> Binding<Value> {
            if let actionClosure = action {
                return .store(viewModel,
                              state: path,
                              changeModifier: changeModifier,
                              file: file,
                              function: function,
                              line: line,
                              info: info,
                              onChange: actionClosure)

            } else {
                return .getOnly(viewModel, state: path)
            }
    }
}

extension ObservableViewModel {
    /// Creates a `Binding` lens for the `ViewModel`. All keypaths of the state are supported and
    /// can be exposed as a `Binding`.
    public var binding: BindableViewModel<ActionType, StateType> {
        BindableViewModel(self)
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
        /*
        .sheet(isPresented: fakeRoomModel.state.$isShowingSettings, content: {
            SettingsView(viewModel: SettingsViewModel.viewModel(from: s))
        })*/
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
