import Foundation

enum KenMillionRoadLaunchDestination: Equatable {
    case native
    case web(URL)
    case offline
}

enum KenMillionRoadTab: String, CaseIterable, Identifiable, Codable {
    case route = "Studio"
    case cashflow = "Ledger"
    case simulate = "Forecast"
    case learn = "Playbook"
    case reports = "Review"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .route: return "suitcase.fill"
        case .cashflow: return "tray.full.fill"
        case .simulate: return "slider.horizontal.3"
        case .learn: return "book.closed.fill"
        case .reports: return "doc.text.magnifyingglass"
        }
    }
}

enum KenMillionRoadLedgerKind: String, Codable, CaseIterable, Identifiable {
    case income = "Income"
    case expense = "Expense"
    case saving = "Saving"

    var id: String { rawValue }
}

enum KenMillionRoadIncomeType: String, Codable, CaseIterable, Identifiable {
    case salary = "Salary"
    case business = "Business"
    case sideProject = "Side Project"
    case investment = "Investment"
    case saving = "Saving"

    var id: String { rawValue }
}

struct KenMillionRoadProfitEntry: Identifiable, Codable {
    let id: UUID
    var type: KenMillionRoadIncomeType
    var title: String
    var amount: Double
    var date: Date
}

enum KenMillionRoadLedgerCategory: String, Codable, CaseIterable, Identifiable {
    case salary = "Salary"
    case business = "Business"
    case sideIncome = "Side Income"
    case investment = "Investment Growth"
    case housing = "Housing"
    case food = "Food"
    case transport = "Transport"
    case lifestyle = "Lifestyle"
    case debt = "Debt"
    case savings = "Savings"

    var id: String { rawValue }

    var defaultKind: KenMillionRoadLedgerKind {
        switch self {
        case .salary, .business, .sideIncome, .investment: return .income
        case .savings: return .saving
        case .housing, .food, .transport, .lifestyle, .debt: return .expense
        }
    }

    var icon: String {
        switch self {
        case .salary: return "briefcase.fill"
        case .business: return "building.2.fill"
        case .sideIncome: return "sparkles"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .housing: return "house.fill"
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .lifestyle: return "bag.fill"
        case .debt: return "creditcard.fill"
        case .savings: return "banknote.fill"
        }
    }
}

struct KenMillionRoadLedgerEntry: Identifiable, Codable {
    let id: UUID
    var kind: KenMillionRoadLedgerKind
    var category: KenMillionRoadLedgerCategory
    var title: String
    var amount: Double
    var date: Date
}

enum KenMillionRoadGoalType: String, Codable, CaseIterable, Identifiable {
    case emergencyFund = "Emergency Fund"
    case monthlyIncome = "Monthly Income"
    case investingHabit = "Investing Habit"
    case skillGrowth = "Skill Growth"
    case debtCleanup = "Debt Cleanup"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .emergencyFund: return "shield.fill"
        case .monthlyIncome: return "calendar.badge.plus"
        case .investingHabit: return "chart.pie.fill"
        case .skillGrowth: return "graduationcap.fill"
        case .debtCleanup: return "scissors"
        }
    }
}

struct KenMillionRoadGoal: Identifiable, Codable {
    let id: KenMillionRoadGoalType
    var progress: Int
    var target: Int
    var isComplete: Bool
}

struct KenMillionRoadStats: Codable {
    var totalLogged = 0.0
    var bestEntry = 0.0
    var logCount = 0
    var streak = 0
    var lastLogDate: Date?
}

struct KenMillionRoadState: Codable {
    var targetAmount = 1_000_000.0
    var currentNetWorth = 0.0
    var startingCapital = 0.0
    var monthlyIncome = 5_000.0
    var monthlyExpenses = 3_200.0
    var monthlySideIncome = 600.0
    var targetDate = Calendar.current.date(byAdding: .year, value: 12, to: Date()) ?? Date()
    var riskStyle = "Balanced"
    var hasCompletedGoalBuilder = false
    var monthlyProfitTarget = 6_000.0
    var selectedTab = KenMillionRoadTab.route
    var entries: [KenMillionRoadProfitEntry] = []
    var cashflowEntries: [KenMillionRoadLedgerEntry] = []
    var goals: [KenMillionRoadGoal] = KenMillionRoadGoalType.allCases.map {
        KenMillionRoadGoal(id: $0, progress: 0, target: $0 == .monthlyIncome ? 12 : 5, isComplete: false)
    }
    var stats = KenMillionRoadStats()
    var sounds = true
    var haptics = true
    var reducedMotion = false
}

struct KenMillionRoadMonthlyPoint: Identifiable {
    let id = UUID()
    let title: String
    let value: Double
}

struct KenMillionRoadSourceSlice: Identifiable {
    let id = UUID()
    let type: KenMillionRoadIncomeType
    let value: Double
}

struct KenMillionRoadCategorySlice: Identifiable {
    let id = UUID()
    let category: KenMillionRoadLedgerCategory
    let value: Double
}

struct KenMillionRoadKnowledgeArticle: Identifiable {
    let id: String
    let title: String
    let readTime: String
    let summary: String
    let body: [String]
    let icon: String
}

struct KenMillionRoadScenarioResult: Identifiable {
    let id = UUID()
    let title: String
    let monthlySurplus: Double
    let months: Int
    let note: String
    let colorHex: String
}

struct KenMillionRoadLevel: Identifiable {
    let id: Int
    let title: String
    let amount: Double
    let colorHex: String
    let note: String
}

let KenMillionRoadLevels: [KenMillionRoadLevel] = [
    KenMillionRoadLevel(id: 1, title: "Starter Spark", amount: 1_000, colorHex: "#FF78D6", note: "Begin with a visible first reserve."),
    KenMillionRoadLevel(id: 2, title: "Style Base", amount: 10_000, colorHex: "#64E1FF", note: "Turn tracking into a repeatable habit."),
    KenMillionRoadLevel(id: 3, title: "Runway Fifty", amount: 50_000, colorHex: "#FFD25A", note: "Build enough space to choose calmly."),
    KenMillionRoadLevel(id: 4, title: "Six-Figure Set", amount: 100_000, colorHex: "#FF6767", note: "Strengthen income lanes and protection."),
    KenMillionRoadLevel(id: 5, title: "Quarter Club", amount: 250_000, colorHex: "#D96BFF", note: "Review systems before scaling harder."),
    KenMillionRoadLevel(id: 6, title: "Halfway Luxe", amount: 500_000, colorHex: "#7BF3A5", note: "Protect the plan and remove waste."),
    KenMillionRoadLevel(id: 7, title: "Million Mark", amount: 1_000_000, colorHex: "#F7C93D", note: "Reach the long-term seven-figure target.")
]

let KenMillionRoadKnowledgeBase: [KenMillionRoadKnowledgeArticle] = [
    KenMillionRoadKnowledgeArticle(id: "savings-rate", title: "Keep Rate", readTime: "7 min", summary: "The core number behind a realistic capital plan.", body: ["Savings rate is the percentage of income that remains after recurring expenses. The simple formula is: monthly surplus divided by monthly income. If income is $5,000 and expenses are $3,500, the surplus is $1,500 and the savings rate is 30%.", "This number is useful because it compares lifestyle and progress on the same scale. A larger salary does not automatically create a faster route if expenses rise at the same speed. A smaller income with controlled spending can sometimes produce a stronger path.", "In Ken Million Road, the Dashboard shows your savings rate from the values you enter in Ledger. Use it as a trend signal, not a judgment. The goal is to notice whether the route is getting easier or heavier month by month.", "A practical review question: which one repeatable change would improve the rate this month without making the plan impossible to maintain?"], icon: "percent"),
    KenMillionRoadKnowledgeArticle(id: "cashflow", title: "Ledger System", readTime: "8 min", summary: "Separate income, expenses, savings and capital changes.", body: ["Ledger is the movement of money through the month. Income brings resources in, expenses move resources out, and savings are the part intentionally kept for future progress.", "A useful system separates planned monthly flow from current capital. Rent, food and transport affect monthly surplus. A capital withdrawal is different: it reduces the amount already accumulated on the route. That is why the app includes both normal expense tracking and a separate subtract-from-capital action.", "Start with broad categories instead of trying to classify every tiny purchase. Salary, business, side income, housing, food, transport, lifestyle, debt and savings are enough to reveal the main pattern.", "When a category keeps growing, ask whether it is temporary, seasonal or structural. Temporary costs can be noted and watched. Structural costs need a plan, because they repeat and change the projected date."], icon: "arrow.left.arrow.right"),
    KenMillionRoadKnowledgeArticle(id: "emergency", title: "Reserve First", readTime: "6 min", summary: "Why early milestones should protect the plan.", body: ["A reserve is money kept for unexpected events. It is not exciting, but it prevents one problem from breaking the whole routemap.", "The first milestones in the app are intentionally smaller than $1M. Reaching $1,000, then $10,000 and $50,000 creates visible progress and helps the user build a habit before the final target feels realistic.", "A reserve can also reduce emotional decisions. If an unexpected cost appears, the plan has a buffer. If the buffer is used, log the capital withdrawal and rebuild the reserve before pushing aggressively toward the next stage.", "A practical rule: when progress feels slow, check whether the current milestone is too large. Smaller milestones make behavior easier to repeat."], icon: "shield.fill"),
    KenMillionRoadKnowledgeArticle(id: "scenarios", title: "Scenario Planning", readTime: "9 min", summary: "Test big income jumps and expense changes before acting.", body: ["A scenario is a safe estimate. It lets you ask: what happens if monthly income grows, if expenses drop, or if a new side income appears?", "Large changes matter. A $30,000 monthly income increase completely changes the timeline, so the simulator supports bigger ranges and manual values. This is useful for users planning a promotion, business month, commission cycle or major contract.", "The important comparison is not only the best case. Compare the current pace, an income-growth route, an expense-control route and a combined route. A good plan usually survives more than one version of the future.", "Remember that scenario results are local calculations based on user-entered data. They are planning estimates, not financial advice or investment projections."], icon: "slider.horizontal.3"),
    KenMillionRoadKnowledgeArticle(id: "review", title: "Monthly Review", readTime: "7 min", summary: "Turn records into a concrete next action.", body: ["A monthly review should answer three questions: what increased capital, what reduced momentum, and what should be changed next month?", "Use the Reports tab to compare current capital, target gap, best entry, record count and category mix. These are simple signals, but together they show whether the routemap is supported by real behavior.", "If the month was strong, identify the repeatable cause. Was it salary, side income, lower expenses or savings discipline? If the month was weak, identify whether the issue was income, spending, debt, or a one-time capital withdrawal.", "End every review with one next action. Examples: add one more income lane, reduce a recurring subscription, rebuild reserve, or update planning inputs because salary changed."], icon: "doc.text.fill"),
    KenMillionRoadKnowledgeArticle(id: "inputs", title: "Updating The Plan", readTime: "5 min", summary: "When salary, expenses or goals change, the routemap should change too.", body: ["A routemap is only useful if the assumptions stay current. If salary changes, expenses rise, a side project starts, or the target date becomes unrealistic, update the planning inputs instead of resetting the whole app.", "The app keeps accumulated capital and records, while allowing monthly income, monthly expenses, side income, target date and planning style to be adjusted in Reports.", "Use updates sparingly but honestly. Changing inputs every day creates noise. Updating them after a real life change keeps projections meaningful.", "A good habit is to review assumptions once per month after entering the month’s cashflow records."], icon: "pencil.and.list.clipboard")
]
