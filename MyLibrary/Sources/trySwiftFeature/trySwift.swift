import ComposableArchitecture
import DataClient
import Safari
import SwiftUI
import SharedModels

@Reducer
public struct TrySwift {
  @ObservableState
  public struct State: Equatable {
    var path = StackState<Path.State>()
    @Presents var destination: Destination.State?
    public init() {}
  }

  public enum Action: BindableAction, ViewAction {
    case path(StackAction<Path.State, Path.Action>)
    case destination(PresentationAction<Destination.Action>)
    case binding(BindingAction<State>)
    case view(View)

    public enum View {
      case organizerTapped
      case codeOfConductTapped
      case acknowledgementsTapped
      case privacyPolicyTapped
      case eventbriteTapped
      case websiteTapped
    }
  }

  @Reducer(state: .equatable)
  public enum Path {
    case organizers(Organizers)
    case acknowledgements(Acknowledgements)
  }

  @Reducer(state: .equatable)
  public enum Destination {
    case codeOfConduct(Safari)
    case privacyPolicy(Safari)
    case eventbrite(Safari)
    case website(Safari)
  }

  public init() {}

  public var body: some ReducerOf<TrySwift> {
    BindingReducer()
    Reduce { state, action in
      switch action {
        case .view(.organizerTapped):
          state.path.append(.organizers(.init()))
          return .none
        case .view(.codeOfConductTapped):
          let url = URL(string: String(localized: "Code of Conduct URL", bundle: .module))!
          state.destination = .codeOfConduct(.init(url: url))
          return .none
        case .view(.privacyPolicyTapped):
          let url = URL(string: String(localized: "Privacy Policy URL", bundle: .module))!
          state.destination = .privacyPolicy(.init(url: url))
          return .none
        case .view(.acknowledgementsTapped):
          state.path.append(.acknowledgements(.init()))
          return .none
        case .view(.eventbriteTapped):
          let url = URL(string: String(localized: "Eventbrite URL", bundle: .module))!
          state.destination = .eventbrite(.init(url: url))
          return .none
        case .view(.websiteTapped):
          let url = URL(string: String(localized: "Website URL", bundle: .module))!
          state.destination = .eventbrite(.init(url: url))
          return .none
        case .binding:
          return .none
        case .path:
          return .none
        case .destination:
          return .none
      }
    }
    .forEach(\.path, action: \.path)
    .ifLet(\.$destination, action: \.destination)
  }
}

@ViewAction(for: TrySwift.self)
public struct TrySwiftView: View {

  @Bindable public var store: StoreOf<TrySwift>

  public init(store: StoreOf<TrySwift>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      root
    } destination: { store in
      switch store.state {
        case .organizers:
          if let store = store.scope(state: \.organizers, action: \.organizers) {
            OrganizersView(store: store)
          }
        case .acknowledgements:
          if let store = store.scope(state: \.acknowledgements, action: \.acknowledgements) {
            AcknowledgementsView(store: store)
          }
      }
    }
    .navigationTitle(Text("try! Swift", bundle: .module))
  }

  @ViewBuilder var root: some View {
    List {
      Section {
        Image("logo", bundle: .module)
          .resizable()
          .aspectRatio(contentMode: .fit)
        Text("try! Swift Description", bundle: .module)
      }
      Section {
        Button {
          send(.codeOfConductTapped)
        } label: {
          Text("Code of Conduct", bundle: .module)
        }
        Button {
          send(.privacyPolicyTapped)
        } label: {
          Text("Privacy Policy", bundle: .module)
        }
      }
      Section {
        Button {
          send(.organizerTapped)
        } label: {
          Text("Organizers", bundle: .module)
        }
        Button {
          send(.acknowledgementsTapped)
        } label: {
          Text("Acknowledgements", bundle: .module)
        }
      }
      Section {
        Button {
          send(.eventbriteTapped)
        } label: {
          Text("Eventbrite", bundle: .module)
        }
        Button {
          send(.websiteTapped)
        } label: {
          Text("try! Swift Website", bundle: .module)
        }
      }
    }
    .navigationTitle(Text("try! Swift", bundle: .module))
    .sheet(item: $store.scope(state: \.destination?.codeOfConduct, action: \.destination.codeOfConduct)) { sheetStore in
      SafariViewRepresentation(url: sheetStore.url)
        .ignoresSafeArea()
        .navigationTitle(Text("Code of Conduct", bundle: .module))
    }
    .sheet(item: $store.scope(state: \.destination?.privacyPolicy, action: \.destination.privacyPolicy), content: { sheetStore in
      SafariViewRepresentation(url: sheetStore.url)
        .ignoresSafeArea()
        .navigationTitle(Text("Privacy Policy", bundle: .module))
    })
    .sheet(item: $store.scope(state: \.destination?.eventbrite, action: \.destination.eventbrite), content: { sheetStore in
      SafariViewRepresentation(url: sheetStore.url)
        .ignoresSafeArea()
    })
    .sheet(item: $store.scope(state: \.destination?.website, action: \.destination.website), content: { sheetStore in
      SafariViewRepresentation(url: sheetStore.url)
        .ignoresSafeArea()
    })
  }
}
