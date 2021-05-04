//
//  CombineRexSwiftUI.swift
//  TyranosaurusRex
//
//  Created by Alisdair Mills on 04/05/2021.
//

import Foundation
import SwiftUI
import Combine
import CombineRex

public enum ChangeModifier {
    case animated
    case notAnimated
}

extension Binding {
    public static func store<Action, State>(
        _ store: ObservableViewModel<Action, State>,
        state: KeyPath<State, Value>,
        changeModifier: ChangeModifier = .notAnimated,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        onChange: @escaping (Value) -> Action?
    ) -> Binding<Value> {
        Binding.store(
            store,
            stateMap: { $0[keyPath: state] },
            changeModifier: changeModifier,
            file: file,
            function: function,
            line: line,
            info: info,
            onChange: onChange
        )
    }

    public static func store<Action, State>(
        _ store: ObservableViewModel<Action, State>,
        stateMap: @escaping (State) -> Value,
        changeModifier: ChangeModifier = .notAnimated,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        info: String? = nil,
        onChange: @escaping (Value) -> Action?
    ) -> Binding<Value> {
        return .caching(
            get: { stateMap(store.state) },
            set: { newValue in
                // Allow to not dispatch any action.
                guard let action = onChange(newValue) else { return }
                let dispatch = {
                    store.dispatch(action, from: .init(file: file, function: function, line: line, info: info))
                }
                switch changeModifier {
                case .animated:
                    withAnimation { dispatch() }
                case .notAnimated:
                    dispatch()
                }
        })
    }

    /// Returns a Binding that ignores all tries to set the value.
    public static func getOnly<Action, State>(_ store: ObservableViewModel<Action, State>,
                                              state: KeyPath<State, Value>) -> Binding<Value> {
        return .init(
            get: { store.state[keyPath: state] },
            set: { _ in }
        )
    }

    public static func caching(
        get: @escaping () -> Value,
        set: @escaping (Value) -> Void) -> Binding<Value> {
        var temp: Value?
        return .init(
            get: { temp ?? get() },
            set: { newValue in
                temp = newValue
                set(newValue)

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
