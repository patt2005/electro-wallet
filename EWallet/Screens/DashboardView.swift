import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: WalletStore
    @State private var selectedTab: Tab = .home

    enum Tab { case home, history, receive, settings }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            // Content
            Group {
                switch selectedTab {
                case .home:    HomeTabView(selectedTab: $selectedTab)
                case .history: HistoryTabView()
                case .receive: ReceiveTabView()
                case .settings: SettingsTabView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 82) }

            // Custom tab bar
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 0) {
                    TabBarItem(icon: "house.fill", label: "Home", tab: .home, selectedTab: $selectedTab)
                    TabBarItem(icon: "clock.fill", label: "History", tab: .history, selectedTab: $selectedTab)
                    TabBarItem(icon: "arrow.down.circle.fill", label: "Receive", tab: .receive, selectedTab: $selectedTab)
                    TabBarItem(icon: "gearshape.fill", label: "Settings", tab: .settings, selectedTab: $selectedTab)
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
                .background(Color(.systemBackground))
            }
        }
        .fullScreenCover(isPresented: $store.showSend) {
            SendView()
        }
        .sheet(isPresented: $store.showSendSuccess) {
            SendSuccessView()
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Tab Bar Item

struct TabBarItem: View {
    let icon: String
    let label: String
    let tab: DashboardView.Tab
    @Binding var selectedTab: DashboardView.Tab

    var isActive: Bool { selectedTab == tab }

    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isActive ? Color.btcGreen : Color(.tertiaryLabel))
                Text(label)
                    .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? Color.btcGreen : Color(.tertiaryLabel))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
