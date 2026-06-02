import Foundation

final class KenMillionRoadLocalStore: ObservableObject {
    private enum KenMillionRoadKeys {
        static let state = "kenmillionroute_state_v1"
    }

    @Published var KenMillionRoadState: KenMillionRoadState {
        didSet { KenMillionRoadPersistState() }
    }

    init() {
        KenMillionRoadState = Self.KenMillionRoadRestoreState() ?? KenMillionRoad.KenMillionRoadState()
        KenMillionRoadNormalizeState()
    }

    var KenMillionRoadProgress: Double {
        min(1, max(0, KenMillionRoadState.currentNetWorth / KenMillionRoadState.targetAmount))
    }

    var KenMillionRoadProgressText: String {
        "\(Int(KenMillionRoadProgress * 100))%"
    }

    var KenMillionRoadNetWorthText: String {
        KenMillionRoadCurrency(KenMillionRoadState.currentNetWorth)
    }

    var KenMillionRoadRemainingText: String {
        KenMillionRoadCurrency(max(0, KenMillionRoadState.targetAmount - KenMillionRoadState.currentNetWorth))
    }

    var KenMillionRoadMonthlyLogged: Double {
        let calendar = Calendar.current
        return KenMillionRoadState.cashflowEntries
            .filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) && $0.kind != .expense }
            .reduce(0) { $0 + $1.amount }
    }

    var KenMillionRoadMonthlyIncome: Double {
        let logged = KenMillionRoadState.cashflowEntries.filter { $0.kind == .income }.reduce(0) { $0 + $1.amount }
        return logged > 0 ? logged : KenMillionRoadState.monthlyIncome + KenMillionRoadState.monthlySideIncome
    }

    var KenMillionRoadMonthlyExpenses: Double {
        let logged = KenMillionRoadState.cashflowEntries.filter { $0.kind == .expense }.reduce(0) { $0 + $1.amount }
        return logged > 0 ? logged : KenMillionRoadState.monthlyExpenses
    }

    var KenMillionRoadMonthlySavings: Double {
        let logged = KenMillionRoadState.cashflowEntries.filter { $0.kind == .saving }.reduce(0) { $0 + $1.amount }
        return logged > 0 ? logged : max(0, KenMillionRoadMonthlyIncome - KenMillionRoadMonthlyExpenses)
    }

    var KenMillionRoadMonthlySurplus: Double {
        max(0, KenMillionRoadMonthlyIncome - KenMillionRoadMonthlyExpenses)
    }

    var KenMillionRoadSavingsRate: Double {
        guard KenMillionRoadMonthlyIncome > 0 else { return 0 }
        return min(1, max(0, KenMillionRoadMonthlySurplus / KenMillionRoadMonthlyIncome))
    }

    var KenMillionRoadSourceSlices: [KenMillionRoadSourceSlice] {
        KenMillionRoadIncomeType.allCases.map { type in
            KenMillionRoadSourceSlice(
                type: type,
                value: KenMillionRoadState.entries.filter { $0.type == type }.reduce(0) { $0 + $1.amount }
            )
        }
    }

    var KenMillionRoadCategorySlices: [KenMillionRoadCategorySlice] {
        KenMillionRoadLedgerCategory.allCases.map { category in
            KenMillionRoadCategorySlice(
                category: category,
                value: KenMillionRoadState.cashflowEntries.filter { $0.category == category }.reduce(0) { $0 + $1.amount }
            )
        }
    }

    var KenMillionRoadMonthlyTrend: [KenMillionRoadMonthlyPoint] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return (0..<6).reversed().map { offset in
            let date = calendar.date(byAdding: .month, value: -offset, to: Date()) ?? Date()
            let total = KenMillionRoadState.cashflowEntries
                .filter { calendar.isDate($0.date, equalTo: date, toGranularity: .month) }
                .reduce(0) { $0 + ($1.kind == .expense ? -$1.amount : $1.amount) }
            return KenMillionRoadMonthlyPoint(title: formatter.string(from: date), value: total)
        }
    }

    var KenMillionRoadAverageEntry: Double {
        guard KenMillionRoadState.stats.logCount > 0 else { return 0 }
        return KenMillionRoadState.stats.totalLogged / Double(KenMillionRoadState.stats.logCount)
    }

    var KenMillionRoadProjectedMonths: Int {
        let monthly = max(1, KenMillionRoadMonthlyLogged > 0 ? KenMillionRoadMonthlyLogged : KenMillionRoadState.monthlyProfitTarget)
        return Int(ceil(max(0, KenMillionRoadState.targetAmount - KenMillionRoadState.currentNetWorth) / monthly))
    }

    var KenMillionRoadProjectedTargetDateText: String {
        let date = Calendar.current.date(byAdding: .month, value: KenMillionRoadProjectedMonths, to: Date()) ?? Date()
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    var KenMillionRoadNextMilestone: KenMillionRoadLevel {
        KenMillionRoadLevels.first(where: { KenMillionRoadState.currentNetWorth < $0.amount }) ?? KenMillionRoadLevels.last!
    }

    var KenMillionRoadScenarioResults: [KenMillionRoadScenarioResult] {
        let remaining = max(0, KenMillionRoadState.targetAmount - KenMillionRoadState.currentNetWorth)
        let base = max(1, KenMillionRoadMonthlySurplus)
        let scenarios: [(String, Double, String, String)] = [
            ("Current Pace", base, "Based on current income minus expenses.", "#35BDF2"),
            ("Save +10%", base + KenMillionRoadMonthlyIncome * 0.10, "If savings rate improves by ten points.", "#FFD042"),
            ("Side Income", base + max(400, KenMillionRoadState.monthlySideIncome), "If a repeatable extra income lane is added.", "#A95CFF"),
            ("Expense Cut", base + max(250, KenMillionRoadMonthlyExpenses * 0.08), "If recurring expenses are trimmed.", "#74D66A")
        ]
        return scenarios.map { title, monthly, note, color in
            KenMillionRoadScenarioResult(title: title, monthlySurplus: monthly, months: Int(ceil(remaining / max(1, monthly))), note: note, colorHex: color)
        }
    }

    var KenMillionRoadCurrentLevel: KenMillionRoadLevel {
        KenMillionRoadLevels.last(where: { KenMillionRoadState.currentNetWorth >= $0.amount }) ?? KenMillionRoadLevels[0]
    }

    func KenMillionRoadSelectTab(_ tab: KenMillionRoadTab) {
        KenMillionRoadState.selectedTab = tab
    }

    func KenMillionRoadAddEntry(type: KenMillionRoadIncomeType, title: String, amount: Double) -> String {
        guard amount > 0 else { return "Enter a positive amount." }
        let entry = KenMillionRoadProfitEntry(id: UUID(), type: type, title: title.isEmpty ? type.rawValue : title, amount: amount, date: Date())
        KenMillionRoadState.entries.insert(entry, at: 0)
        KenMillionRoadState.entries = Array(KenMillionRoadState.entries.prefix(80))
        KenMillionRoadState.currentNetWorth += amount
        KenMillionRoadState.stats.totalLogged += amount
        KenMillionRoadState.stats.bestEntry = max(KenMillionRoadState.stats.bestEntry, amount)
        KenMillionRoadState.stats.logCount += 1
        KenMillionRoadUpdateStreak()
        KenMillionRoadAdvanceGoal(.monthlyIncome, by: KenMillionRoadMonthlyLogged >= KenMillionRoadState.monthlyProfitTarget ? 1 : 0)
        if type == .investment { KenMillionRoadAdvanceGoal(.investingHabit, by: 1) }
        if type == .saving { KenMillionRoadAdvanceGoal(.emergencyFund, by: 1) }
        if type == .sideProject || type == .business { KenMillionRoadAdvanceGoal(.skillGrowth, by: 1) }
        return "+\(KenMillionRoadCurrency(amount)) added to the route."
    }

    func KenMillionRoadAddLedger(kind: KenMillionRoadLedgerKind, category: KenMillionRoadLedgerCategory, title: String, amount: Double) -> String {
        guard amount > 0 else { return "Enter a positive amount." }
        let entry = KenMillionRoadLedgerEntry(
            id: UUID(),
            kind: kind,
            category: category,
            title: title.isEmpty ? category.rawValue : title,
            amount: amount,
            date: Date()
        )
        KenMillionRoadState.cashflowEntries.insert(entry, at: 0)
        KenMillionRoadState.cashflowEntries = Array(KenMillionRoadState.cashflowEntries.prefix(140))
        if kind != .expense {
            KenMillionRoadState.currentNetWorth += amount
            KenMillionRoadState.stats.totalLogged += amount
            KenMillionRoadState.stats.bestEntry = max(KenMillionRoadState.stats.bestEntry, amount)
        }
        KenMillionRoadState.stats.logCount += 1
        KenMillionRoadUpdateStreak()
        if kind == .saving { KenMillionRoadAdvanceGoal(.emergencyFund, by: 1) }
        if category == .investment { KenMillionRoadAdvanceGoal(.investingHabit, by: 1) }
        if category == .sideIncome || category == .business { KenMillionRoadAdvanceGoal(.skillGrowth, by: 1) }
        return "\(kind.rawValue) saved."
    }

    func KenMillionRoadSubtractCapital(category: KenMillionRoadLedgerCategory, title: String, amount: Double) -> String {
        guard amount > 0 else { return "Enter a positive amount." }
        let entry = KenMillionRoadLedgerEntry(
            id: UUID(),
            kind: .expense,
            category: category,
            title: title.isEmpty ? "Capital withdrawal" : title,
            amount: amount,
            date: Date()
        )
        KenMillionRoadState.cashflowEntries.insert(entry, at: 0)
        KenMillionRoadState.cashflowEntries = Array(KenMillionRoadState.cashflowEntries.prefix(140))
        KenMillionRoadState.currentNetWorth = max(0, KenMillionRoadState.currentNetWorth - amount)
        KenMillionRoadState.stats.logCount += 1
        KenMillionRoadUpdateStreak()
        return "-\(KenMillionRoadCurrency(amount)) removed from capital."
    }

    func KenMillionRoadCompleteGoalBuilder(startingCapital: Double, monthlyIncome: Double, monthlyExpenses: Double, sideIncome: Double, targetDate: Date, riskStyle: String) {
        KenMillionRoadState.startingCapital = max(0, startingCapital)
        KenMillionRoadState.currentNetWorth = max(0, startingCapital)
        KenMillionRoadState.monthlyIncome = max(0, monthlyIncome)
        KenMillionRoadState.monthlyExpenses = max(0, monthlyExpenses)
        KenMillionRoadState.monthlySideIncome = max(0, sideIncome)
        KenMillionRoadState.monthlyProfitTarget = max(100, monthlyIncome + sideIncome - monthlyExpenses)
        KenMillionRoadState.targetDate = targetDate
        KenMillionRoadState.riskStyle = riskStyle
        KenMillionRoadState.hasCompletedGoalBuilder = true
    }

    func KenMillionRoadUpdatePlanningInputs(monthlyIncome: Double, monthlyExpenses: Double, sideIncome: Double, targetDate: Date, riskStyle: String) -> String {
        KenMillionRoadState.monthlyIncome = max(0, monthlyIncome)
        KenMillionRoadState.monthlyExpenses = max(0, monthlyExpenses)
        KenMillionRoadState.monthlySideIncome = max(0, sideIncome)
        KenMillionRoadState.monthlyProfitTarget = max(100, monthlyIncome + sideIncome - monthlyExpenses)
        KenMillionRoadState.targetDate = targetDate
        KenMillionRoadState.riskStyle = riskStyle
        return "Planning inputs updated."
    }

    func KenMillionRoadSkipGoalBuilder() {
        KenMillionRoadState.hasCompletedGoalBuilder = true
    }

    func KenMillionRoadAdjustTarget(_ value: Double) {
        KenMillionRoadState.monthlyProfitTarget = max(100, value)
    }

    func KenMillionRoadResetProgress() {
        var state = KenMillionRoad.KenMillionRoadState()
        state.sounds = KenMillionRoadState.sounds
        state.haptics = KenMillionRoadState.haptics
        state.reducedMotion = KenMillionRoadState.reducedMotion
        KenMillionRoadState = state
    }

    func KenMillionRoadCompleteGoal(_ goal: KenMillionRoadGoalType) -> String {
        guard let index = KenMillionRoadState.goals.firstIndex(where: { $0.id == goal }) else { return "Goal not found." }
        KenMillionRoadState.goals[index].progress = KenMillionRoadState.goals[index].target
        KenMillionRoadState.goals[index].isComplete = true
        return "\(goal.rawValue) marked complete."
    }

    func KenMillionRoadIncrementGoal(_ goal: KenMillionRoadGoalType) -> String {
        guard let index = KenMillionRoadState.goals.firstIndex(where: { $0.id == goal }) else { return "Goal not found." }
        guard !KenMillionRoadState.goals[index].isComplete else { return "\(goal.rawValue) is already complete." }
        KenMillionRoadState.goals[index].progress = min(KenMillionRoadState.goals[index].target, KenMillionRoadState.goals[index].progress + 1)
        KenMillionRoadState.goals[index].isComplete = KenMillionRoadState.goals[index].progress >= KenMillionRoadState.goals[index].target
        return "\(goal.rawValue) progress updated."
    }

    func KenMillionRoadCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let amount = formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
        return "$\(amount)"
    }

    private func KenMillionRoadAdvanceGoal(_ goal: KenMillionRoadGoalType, by amount: Int) {
        guard amount > 0, let index = KenMillionRoadState.goals.firstIndex(where: { $0.id == goal }) else { return }
        KenMillionRoadState.goals[index].progress = min(KenMillionRoadState.goals[index].target, KenMillionRoadState.goals[index].progress + amount)
        KenMillionRoadState.goals[index].isComplete = KenMillionRoadState.goals[index].progress >= KenMillionRoadState.goals[index].target
    }

    private func KenMillionRoadUpdateStreak() {
        let calendar = Calendar.current
        if let last = KenMillionRoadState.stats.lastLogDate {
            if calendar.isDateInYesterday(last) {
                KenMillionRoadState.stats.streak += 1
            } else if !calendar.isDateInToday(last) {
                KenMillionRoadState.stats.streak = 1
            }
        } else {
            KenMillionRoadState.stats.streak = 1
        }
        KenMillionRoadState.stats.lastLogDate = Date()
    }

    private func KenMillionRoadNormalizeState() {
        if KenMillionRoadState.entries.isEmpty && KenMillionRoadState.stats.logCount == 0 && KenMillionRoadState.currentNetWorth == 24_500 {
            KenMillionRoadState.currentNetWorth = 0
        }
        if KenMillionRoadState.cashflowEntries.isEmpty && !KenMillionRoadState.entries.isEmpty {
            KenMillionRoadState.cashflowEntries = KenMillionRoadState.entries.map {
                KenMillionRoadLedgerEntry(id: $0.id, kind: .income, category: .business, title: $0.title, amount: $0.amount, date: $0.date)
            }
        }
        for type in KenMillionRoadGoalType.allCases where !KenMillionRoadState.goals.contains(where: { $0.id == type }) {
            KenMillionRoadState.goals.append(KenMillionRoadGoal(id: type, progress: 0, target: type == .monthlyIncome ? 12 : 5, isComplete: false))
        }
    }

    private func KenMillionRoadPersistState() {
        guard let data = try? JSONEncoder().encode(KenMillionRoadState) else { return }
        UserDefaults.standard.set(data, forKey: KenMillionRoadKeys.state)
    }

    private static func KenMillionRoadRestoreState() -> KenMillionRoadState? {
        guard let data = UserDefaults.standard.data(forKey: KenMillionRoadKeys.state) else { return nil }
        return try? JSONDecoder().decode(KenMillionRoad.KenMillionRoadState.self, from: data)
    }
}
