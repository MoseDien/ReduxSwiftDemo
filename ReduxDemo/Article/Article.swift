import SwiftUI
import Combine

// MARK: - Protocol Definitions
protocol Action {}
protocol StateType {}

// MARK: - Store
@MainActor
class Store<State: StateType>: ObservableObject {
    @Published private(set) var state: State
    private let reducer: any ReducerProtocol<State>
    
    init(initialState: State, reducer: any ReducerProtocol<State>) {
        self.state = initialState
        self.reducer = reducer
    }
    
    func dispatch(_ action: Action) {
        state = reducer.reduce(state: state, action: action)
    }
}

// MARK: - Reducer Protocol
protocol ReducerProtocol<State> {
    associatedtype State: StateType
    func reduce(state: State, action: Action) -> State
}

// MARK: - App State
struct AppState: StateType {
    var userState: UserState
    var settingsState: SettingsState
    var contentState: ContentState
}

struct UserState: StateType {
    var isLoggedIn: Bool = false
    var username: String = ""
    var email: String = ""
}

struct SettingsState: StateType {
    var isDarkMode: Bool = false
    var notificationsEnabled: Bool = true
    var language: String = "zh"
}

struct ContentState: StateType {
    var articles: [Article] = []
    var favorites: Set<Int> = []
}

// MARK: - Models
struct Article: Identifiable {
    let id: Int
    let title: String
    let content: String
}

// MARK: - Actions
enum UserAction: Action {
    case login(username: String, password: String)
    case logout
    case updateProfile(username: String, email: String)
}

enum SettingsAction: Action {
    case toggleDarkMode
    case toggleNotifications
    case changeLanguage(String)
}

enum ContentAction: Action {
    case loadArticles([Article])
    case toggleFavorite(Int)
    case clearFavorites
}

// MARK: - Concrete Reducers
struct UserReducer: ReducerProtocol {
    func reduce(state: UserState, action: Action) -> UserState {
        var newState = state
        guard let userAction = action as? UserAction else { return state }
        
        switch userAction {
        case let .login(username, _):
            newState.isLoggedIn = true
            newState.username = username
        case .logout:
            newState.isLoggedIn = false
            newState.username = ""
            newState.email = ""
        case let .updateProfile(username, email):
            newState.username = username
            newState.email = email
        }
        return newState
    }
}

struct SettingsReducer: ReducerProtocol {
    func reduce(state: SettingsState, action: Action) -> SettingsState {
        var newState = state
        guard let settingsAction = action as? SettingsAction else { return state }
        
        switch settingsAction {
        case .toggleDarkMode:
            newState.isDarkMode.toggle()
        case .toggleNotifications:
            newState.notificationsEnabled.toggle()
        case let .changeLanguage(language):
            newState.language = language
        }
        return newState
    }
}

struct ContentReducer: ReducerProtocol {
    func reduce(state: ContentState, action: Action) -> ContentState {
        var newState = state
        guard let contentAction = action as? ContentAction else { return state }
        
        switch contentAction {
        case let .loadArticles(articles):
            newState.articles = articles
        case let .toggleFavorite(articleId):
            if newState.favorites.contains(articleId) {
                newState.favorites.remove(articleId)
            } else {
                newState.favorites.insert(articleId)
            }
        case .clearFavorites:
            newState.favorites.removeAll()
        }
        return newState
    }
}

// MARK: - Root Reducer
struct AppReducer: ReducerProtocol {
    let userReducer: UserReducer
    let settingsReducer: SettingsReducer
    let contentReducer: ContentReducer
    
    func reduce(state: AppState, action: Action) -> AppState {
        AppState(
            userState: userReducer.reduce(state: state.userState, action: action),
            settingsState: settingsReducer.reduce(state: state.settingsState, action: action),
            contentState: contentReducer.reduce(state: state.contentState, action: action)
        )
    }
}

// MARK: - Store Provider
@MainActor
class StoreProvider: ObservableObject {
    @Published var store: Store<AppState>
    
    init() {
        let initialState = AppState(
            userState: UserState(),
            settingsState: SettingsState(),
            contentState: ContentState()
        )
        
        let rootReducer = AppReducer(
            userReducer: UserReducer(),
            settingsReducer: SettingsReducer(),
            contentReducer: ContentReducer()
        )
        
        self.store = Store(initialState: initialState, reducer: rootReducer)
    }
}

// MARK: - View Examples
struct ArticleView: View {
    @StateObject private var storeProvider = StoreProvider()
    
    var body: some View {
        TabView {
            UserView()
                .tabItem {
                    Label("用户", systemImage: "person")
                }
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
            
            ArticlesView()
                .tabItem {
                    Label("文章", systemImage: "book")
                }
        }
        .environmentObject(storeProvider.store)
    }
}

struct UserView: View {
    @EnvironmentObject var store: Store<AppState>
    
    var body: some View {
        VStack {
            if store.state.userState.isLoggedIn {
                Text("欢迎, \(store.state.userState.username)")
                Button("登出") {
                    store.dispatch(UserAction.logout)
                }
            } else {
                Button("登录") {
                    store.dispatch(UserAction.login(username: "测试用户", password: ""))
                }
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var store: Store<AppState>
    
    var body: some View {
        Form {
            Toggle("深色模式", isOn: Binding(
                get: { store.state.settingsState.isDarkMode },
                set: { _ in store.dispatch(SettingsAction.toggleDarkMode) }
            ))
            
            Toggle("通知", isOn: Binding(
                get: { store.state.settingsState.notificationsEnabled },
                set: { _ in store.dispatch(SettingsAction.toggleNotifications) }
            ))
        }
    }
}

struct ArticlesView: View {
    @EnvironmentObject var store: Store<AppState>
    
    var body: some View {
        List(store.state.contentState.articles) { article in
            VStack(alignment: .leading) {
                Text(article.title)
                    .font(.headline)
                Text(article.content)
                    .font(.subheadline)
                
                Button(store.state.contentState.favorites.contains(article.id) ? "取消收藏" : "收藏") {
                    store.dispatch(ContentAction.toggleFavorite(article.id))
                }
            }
        }
    }
}
