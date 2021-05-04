//
//  Store.swift
//  TyranosaurusRex
//
//  Created by Tim Isenman on 2021/04/28.
//

import Foundation
import CombineRex
import Combine
import SwiftUI

let roomReducer = Reducer<AppAction, AppState>.reduce { action, state in
    switch action {
    case .changeName:
        state.roomName = "Bitch"
        print("Name from reducer: \(state.roomName)")
    case .restoreOriginal:
        state.roomName = "Tim, again"
        print("Name from reducer: \(state.roomName)")
        
    case .presentView:
        print("Present view tapped")
        state.isPresenting = true
        state.isInRoom = true
        print("Is in room: \(state.isInRoom)")
    case .closeView:
        print("View Closed")
        state.isPresenting = false
        state.isInRoom = false
        print("Is in room: \(state.isInRoom)")
    }
}

let appReducer = roomReducer

let store = ReduxStoreBase<AppAction, AppState>(
    subject: .combine(initialValue: AppState(roomName: "Tim's Room")),
    reducer: appReducer,
    middleware: IdentityMiddleware() //RoomMiddleWare()
)

struct AppState: Equatable {
    var roomName = ""
    var isInRoom = false
    var isPresenting = false
    
}

enum AppAction {
    case changeName
    case restoreOriginal
    case presentView
    case closeView
}



enum RoomViewModel {
    
    static func viewModel<S: StoreType>(from store: S) -> ObservableViewModel<RoomViewAction, RoomViewState> where S.ActionType == AppAction, S.StateType == AppState {
        store.projection(
            action: from(viewAction:),
            state: from(appState:)
        ).asObservableViewModel(initialState: .initial)
    }
    
    struct RoomViewState: Equatable {
        static func == (lhs: RoomViewModel.RoomViewState, rhs: RoomViewModel.RoomViewState) -> Bool {
            print("Printing a comparison?")
            return true
        }
        
        var currentName: String?
        @Binding var isCurrentlyPresenting: Bool
        
        static var initial: RoomViewState {
            .init(currentName: "Tim", isCurrentlyPresenting: .constant(false))
        }
    }
    
    enum RoomViewAction {
        case viewChangeName
        case beginPresenting
        case restoreName
    }
    
    private static func from(viewAction: RoomViewAction) -> AppAction? {
        switch viewAction {
        case .viewChangeName: return .changeName
        case .beginPresenting: return .presentView
        case .restoreName: return .restoreOriginal
//        case .plusButtonTap: return .count(.increment)
//        case .minusButtonTap: return .count(.decrement)
//        case .changeName: return .changeName(.)
        }
    }

    private static func from(appState: AppState) -> RoomViewState {
        RoomViewState(currentName: "Tim, once again", isCurrentlyPresenting: .constant(false))
    }
    
}

// MARK: Functional helpers
func ignore<T>(_ t: T) -> Void { }
func identity<T>(_ t: T) -> T { t }
func absurd<T>(_ never: Never) -> T { }

class RoomMiddleWare: Middleware {
    
//    typealias InputActionType = AppAction // It wants to receive all possible app actions
//    typealias OutputActionType = Never          // No action is generated from this Middleware
//    typealias StateType = AppState        // It wants to read the whole app state
//
    private var cancellables = Set<AnyCancellable>()
    private var currentState: GetState<AppState>?
    private var output: AnyActionHandler<AppAction>?
    
    func receiveContext(getState: @escaping GetState<AppState>, output: AnyActionHandler<AppAction>) {
        self.currentState = getState
        self.output = output
        
    }
    
    func handle(action: AppState, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        guard let getState = self.currentState else { return }

        let stateBefore = getState()
        afterReducer = .do {
            let stateAfter = getState()
            print("State before: \(stateBefore)")
            defer { print("blah blah\n") }
            
            print("Action: \(action) from \(dispatcher)")
            guard stateBefore != stateAfter else { return }
            print("Old State: \(stateBefore)")
            print("New State: \(stateAfter)")
        }
    }
    
    
}

enum SettingsViewModel {
    
    static func viewModel<S: StoreType>(from store: S) -> ObservableViewModel<SettingsViewAction, SettingsViewState> where S.ActionType == AppAction, S.StateType == AppState {
        store.projection(
            action: from(viewAction:),
            state: from(appState:)
        ).asObservableViewModel(initialState: .initial)
    }
    
    struct SettingsViewState: Equatable {
        var userWantsNotifications: Bool?
        var backgroundColor: String?
        
        static var initial: SettingsViewState {
            .init(userWantsNotifications: false, backgroundColor: "")
        }
    }
    
    enum SettingsViewAction {
        case changedNotifPreference
        case changedBackgroundColor
    }
    
    private static func from(viewAction: SettingsViewAction) -> AppAction? {
        switch viewAction {
        case .changedNotifPreference: return .none
        case .changedBackgroundColor: return .none
        }
    }

    private static func from(appState: AppState) -> SettingsViewState {
        SettingsViewState(userWantsNotifications: false)
    }
    
}
