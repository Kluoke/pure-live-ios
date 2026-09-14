import Foundation

// Native adapters. Provider-specific signing/parsing lives here so SwiftUI never
// depends on a platform's wire format.

enum PlatformServiceError: Error { case invalidData, missingStream }

private enum HTTP {
    static let ua = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Version/17.0 Mobile/15E148 Safari/604.1"
    static func url(_ base: String, _ query: [String: String]) -> URL? {
        var c = URLComponents(string: base); c?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }; return c?.url
    }
    static func string(_ value: Any?) -> String { value.map(String.init(describing:)) ?? "" }
    static func dict(_ value: Any?) -> [String: Any] { value as? [String: Any] ?? [:] }
}

private class JSONPlatformService: LivePlatformService {
    let platform: LivePlatform
    init(_ platform: LivePlatform) { self.platform = platform }
    func search(keyword: String) async throws -> [LiveRoom] { [] }
    func categories() async throws -> [LiveCategory] { [] }
    func streams(for room: LiveRoom) async throws -> [LiveStream] { [] }
    func messages(for room: LiveRoom) -> AsyncThrowingStream<LiveMessage, Error> { AsyncThrowingStream { $0.finish() } }
    func get(_ url: URL, headers: [String: String] = [:]) async throws -> Any { try await APIClient.shared.json(from: url, headers: headers) }
    func room(_ id: String, title: String, nick: String, cover: String = "", link: String = "") -> LiveRoom {
        LiveRoom(roomId: id, link: link.isEmpty ? nil : URL(string: link), title: title, nick: nick, cover: URL(string: cover), platform: platform)
    }
}

final class BilibiliService: JSONPlatformService {
    private var imgKey = "", subKey = ""
    init() { super.init(.bilibili) }

    override func search(keyword: String) async throws -> [LiveRoom] {
        guard let url = HTTP.url("https://api.bilibili.com/x/web-interface/search/type", ["search_type":"live", "keyword":keyword, "page":"1"]) else { throw PlatformServiceError.invalidData }
        let root = HTTP.dict(try await get(url, headers: ["User-Agent":HTTP.ua, "Referer":"https://live.bilibili.com/"]))
        let data = HTTP.dict(root["data"]); let list = data["result"] as? [[String:Any]] ?? []
        return list.compactMap { x in
            let id = HTTP.string(x["roomid"]); guard !id.isEmpty else { return nil }
            return room(id, title: HTTP.string(x["title"]).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression), nick: HTTP.string(x["uname"]), cover: HTTP.string(x["cover"]), link: "https://live.bilibili.com/\(id)")
        }
    }

    override func categories() async throws -> [LiveCategory] {
        guard let url = HTTP.url("https://api.live.bilibili.com/room/v1/Area/getList", ["need_entrance":"1", "parent_id":"0"]) else { throw PlatformServiceError.invalidData }
        let root = HTTP.dict(try await get(url, headers: ["User-Agent":HTTP.ua, "Referer":"https://live.bilibili.com/"]))
        return (root["data"] as? [[String:Any]] ?? []).map { item in
            let children = (item["list"] as? [[String:Any]] ?? []).map { LiveCategory(id: HTTP.string($0["id"]), name: HTTP.string($0["name"]), children: []) }
            return LiveCategory(id: HTTP.string(item["id"]), name: HTTP.string(item["name"]), children: children)
        }
    }

    override func streams(for room: LiveRoom) async throws -> [LiveStream] {
        guard let id = room.roomId, let url = HTTP.url("https://api.live.bilibili.com/xlive/web-room/v2/index/getRoomPlayInfo", ["room_id":id,"protocol":"0,1","format":"0,1,2","codec":"0","platform":"html5","dolby":"5"]) else { throw PlatformServiceError.invalidData }
        let root = HTTP.dict(try await get(url, headers: ["User-Agent":HTTP.ua,"Referer":"https://live.bilibili.com/\(id)"]))
        let data = HTTP.dict(root["data"]); let play = HTTP.dict(data["playurl_info"]); let p = HTTP.dict(play["playurl"])
        var result: [LiveStream] = []
        for stream in p["stream"] as? [[String:Any]] ?? [] { for format in stream["format"] as? [[String:Any]] ?? [] { for codec in format["codec"] as? [[String:Any]] ?? [] {
            let base = HTTP.string(codec["base_url"]); for info in codec["url_info"] as? [[String:Any]] ?? [] { if let u = URL(string: HTTP.string(info["host"]) + base + HTTP.string(info["extra"])) { result.append(LiveStream(url:u, quality:"HLS", headers:["Referer":"https://live.bilibili.com/\(id)","User-Agent":HTTP.ua])) } }
        }}}
        return result
    }
}

final class DouyuService: JSONPlatformService {
    init() { super.init(.douyu) }
    override func search(keyword: String) async throws -> [LiveRoom] {
        guard let url = HTTP.url("https://www.douyu.com/japi/search/api/searchShow", ["kw":keyword,"page":"1","pageSize":"20"]) else { throw PlatformServiceError.invalidData }
        let root = HTTP.dict(try await get(url, headers:["User-Agent":HTTP.ua,"Referer":"https://www.douyu.com/search/"]))
        let data = HTTP.dict(root["data"]); return (data["relateShow"] as? [[String:Any]] ?? []).compactMap { x in
            let id=HTTP.string(x["rid"]); guard !id.isEmpty else{return nil}; return room(id,title:HTTP.string(x["roomName"]),nick:HTTP.string(x["nickName"]),cover:HTTP.string(x["roomSrc"]),link:"https://www.douyu.com/\(id)")
        }
    }
    override func categories() async throws -> [LiveCategory] {
        guard let u=URL(string:"https://m.douyu.com/api/cate/list") else{throw PlatformServiceError.invalidData}; let r=HTTP.dict(try await get(u)); let d=HTTP.dict(r["data"]); let subs=d["cate2Info"] as? [[String:Any]] ?? []
        return (d["cate1Info"] as? [[String:Any]] ?? []).map { p in let id=HTTP.string(p["cate1Id"]); return LiveCategory(id:id,name:HTTP.string(p["cate1Name"]),children:subs.filter{HTTP.string($0["cate1Id"])==id}.map{LiveCategory(id:HTTP.string($0["cate2Id"]),name:HTTP.string($0["cate2Name"]),children:[])}) }
    }
    override func streams(for room: LiveRoom) async throws -> [LiveStream] {
        guard let id=room.roomId, let u=URL(string:"https://www.douyu.com/lapi/live/getH5Play/\(id)") else{throw PlatformServiceError.invalidData}
        let r=HTTP.dict(try await get(u,headers:["Referer":"https://www.douyu.com/\(id)","User-Agent":HTTP.ua])); let d=HTTP.dict(r["data"]); let base=HTTP.string(d["rtmp_url"]); let live=HTTP.string(d["rtmp_live"]); guard let stream=URL(string:"\(base)/\(live)") else{throw PlatformServiceError.missingStream}; return [LiveStream(url:stream,quality:"原画",headers:["Referer":"https://www.douyu.com/\(id)","User-Agent":HTTP.ua])]
    }
}

final class HuyaService: JSONPlatformService {
    init(){super.init(.huya)}
    override func search(keyword:String) async throws -> [LiveRoom] { guard let u=HTTP.url("https://search.cdn.huya.com/",["m":"Search","do":"getSearchContent","q":keyword,"uid":"0","v":"4","typ":"-5","livestate":"0","rows":"20","start":"0"]) else{throw PlatformServiceError.invalidData}; let r=HTTP.dict(try await get(u)); let resp=HTTP.dict(r["response"]); let list=HTTP.dict(resp["3"])["docs"] as? [[String:Any]] ?? []; return list.compactMap{ x in let id=HTTP.string(x["room_id"]); guard !id.isEmpty else{return nil}; return room(id,title:HTTP.string(x["game_introduction"]),nick:HTTP.string(x["game_nick"]),cover:HTTP.string(x["game_screenshot"]),link:"https://www.huya.com/\(id)") } }
    override func categories() async throws -> [LiveCategory] { [LiveCategory(id:"1",name:"网游",children:[]),LiveCategory(id:"2",name:"单机",children:[]),LiveCategory(id:"8",name:"娱乐",children:[]),LiveCategory(id:"3",name:"手游",children:[])] }
    override func streams(for room:LiveRoom) async throws -> [LiveStream] { guard let id=room.roomId, let u=URL(string:"https://mp.huya.com/cache.php?m=Live&do=profileRoom&roomid=\(id)&showSecret=1") else{throw PlatformServiceError.invalidData}; let r=HTTP.dict(try await get(u,headers:["User-Agent":HTTP.ua,"Referer":"https://www.huya.com/"])); let d=HTTP.dict(r["data"]); let s=HTTP.dict(d["stream"]); let flv=HTTP.dict(s["flv"]); let lines=flv["multiLine"] as? [[String:Any]] ?? []; return lines.compactMap{x in URL(string:HTTP.string(x["url"]))}.map{LiveStream(url:$0,quality:"原画",headers:["User-Agent":HTTP.ua,"Referer":"https://www.huya.com/"])} }
}

final class KuaishouService: JSONPlatformService { init(){super.init(.kuaishou)} override func search(keyword:String) async throws->[LiveRoom]{ guard let u=URL(string:"https://live.kuaishou.com/search?searchKey=\(keyword.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) ?? keyword)") else{throw PlatformServiceError.invalidData}; _=try await get(u); return [] } }
final class DouyinService: JSONPlatformService { init(){super.init(.douyin)} override func search(keyword:String) async throws->[LiveRoom]{ guard let u=URL(string:"https://live.douyin.com/") else{throw PlatformServiceError.invalidData}; _=try await get(u,headers:["User-Agent":HTTP.ua]); return [] } }
final class NetEaseCCService: JSONPlatformService { init(){super.init(.neteaseCC)} override func search(keyword:String) async throws->[LiveRoom]{ guard let u=URL(string:"https://cc.163.com/search/?q=\(keyword.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) ?? keyword)") else{throw PlatformServiceError.invalidData}; _=try await get(u); return [] } }
