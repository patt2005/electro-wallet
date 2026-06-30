import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: WalletStore
    @State private var selectedTab: Tab = .home

    enum Tab { case home, history, receive, settings }

    var body: some View {
        Color.appBackground.ignoresSafeArea()
            .overlay(alignment: .bottom) {
                // Content fills all available space above the tab bar
                Group {
                    switch selectedTab {
                    case .home:     HomeTabView(selectedTab: $selectedTab)
                    case .history:  HistoryTabView()
                    case .receive:  ReceiveTabView()
                    case .settings: SettingsTabView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    tabBar
                }
            }
        .fullScreenCover(isPresented: $store.showSend) {
            SendView()
        }
        .sheet(isPresented: $store.showSendSuccess) {
            SendSuccessView()
        }
    }

    private var tabBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 1)

            HStack(spacing: 0) {
                TabBarItem(icon: "house",         label: "Home",     tab: .home,     selectedTab: $selectedTab)
                TabBarItem(icon: "clock",         label: "History",  tab: .history,  selectedTab: $selectedTab)
                TabBarItem(icon: "arrow.down",    label: "Receive",  tab: .receive,  selectedTab: $selectedTab)
                TabBarItem(icon: "gearshape",     label: "Settings", tab: .settings, selectedTab: $selectedTab)
            }
            .padding(.top, 9)
            .padding(.bottom, 4)
        }
        .background(.ultraThinMaterial)
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
                    .font(.system(size: 22, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? Color.btcGreen : Color.textMuted)
                Text(label)
                    .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? Color.btcGreen : Color.textMuted)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
