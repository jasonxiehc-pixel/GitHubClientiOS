import WidgetKit
import SwiftUI
import Intents

/*
struct Provider: IntentTimelineProvider {
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let repos = await fetchTrendingRepos(count: context.family.suggestedCount)
            let entry = SimpleEntry(date: Date(), repos: repos, configuration: configuration)
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let repos = await fetchTrendingRepos(count: context.family.suggestedCount)
            let entry = SimpleEntry(date: Date(), repos: repos, configuration: configuration)
            
            // 每小时刷新一次
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    // 获取趋势仓库数据
    private func fetchTrendingRepos(count: Int) async -> [Repository] {
        do {
            let service = GitHubService().shared
            let repos = try await service.fetchTrendingRepos(count: count)
            return repos
        } catch {
            print("Error fetching trending repos: \(error)")
            return [MockData.sampleRepo]
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let repos: [Repository]
    let configuration: ConfigurationIntent
}

struct TrendingRepoWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(repo: entry.repos.first ?? nil)
        case .systemMedium:
            MediumWidgetView(repos: entry.repos)
        case .systemLarge:
            LargeWidgetView(repos: entry.repos)
        default:
            Text(NSLocalizedString("不支持的尺寸", comment: ""))
        }
    }
}

// 小尺寸小组件
struct SmallWidgetView: View {
    let repo: Repository
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(NSLocalizedString("热门仓库", comment: ""))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(repo.name)
                .font(.headline)
                .lineLimit(1)
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 12))
                Text(repo.stargazersCount.formatted())
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// 中尺寸小组件
struct MediumWidgetView: View {
    let repos: [Repository]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("GitHub热门仓库", comment: ""))
                .font(.headline)
            
            ForEach(repos.prefix(3), id: \.id) { repo in
                HStack(alignment: .center, spacing: 8) {
                    AsyncImageView(urlStr: repo.owner.avatarUrl,
                                   avatarPlaceholder: Circle().foregroundColor(.secondary) as! String)
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                    
                    Text(repo.name)
                        .font(.subheadline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                        Text(repo.stargazersCount.formatted())
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// 大尺寸小组件
struct LargeWidgetView: View {
    let repos: [Repository]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("GitHub趋势仓库", comment: ""))
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

@main
struct TrendingRepoWidget: Widget {
    let kind: String = "TrendingRepoWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TrendingRepoWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(NSLocalizedString("GitHub趋势", comment: ""))
        .description(NSLocalizedString("展示GitHub热门仓库", comment: ""))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// 扩展WidgetFamily以获取建议的项目数量
extension WidgetFamily {
    var suggestedCount: Int {
        switch self {
        case .systemSmall: return 1
        case .systemMedium: return 3
        case .systemLarge: return 5
        default: return 1
        }
    }
}
 */
