import SwiftUI

struct KenMillionRoadAppShell: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore
    var KenMillionRoadShowToast: (String) -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                KenMillionRoadAppBackground()
                if KenMillionRoadStore.KenMillionRoadState.hasCompletedGoalBuilder {
                    VStack(spacing: 0) {
                        KenMillionRoadSelectedScreen(KenMillionRoadShowToast: KenMillionRoadShowToast)
                            .frame(width: proxy.size.width)
                            .frame(maxHeight: .infinity)
                            .background(KenMillionRoadTheme.deep.opacity(0.58))
                            .clipped()

                        KenMillionRoadTabBar()
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                            .padding(.bottom, 30)
                            .frame(width: proxy.size.width)
                            .background(KenMillionRoadTheme.asphalt.opacity(0.98))
                    }
                } else {
                    KenMillionRoadGoalBuilderScreen(KenMillionRoadShowToast: KenMillionRoadShowToast)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }
}

struct KenMillionRoadSelectedScreen: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore
    var KenMillionRoadShowToast: (String) -> Void

    var body: some View {
        switch KenMillionRoadStore.KenMillionRoadState.selectedTab {
        case .route:
            KenMillionRoadDashboardScreen(KenMillionRoadShowToast: KenMillionRoadShowToast)
        case .cashflow:
            KenMillionRoadLedgerScreen(KenMillionRoadShowToast: KenMillionRoadShowToast)
        case .simulate:
            KenMillionRoadSimulatorScreen(KenMillionRoadShowToast: KenMillionRoadShowToast)
        case .learn:
            KenMillionRoadLearnScreen()
        case .reports:
            KenMillionRoadReportsScreen(KenMillionRoadShowToast: KenMillionRoadShowToast)
        }
    }
}

struct KenMillionRoadTabBar: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore

    var body: some View {
        GeometryReader { proxy in
            let itemWidth = max(54, (proxy.size.width - 32) / CGFloat(KenMillionRoadTab.allCases.count))
            HStack(spacing: 8) {
                ForEach(KenMillionRoadTab.allCases) { tab in
                    Button {
                        KenMillionRoadStore.KenMillionRoadSelectTab(tab)
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 18, weight: .black))
                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: .black))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .foregroundStyle(KenMillionRoadStore.KenMillionRoadState.selectedTab == tab ? KenMillionRoadTheme.abyss : KenMillionRoadTheme.frost.opacity(0.76))
                        .frame(width: itemWidth, height: 58)
                        .background(KenMillionRoadStore.KenMillionRoadState.selectedTab == tab ? KenMillionRoadTheme.gold : Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.12), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: proxy.size.width, height: 58)
        }
        .frame(height: 58)
    }
}

private extension View {
    func KenMillionRoadScreenPadding() -> some View {
        padding(.horizontal, 18)
            .padding(.top, 108)
            .padding(.bottom, 36)
    }
}

struct KenMillionRoadGoalBuilderScreen: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore
    @State private var KenMillionRoadCapital = "0"
    @State private var KenMillionRoadIncome = "5000"
    @State private var KenMillionRoadExpenses = "3200"
    @State private var KenMillionRoadSideIncome = "600"
    @State private var KenMillionRoadTargetDate = Calendar.current.date(byAdding: .year, value: 12, to: Date()) ?? Date()
    @State private var KenMillionRoadRisk = "Balanced"
    var KenMillionRoadShowToast: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                KenMillionRoadHeader(title: "Design Your Million Plan", subtitle: "CAPITAL STYLE BRIEF", balance: "$1M")
                VStack(alignment: .leading, spacing: 14) {
                    Text("Set the first runway")
                        .font(.system(size: 24, weight: .black))
                    Text("Add your starting numbers and Ken Million Road will shape them into a route, forecasts, milestone cards and monthly reviews.")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(KenMillionRoadTheme.muted)
                    KenMillionRoadMoneyField(title: "Starting capital", text: $KenMillionRoadCapital)
                    KenMillionRoadMoneyField(title: "Monthly income", text: $KenMillionRoadIncome)
                    KenMillionRoadMoneyField(title: "Monthly expenses", text: $KenMillionRoadExpenses)
                    KenMillionRoadMoneyField(title: "Side income", text: $KenMillionRoadSideIncome)
                    DatePicker("Target review date", selection: $KenMillionRoadTargetDate, displayedComponents: .date)
                    Picker("Planning style", selection: $KenMillionRoadRisk) {
                        ForEach(["Conservative", "Balanced", "Ambitious"], id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    Button {
                        KenMillionRoadStore.KenMillionRoadCompleteGoalBuilder(
                            startingCapital: Double(KenMillionRoadCapital) ?? 0,
                            monthlyIncome: Double(KenMillionRoadIncome) ?? 0,
                            monthlyExpenses: Double(KenMillionRoadExpenses) ?? 0,
                            sideIncome: Double(KenMillionRoadSideIncome) ?? 0,
                            targetDate: KenMillionRoadTargetDate,
                            riskStyle: KenMillionRoadRisk
                        )
                        KenMillionRoadShowToast("Plan created")
                    } label: {
                        Label("Create Plan", systemImage: "map.fill")
                    }
                    .buttonStyle(KenMillionRoadPrimaryButtonStyle())
                    Button("Start With Blank Plan") {
                        KenMillionRoadStore.KenMillionRoadSkipGoalBuilder()
                    }
                    .buttonStyle(KenMillionRoadSecondaryButtonStyle())
                }
                .padding(16)
                .KenMillionRoadPanel(cornerRadius: 24)
            }
            .KenMillionRoadScreenPadding()
        }
        .scrollIndicators(.hidden)
    }
}

struct KenMillionRoadDashboardScreen: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore
    var KenMillionRoadShowToast: (String) -> Void

    var body: some View {
        KenMillionRoadScreen(title: "Ken Studio", subtitle: "ROUTE SNAPSHOT", balance: KenMillionRoadStore.KenMillionRoadNetWorthText) {
            KenMillionRoadDashboardHero()
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                KenMillionRoadStatTile(title: "Monthly Lift", value: KenMillionRoadStore.KenMillionRoadCurrency(KenMillionRoadStore.KenMillionRoadMonthlySurplus), icon: "arrow.up.forward.circle.fill", color: KenMillionRoadTheme.green)
                KenMillionRoadStatTile(title: "Keep Rate", value: "\(Int(KenMillionRoadStore.KenMillionRoadSavingsRate * 100))%", icon: "percent", color: KenMillionRoadTheme.gold)
                KenMillionRoadStatTile(title: "Arrival Estimate", value: KenMillionRoadStore.KenMillionRoadProjectedTargetDateText, icon: "calendar", color: KenMillionRoadTheme.cyan)
                KenMillionRoadStatTile(title: "Next Marker", value: KenMillionRoadStore.KenMillionRoadNextMilestone.title, icon: "flag.checkered", color: KenMillionRoadTheme.purple)
            }
            KenMillionRoadTrendCard()
            KenMillionRoadLevelRoad()
        }
    }
}

struct KenMillionRoadLedgerScreen: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore
    @State private var KenMillionRoadKind = KenMillionRoadLedgerKind.income
    @State private var KenMillionRoadCategory = KenMillionRoadLedgerCategory.salary
    @State private var KenMillionRoadTitle = ""
    @State private var KenMillionRoadAmount = ""
    @State private var KenMillionRoadWithdrawTitle = ""
    @State private var KenMillionRoadWithdrawAmount = ""
    var KenMillionRoadShowToast: (String) -> Void

    var body: some View {
        KenMillionRoadScreen(title: "Ledger", subtitle: "MONEY IN, MONEY OUT", balance: KenMillionRoadStore.KenMillionRoadCurrency(KenMillionRoadStore.KenMillionRoadMonthlySurplus)) {
            KenMillionRoadLedgerSummary()
            VStack(alignment: .leading, spacing: 14) {
                Text("Add ledger item")
                    .font(.system(size: 20, weight: .black))
                Picker("Type", selection: $KenMillionRoadKind) {
                    ForEach(KenMillionRoadLedgerKind.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                Picker("Category", selection: $KenMillionRoadCategory) {
                    ForEach(KenMillionRoadLedgerCategory.allCases) { Text($0.rawValue).tag($0) }
                }
                TextField("Title", text: $KenMillionRoadTitle)
                    .KenMillionRoadInputSurface()
                TextField("Amount", text: $KenMillionRoadAmount)
                    .keyboardType(.decimalPad)
                    .KenMillionRoadInputSurface()
                Button {
                    let value = Double(KenMillionRoadAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
                    KenMillionRoadShowToast(KenMillionRoadStore.KenMillionRoadAddLedger(kind: KenMillionRoadKind, category: KenMillionRoadCategory, title: KenMillionRoadTitle, amount: value))
                    if value > 0 {
                        KenMillionRoadAmount = ""
                        KenMillionRoadTitle = ""
                    }
                } label: {
                    Label("Save Item", systemImage: "plus.circle.fill")
                }
                .buttonStyle(KenMillionRoadPrimaryButtonStyle())
            }
            .padding(16)
            .KenMillionRoadPanel(cornerRadius: 24)
            KenMillionRoadCapitalSubtractCard(
                KenMillionRoadTitle: $KenMillionRoadWithdrawTitle,
                KenMillionRoadAmount: $KenMillionRoadWithdrawAmount,
                KenMillionRoadShowToast: KenMillionRoadShowToast
            )
            KenMillionRoadCategoryBreakdownCard()
            KenMillionRoadLedgerList()
        }
        .onChange(of: KenMillionRoadCategory) { newValue in
            KenMillionRoadKind = newValue.defaultKind
        }
    }
}

struct KenMillionRoadSimulatorScreen: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore
    @State private var KenMillionRoadIncomeBoost = 0.0
    @State private var KenMillionRoadExpenseCut = 0.0
    @State private var KenMillionRoadExtraSide = 0.0
    var KenMillionRoadShowToast: (String) -> Void

    var customMonthly: Double {
        max(1, KenMillionRoadStore.KenMillionRoadMonthlySurplus + KenMillionRoadIncomeBoost + KenMillionRoadExpenseCut + KenMillionRoadExtraSide)
    }

    var customMonths: Int {
        Int(ceil(max(0, KenMillionRoadStore.KenMillionRoadState.targetAmount - KenMillionRoadStore.KenMillionRoadState.currentNetWorth) / customMonthly))
    }

    var body: some View {
        KenMillionRoadScreen(title: "Forecast Room", subtitle: "TEST POSSIBLE MOVES", balance: "\(customMonths)m") {
            VStack(alignment: .leading, spacing: 16) {
                Text("Custom move")
                    .font(.system(size: 22, weight: .black))
                KenMillionRoadSliderRow(title: "Income jump", value: $KenMillionRoadIncomeBoost, range: 0...50000)
                KenMillionRoadSliderRow(title: "Expense trim", value: $KenMillionRoadExpenseCut, range: 0...25000)
                KenMillionRoadSliderRow(title: "Extra lane", value: $KenMillionRoadExtraSide, range: 0...50000)
                HStack {
                    KenMillionRoadMetricPill(title: "Monthly surplus", value: KenMillionRoadStore.KenMillionRoadCurrency(customMonthly))
                    KenMillionRoadMetricPill(title: "ETA", value: "\(customMonths) months")
                }
            }
            .padding(16)
            .KenMillionRoadPanel(cornerRadius: 24)

            ForEach(KenMillionRoadStore.KenMillionRoadScenarioResults) { scenario in
                KenMillionRoadScenarioRow(scenario: scenario)
            }
        }
    }
}

struct KenMillionRoadLearnScreen: View {
    var body: some View {
        KenMillionRoadScreen(title: "Capital Playbook", subtitle: "PRACTICAL GUIDES", balance: "\(KenMillionRoadKnowledgeBase.count) guides") {
            ForEach(KenMillionRoadKnowledgeBase) { article in
                KenMillionRoadArticleCard(article: article)
            }
        }
    }
}

struct KenMillionRoadReportsScreen: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore
    var KenMillionRoadShowToast: (String) -> Void

    var body: some View {
        KenMillionRoadScreen(title: "Monthly Review", subtitle: "CAPITAL CHECK-IN", balance: KenMillionRoadStore.KenMillionRoadProjectedTargetDateText) {
            KenMillionRoadReportHero()
            KenMillionRoadSourceMixCard()
            KenMillionRoadActionChecklist(KenMillionRoadShowToast: KenMillionRoadShowToast)
            KenMillionRoadPlanningInputsCard(KenMillionRoadShowToast: KenMillionRoadShowToast)
            KenMillionRoadInlineSettingsCard()
        }
    }
}

struct KenMillionRoadScreen<Content: View>: View {
    var title: String
    var subtitle: String
    var balance: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                KenMillionRoadHeader(title: title, subtitle: subtitle, balance: balance)
                content
            }
            .KenMillionRoadScreenPadding()
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct KenMillionRoadDashboardHero: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore

    var body: some View {
        VStack(spacing: 0) {
            Image("KenMillionRoadBackground")
                .resizable()
                .scaledToFill()
                .frame(height: 74)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.10), KenMillionRoadTheme.panel.opacity(0.88)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            ZStack(alignment: .trailing) {
                LinearGradient(
                    colors: [
                        KenMillionRoadTheme.panel,
                        Color(red: 0.28, green: 0.12, blue: 0.31)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                HStack(alignment: .bottom, spacing: -22) {
                    Image("KenMillionRoadBarbi")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 108)
                    Image("KenMillionRoadKen")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                }
                .padding(.trailing, 4)
                .padding(.bottom, 6)

                VStack(alignment: .leading, spacing: 10) {
                    Image("KenMillionRoadLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 128)

                    Text(KenMillionRoadStore.KenMillionRoadNetWorthText)
                        .font(.system(size: 32, weight: .black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text("Current style-capital value")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(KenMillionRoadTheme.gold)

                    Spacer(minLength: 0)

                    VStack(alignment: .leading, spacing: 7) {
                        HStack {
                            Text("\(KenMillionRoadStore.KenMillionRoadProgressText) complete")
                                .font(.system(size: 14, weight: .black))
                            Spacer()
                            Text(KenMillionRoadStore.KenMillionRoadRemainingText)
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(KenMillionRoadTheme.gold)
                        }
                        ProgressView(value: KenMillionRoadStore.KenMillionRoadProgress)
                            .tint(KenMillionRoadTheme.gold)
                    }
                    .padding(11)
                    .background(Color.black.opacity(0.42), in: RoundedRectangle(cornerRadius: 15))
                    .padding(.trailing, 54)
                }
                .padding(16)
            }
            .frame(height: 180)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 254)
        .background(KenMillionRoadTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(KenMillionRoadTheme.gold.opacity(0.42), lineWidth: 1.5))
    }
}

struct KenMillionRoadStatTile: View {
    var title: String
    var value: String
    var icon: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .black))
                .lineLimit(2)
                .minimumScaleFactor(0.62)
            Text(title)
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(KenMillionRoadTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .KenMillionRoadPanel()
    }
}

struct KenMillionRoadMoneyField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(KenMillionRoadTheme.muted)
            TextField(title, text: $text)
                .keyboardType(.decimalPad)
                .KenMillionRoadInputSurface()
        }
    }
}

struct KenMillionRoadLedgerSummary: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            KenMillionRoadStatTile(title: "Income", value: KenMillionRoadStore.KenMillionRoadCurrency(KenMillionRoadStore.KenMillionRoadMonthlyIncome), icon: "arrow.down.circle.fill", color: KenMillionRoadTheme.green)
            KenMillionRoadStatTile(title: "Expenses", value: KenMillionRoadStore.KenMillionRoadCurrency(KenMillionRoadStore.KenMillionRoadMonthlyExpenses), icon: "arrow.up.circle.fill", color: KenMillionRoadTheme.orange)
            KenMillionRoadStatTile(title: "Savings", value: KenMillionRoadStore.KenMillionRoadCurrency(KenMillionRoadStore.KenMillionRoadMonthlySavings), icon: "banknote.fill", color: KenMillionRoadTheme.gold)
            KenMillionRoadStatTile(title: "Rate", value: "\(Int(KenMillionRoadStore.KenMillionRoadSavingsRate * 100))%", icon: "percent", color: KenMillionRoadTheme.cyan)
        }
    }
}

struct KenMillionRoadCategoryBreakdownCard: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore

    var total: Double {
        max(1, KenMillionRoadStore.KenMillionRoadCategorySlices.reduce(0) { $0 + $1.value })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("Category Breakdown")
                .font(.system(size: 20, weight: .black))
            ForEach(KenMillionRoadStore.KenMillionRoadCategorySlices.filter { $0.value > 0 }) { slice in
                HStack(spacing: 10) {
                    Image(systemName: slice.category.icon)
                        .foregroundStyle(KenMillionRoadTheme.gold)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(slice.category.rawValue)
                                .font(.system(size: 13, weight: .black))
                            Spacer()
                            Text(KenMillionRoadStore.KenMillionRoadCurrency(slice.value))
                                .font(.system(size: 13, weight: .black))
                        }
                        ProgressView(value: slice.value / total)
                            .tint(KenMillionRoadTheme.gold)
                    }
                }
            }
            if KenMillionRoadStore.KenMillionRoadCategorySlices.allSatisfy({ $0.value == 0 }) {
                Text("Add income, expenses or savings to build your category report.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(KenMillionRoadTheme.muted)
            }
        }
        .padding(16)
        .KenMillionRoadPanel()
    }
}

struct KenMillionRoadLedgerList: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Records")
                .font(.system(size: 20, weight: .black))
            if KenMillionRoadStore.KenMillionRoadState.cashflowEntries.isEmpty {
                Text("No records yet. Add your first cashflow entry.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(KenMillionRoadTheme.muted)
            } else {
                ForEach(KenMillionRoadStore.KenMillionRoadState.cashflowEntries.prefix(10)) { entry in
                    KenMillionRoadLedgerRow(entry: entry)
                }
            }
        }
        .padding(16)
        .KenMillionRoadPanel()
    }
}

struct KenMillionRoadLedgerRow: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore
    var entry: KenMillionRoadLedgerEntry

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.category.icon)
                .foregroundStyle(entry.kind == .expense ? KenMillionRoadTheme.orange : KenMillionRoadTheme.green)
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.08), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.title)
                    .font(.system(size: 14, weight: .black))
                Text("\(entry.category.rawValue) · \(entry.kind.rawValue)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(KenMillionRoadTheme.muted)
            }
            Spacer()
            Text((entry.kind == .expense ? "-" : "+") + KenMillionRoadStore.KenMillionRoadCurrency(entry.amount))
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(entry.kind == .expense ? KenMillionRoadTheme.orange : KenMillionRoadTheme.gold)
        }
        .padding(10)
        .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct KenMillionRoadCapitalSubtractCard: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore
    @Binding var KenMillionRoadTitle: String
    @Binding var KenMillionRoadAmount: String
    var KenMillionRoadShowToast: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 10) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(KenMillionRoadTheme.orange)
                    .font(.system(size: 22, weight: .black))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Subtract from capital")
                        .font(.system(size: 20, weight: .black))
                    Text("Use this for withdrawals from money already accumulated on the route.")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(KenMillionRoadTheme.muted)
                }
            }
            TextField("Reason, e.g. emergency repair", text: $KenMillionRoadTitle)
                .KenMillionRoadInputSurface()
            TextField("Amount", text: $KenMillionRoadAmount)
                .keyboardType(.decimalPad)
                .KenMillionRoadInputSurface()
            Button {
                let value = Double(KenMillionRoadAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
                let message = KenMillionRoadStore.KenMillionRoadSubtractCapital(category: .lifestyle, title: KenMillionRoadTitle, amount: value)
                KenMillionRoadShowToast(message)
                if value > 0 {
                    KenMillionRoadTitle = ""
                    KenMillionRoadAmount = ""
                }
            } label: {
                Label("Record Withdrawal", systemImage: "minus")
            }
            .buttonStyle(KenMillionRoadSecondaryButtonStyle())
        }
        .padding(16)
        .KenMillionRoadPanel(cornerRadius: 24)
    }
}

struct KenMillionRoadTrendCard: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore

    var maxValue: Double {
        max(1, KenMillionRoadStore.KenMillionRoadMonthlyTrend.map { abs($0.value) }.max() ?? 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Runway Chart")
                    .font(.system(size: 20, weight: .black))
                Spacer()
                KenMillionRoadSmallPill(text: "6 months", color: KenMillionRoadTheme.cyan)
            }
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(KenMillionRoadStore.KenMillionRoadMonthlyTrend) { point in
                    VStack(spacing: 7) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: [KenMillionRoadTheme.gold, KenMillionRoadTheme.orange], startPoint: .top, endPoint: .bottom))
                            .frame(height: max(8, CGFloat(abs(point.value) / maxValue) * 104))
                        Text(point.title)
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(KenMillionRoadTheme.muted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 142, alignment: .bottom)
        }
        .padding(16)
        .KenMillionRoadPanel()
    }
}

struct KenMillionRoadLevelRoad: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("Marker Map")
                .font(.system(size: 20, weight: .black))
            ForEach(KenMillionRoadLevels) { level in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: level.colorHex).opacity(KenMillionRoadStore.KenMillionRoadState.currentNetWorth >= level.amount ? 1 : 0.26))
                            .frame(width: 46, height: 46)
                        Text("\(level.id)")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(KenMillionRoadTheme.abyss)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(level.title)
                            .font(.system(size: 15, weight: .black))
                        Text("\(KenMillionRoadStore.KenMillionRoadCurrency(level.amount)) · \(level.note)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(KenMillionRoadTheme.muted)
                    }
                    Spacer()
                    if KenMillionRoadStore.KenMillionRoadState.currentNetWorth >= level.amount {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(KenMillionRoadTheme.green)
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(16)
        .KenMillionRoadPanel()
    }
}

struct KenMillionRoadSliderRow: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore
    var title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    @State private var KenMillionRoadManualValue = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .black))
                Spacer()
                Text(KenMillionRoadStore.KenMillionRoadCurrency(value))
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(KenMillionRoadTheme.gold)
            }
            Slider(value: $value, in: range, step: 100)
                .tint(KenMillionRoadTheme.gold)
            HStack(spacing: 8) {
                TextField("Manual amount", text: $KenMillionRoadManualValue)
                    .keyboardType(.decimalPad)
                    .KenMillionRoadInputSurface()
                Button("Apply") {
                    let typed = Double(KenMillionRoadManualValue.replacingOccurrences(of: ",", with: ".")) ?? value
                    value = min(range.upperBound, max(range.lowerBound, typed))
                }
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(KenMillionRoadTheme.abyss)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(KenMillionRoadTheme.gold, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

struct KenMillionRoadMetricPill: View {
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value)
                .font(.system(size: 18, weight: .black))
            Text(title)
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(KenMillionRoadTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct KenMillionRoadScenarioRow: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore
    var scenario: KenMillionRoadScenarioResult

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: scenario.colorHex))
                .frame(width: 18, height: 18)
            VStack(alignment: .leading, spacing: 4) {
                Text(scenario.title)
                    .font(.system(size: 16, weight: .black))
                Text(scenario.note)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(KenMillionRoadTheme.muted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(scenario.months)m")
                    .font(.system(size: 18, weight: .black))
                Text(KenMillionRoadStore.KenMillionRoadCurrency(scenario.monthlySurplus))
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(KenMillionRoadTheme.gold)
            }
        }
        .padding(14)
        .KenMillionRoadPanel(cornerRadius: 18)
    }
}

struct KenMillionRoadArticleCard: View {
    var article: KenMillionRoadKnowledgeArticle

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(article.body, id: \.self) { paragraph in
                    Text(paragraph)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(KenMillionRoadTheme.muted)
                        .lineSpacing(3)
                }
            }
            .padding(.top, 10)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: article.icon)
                    .foregroundStyle(KenMillionRoadTheme.gold)
                    .frame(width: 34, height: 34)
                    .background(Color.white.opacity(0.08), in: Circle())
                VStack(alignment: .leading, spacing: 5) {
                    Text(article.title)
                        .font(.system(size: 17, weight: .black))
                    Text("\(article.readTime) · \(article.summary)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(KenMillionRoadTheme.muted)
                        .lineLimit(2)
                }
            }
        }
        .padding(16)
        .KenMillionRoadPanel(cornerRadius: 20)
    }
}

struct KenMillionRoadReportHero: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Monthly Monthly Review")
                .font(.system(size: 24, weight: .black))
            Text("A local summary based on your user-entered planning records.")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(KenMillionRoadTheme.muted)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                KenMillionRoadMetricPill(title: "Current capital", value: KenMillionRoadStore.KenMillionRoadNetWorthText)
                KenMillionRoadMetricPill(title: "Target gap", value: KenMillionRoadStore.KenMillionRoadRemainingText)
                KenMillionRoadMetricPill(title: "Best entry", value: KenMillionRoadStore.KenMillionRoadCurrency(KenMillionRoadStore.KenMillionRoadState.stats.bestEntry))
                KenMillionRoadMetricPill(title: "Records", value: "\(KenMillionRoadStore.KenMillionRoadState.stats.logCount)")
            }
        }
        .padding(16)
        .KenMillionRoadPanel(cornerRadius: 24)
    }
}

struct KenMillionRoadSourceMixCard: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore

    private var total: Double {
        max(1, KenMillionRoadStore.KenMillionRoadCategorySlices.reduce(0) { $0 + $1.value })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("Ledger Mix")
                .font(.system(size: 20, weight: .black))
            let activeSlices = KenMillionRoadStore.KenMillionRoadCategorySlices.filter { $0.value > 0 }
            if activeSlices.isEmpty {
                Text("Ledger records will appear here as a category mix for review.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(KenMillionRoadTheme.muted)
            }
            ForEach(activeSlices) { slice in
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        HStack(spacing: 7) {
                            Image(systemName: slice.category.icon)
                                .foregroundStyle(KenMillionRoadTheme.gold)
                            Text(slice.category.rawValue)
                        }
                            .font(.system(size: 13, weight: .black))
                        Spacer()
                        Text(KenMillionRoadStore.KenMillionRoadCurrency(slice.value))
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(KenMillionRoadTheme.gold)
                    }
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.08))
                            Capsule()
                                .fill(KenMillionRoadColorForCategory(slice.category))
                                .frame(width: proxy.size.width * CGFloat(slice.value / total))
                        }
                    }
                    .frame(height: 9)
                }
            }
        }
        .padding(16)
        .KenMillionRoadPanel()
    }
}

struct KenMillionRoadActionChecklist: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore
    var KenMillionRoadShowToast: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Move Board")
                .font(.system(size: 20, weight: .black))
            ForEach(KenMillionRoadStore.KenMillionRoadState.goals) { goal in
                HStack(spacing: 12) {
                    Image(systemName: goal.id.icon)
                        .foregroundStyle(goal.isComplete ? KenMillionRoadTheme.green : KenMillionRoadTheme.gold)
                        .frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.08), in: Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.id.rawValue)
                            .font(.system(size: 14, weight: .black))
                        ProgressView(value: Double(goal.progress), total: Double(goal.target))
                            .tint(goal.isComplete ? KenMillionRoadTheme.green : KenMillionRoadTheme.gold)
                    }
                    Button(goal.isComplete ? "Done" : "+1") {
                        KenMillionRoadShowToast(KenMillionRoadStore.KenMillionRoadIncrementGoal(goal.id))
                    }
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(goal.isComplete ? KenMillionRoadTheme.muted : KenMillionRoadTheme.abyss)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(goal.isComplete ? Color.white.opacity(0.08) : KenMillionRoadTheme.gold, in: Capsule())
                    .disabled(goal.isComplete)
                }
                .padding(12)
                .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(16)
        .KenMillionRoadPanel()
    }
}

struct KenMillionRoadInlineSettingsCard: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Studio Controls")
                .font(.system(size: 20, weight: .black))
            Toggle("Sound effects", isOn: $KenMillionRoadStore.KenMillionRoadState.sounds)
            Toggle("Haptics", isOn: $KenMillionRoadStore.KenMillionRoadState.haptics)
            Toggle("Reduced motion", isOn: $KenMillionRoadStore.KenMillionRoadState.reducedMotion)
            Button(role: .destructive) {
                KenMillionRoadStore.KenMillionRoadResetProgress()
            } label: {
                Label("Reset plan data", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(KenMillionRoadSecondaryButtonStyle())
            Text("Ken Million Road is a personal planning utility. It tracks user-entered progress only and does not provide financial advice, investment services, purchases, or cash rewards.")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(KenMillionRoadTheme.muted)
        }
        .padding(16)
        .KenMillionRoadPanel()
    }
}

struct KenMillionRoadPlanningInputsCard: View {
    @EnvironmentObject private var KenMillionRoadStore: KenMillionRoadLocalStore
    @State private var KenMillionRoadIncome = ""
    @State private var KenMillionRoadExpenses = ""
    @State private var KenMillionRoadSideIncome = ""
    @State private var KenMillionRoadTargetDate = Date()
    @State private var KenMillionRoadRisk = "Balanced"
    @State private var KenMillionRoadDidLoad = false
    var KenMillionRoadShowToast: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "slider.horizontal.below.rectangle")
                    .foregroundStyle(KenMillionRoadTheme.cyan)
                    .font(.system(size: 22, weight: .black))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Plan Inputs")
                        .font(.system(size: 20, weight: .black))
                    Text("Update salary, expenses and target assumptions without resetting progress.")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(KenMillionRoadTheme.muted)
                }
            }
            KenMillionRoadMoneyField(title: "Monthly income", text: $KenMillionRoadIncome)
            KenMillionRoadMoneyField(title: "Monthly expenses", text: $KenMillionRoadExpenses)
            KenMillionRoadMoneyField(title: "Side income", text: $KenMillionRoadSideIncome)
            DatePicker("Target review date", selection: $KenMillionRoadTargetDate, displayedComponents: .date)
                .font(.system(size: 13, weight: .bold))
            Picker("Planning style", selection: $KenMillionRoadRisk) {
                ForEach(["Conservative", "Balanced", "Ambitious"], id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.segmented)
            Button {
                let message = KenMillionRoadStore.KenMillionRoadUpdatePlanningInputs(
                    monthlyIncome: Double(KenMillionRoadIncome.replacingOccurrences(of: ",", with: ".")) ?? KenMillionRoadStore.KenMillionRoadState.monthlyIncome,
                    monthlyExpenses: Double(KenMillionRoadExpenses.replacingOccurrences(of: ",", with: ".")) ?? KenMillionRoadStore.KenMillionRoadState.monthlyExpenses,
                    sideIncome: Double(KenMillionRoadSideIncome.replacingOccurrences(of: ",", with: ".")) ?? KenMillionRoadStore.KenMillionRoadState.monthlySideIncome,
                    targetDate: KenMillionRoadTargetDate,
                    riskStyle: KenMillionRoadRisk
                )
                KenMillionRoadShowToast(message)
            } label: {
                Label("Refresh Plan", systemImage: "checkmark.circle.fill")
            }
            .buttonStyle(KenMillionRoadPrimaryButtonStyle())
        }
        .padding(16)
        .KenMillionRoadPanel(cornerRadius: 24)
        .onAppear {
            guard !KenMillionRoadDidLoad else { return }
            KenMillionRoadIncome = String(Int(KenMillionRoadStore.KenMillionRoadState.monthlyIncome))
            KenMillionRoadExpenses = String(Int(KenMillionRoadStore.KenMillionRoadState.monthlyExpenses))
            KenMillionRoadSideIncome = String(Int(KenMillionRoadStore.KenMillionRoadState.monthlySideIncome))
            KenMillionRoadTargetDate = KenMillionRoadStore.KenMillionRoadState.targetDate
            KenMillionRoadRisk = KenMillionRoadStore.KenMillionRoadState.riskStyle
            KenMillionRoadDidLoad = true
        }
    }
}

private func KenMillionRoadColorForCategory(_ category: KenMillionRoadLedgerCategory) -> Color {
    switch category.defaultKind {
    case .income: return KenMillionRoadTheme.green
    case .expense: return KenMillionRoadTheme.orange
    case .saving: return KenMillionRoadTheme.gold
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
        default:
            (r, g, b) = (255, 255, 255)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }
}
