import Foundation

enum PlatformServiceError: Error { case invalidData, missingStream, unsupported(String) }

private enum HTTP {
    static let ua = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Version/17.0 Mobile/15E148 Safari/604.1"
    static func url(_ base: String, _ query: [String: String]) -> URL? { var c=URLComponents(string:base); c?.queryItems=query.map{URLQueryItem(name:$0.key,value:$0.value)}; return c?.url }
    static func string(_ value: Any?) -> String { value.map(String.init(describing:)) ?? "" }
    static func dict(_ value: Any?) -> [String:Any] { value as? [String:Any] ?? [:] }
}

private enum WebExtraction {
    static func clean(_ value:String)->String { value.replacingOccurrences(of:"\\/",with:"/").replacingOccurrences(of:"\\u0026",with:"&").replacingOccurrences(of:"\\u003F",with:"?").replacingOccurrences(of:"\\u003d",with:"=").replacingOccurrences(of:"&amp;",with:"&") }
    static func urls(_ html:String)->[URL] {
        guard let regex=try? NSRegularExpression(pattern:#"https?:\\?/\\?/[^\"'<>\\\\ ]+"#) else{return[]}
        let ns=html as NSString; var result:[URL]=[]
        for m in regex.matches(in:html,range:NSRange(location:0,length:ns.length)) { let raw=clean(ns.substring(with:m.range)); guard raw.contains(".m3u8") || raw.contains(".flv") else{continue}; if let u=URL(string:raw),!result.contains(u){result.append(u)} }
        return result
    }
    static func links(_ html:String, pattern:String)->[String] {
        guard let regex=try? NSRegularExpression(pattern:pattern) else{return[]}; let ns=html as NSString
        return regex.matches(in:html,range:NSRange(location:0,length:ns.length)).compactMap{ $0.numberOfRanges>1 ? clean(ns.substring(with:$0.range(at:1))) : nil }
    }
}

private class JSONPlatformService: LivePlatformService, @unchecked Sendable {
    let platform:LivePlatform
    init(_ platform:LivePlatform){self.platform=platform}
    func search(keyword:String) async throws->[LiveRoom]{[]}
    func categories() async throws->[LiveCategory]{[]}
    func streams(for room:LiveRoom) async throws->[LiveStream]{[]}
    func messages(for room:LiveRoom)->AsyncThrowingStream<LiveMessage,Error>{AsyncThrowingStream{$0.finish()}}
    func get(_ url:URL,headers:[String:String]=[:]) async throws->Any { try await APIClient.shared.json(from:url,headers:headers) }
    func post(_ url:URL,body:[String:Any],headers:[String:String]=[:]) async throws->Any { var r=URLRequest(url:url); r.httpMethod="POST"; r.setValue("application/json",forHTTPHeaderField:"Content-Type"); headers.forEach{r.setValue($0.value,forHTTPHeaderField:$0.key)}; r.httpBody=try JSONSerialization.data(withJSONObject:body); let(d,res)=try await URLSession.shared.data(for:r); guard let h=res as? HTTPURLResponse,(200..<300).contains(h.statusCode) else{throw PlatformServiceError.invalidData}; return try JSONSerialization.jsonObject(with:d) }
    func room(_ id:String,title:String,nick:String,cover:String="",link:String="",watching:String="0")->LiveRoom { LiveRoom(roomId:id,link:link.isEmpty ? nil:URL(string:link),title:title,nick:nick,cover:URL(string:cover),watching:watching,platform:platform,status:true,liveStatus:"live") }
}

final class BilibiliService: JSONPlatformService {
    init(){super.init(.bilibili)}
    override func search(keyword:String) async throws->[LiveRoom]{ guard let u=HTTP.url("https://api.bilibili.com/x/web-interface/search/type",["search_type":"live","keyword":keyword,"page":"1"])else{throw PlatformServiceError.invalidData};let r=HTTP.dict(try await get(u,headers:["User-Agent":HTTP.ua,"Referer":"https://live.bilibili.com/"]));return (HTTP.dict(r["data"])["result"] as? [[String:Any]] ?? []).compactMap{x in let id=HTTP.string(x["roomid"]);guard !id.isEmpty else{return nil};return room(id,title:HTTP.string(x["title"]).replacingOccurrences(of:"<[^>]+>",with:"",options:.regularExpression),nick:HTTP.string(x["uname"]),cover:HTTP.string(x["cover"]),link:"https://live.bilibili.com/\(id)",watching:HTTP.string(x["online"]))} }
    override func categories() async throws->[LiveCategory]{guard let u=HTTP.url("https://api.live.bilibili.com/room/v1/Area/getList",["need_entrance":"1","parent_id":"0"])else{throw PlatformServiceError.invalidData};let r=HTTP.dict(try await get(u,headers:["User-Agent":HTTP.ua,"Referer":"https://live.bilibili.com/"]));return(r["data"] as? [[String:Any]] ?? []).map{x in LiveCategory(id:HTTP.string(x["id"]),name:HTTP.string(x["name"]),children:(x["list"] as? [[String:Any]] ?? []).map{LiveCategory(id:HTTP.string($0["id"]),name:HTTP.string($0["name"]),children:[])})}}
    override func streams(for room:LiveRoom) async throws->[LiveStream]{guard let id=room.roomId,let u=HTTP.url("https://api.live.bilibili.com/xlive/web-room/v2/index/getRoomPlayInfo",["room_id":id,"protocol":"0,1","format":"0,1,2","codec":"0","platform":"html5","dolby":"5"])else{throw PlatformServiceError.invalidData};let r=HTTP.dict(try await get(u,headers:["User-Agent":HTTP.ua,"Referer":"https://live.bilibili.com/\(id)"]));let p=HTTP.dict(HTTP.dict(HTTP.dict(r["data"])["playurl_info"])["playurl"]);var out:[LiveStream]=[];for s in p["stream"] as? [[String:Any]] ?? [] {for f in s["format"] as? [[String:Any]] ?? [] {for c in f["codec"] as? [[String:Any]] ?? [] {let base=HTTP.string(c["base_url"]);for i in c["url_info"] as? [[String:Any]] ?? [] {if let u=URL(string:HTTP.string(i["host"])+base+HTTP.string(i["extra"])){out.append(LiveStream(url:u,quality:"HLS",headers:["Referer":"https://live.bilibili.com/\(id)","User-Agent":HTTP.ua]))}}}}};return out}
}

final class DouyuService: JSONPlatformService {
    init(){super.init(.douyu)}
    override func search(keyword:String) async throws->[LiveRoom]{guard let u=HTTP.url("https://www.douyu.com/japi/search/api/searchShow",["kw":keyword,"page":"1","pageSize":"20"])else{throw PlatformServiceError.invalidData};let r=HTTP.dict(try await get(u,headers:["User-Agent":HTTP.ua,"Referer":"https://www.douyu.com/search/"]));return(HTTP.dict(r["data"])["relateShow"] as? [[String:Any]] ?? []).compactMap{x in let id=HTTP.string(x["rid"]);guard !id.isEmpty else{return nil};return room(id,title:HTTP.string(x["roomName"]),nick:HTTP.string(x["nickName"]),cover:HTTP.string(x["roomSrc"]),link:"https://www.douyu.com/\(id)")}}
    override func categories() async throws->[LiveCategory]{[LiveCategory(id:"1",name:"网游",children:[]),LiveCategory(id:"2",name:"单机",children:[]),LiveCategory(id:"8",name:"娱乐",children:[]),LiveCategory(id:"3",name:"手游",children:[])]}
    override func streams(for room:LiveRoom) async throws->[LiveStream]{guard let id=room.roomId,let u=URL(string:"https://www.douyu.com/lapi/live/getH5Play/\(id)")else{throw PlatformServiceError.invalidData};let r=HTTP.dict(try await get(u,headers:["Referer":"https://www.douyu.com/\(id)","User-Agent":HTTP.ua]));let d=HTTP.dict(r["data"]);guard let s=URL(string:"\(HTTP.string(d["rtmp_url"]))/\(HTTP.string(d["rtmp_live"]))")else{throw PlatformServiceError.missingStream};return[LiveStream(url:s,quality:"原画",headers:["Referer":"https://www.douyu.com/\(id)","User-Agent":HTTP.ua])]}
}

final class HuyaService: JSONPlatformService {
    init(){super.init(.huya)}
    override func search(keyword:String) async throws->[LiveRoom]{guard let u=HTTP.url("https://search.cdn.huya.com/",["m":"Search","do":"getSearchContent","q":keyword,"uid":"0","v":"4","typ":"-5","livestate":"0","rows":"20","start":"0"])else{throw PlatformServiceError.invalidData};let r=HTTP.dict(try await get(u));let list=HTTP.dict(HTTP.dict(r["response"])["3"])["docs"] as? [[String:Any]] ?? [];return list.compactMap{x in let id=HTTP.string(x["room_id"]);guard !id.isEmpty else{return nil};return room(id,title:HTTP.string(x["game_introduction"]),nick:HTTP.string(x["game_nick"]),cover:HTTP.string(x["game_screenshot"]),link:"https://www.huya.com/\(id)")}}
    override func categories() async throws->[LiveCategory]{[LiveCategory(id:"1",name:"网游",children:[]),LiveCategory(id:"2",name:"单机",children:[]),LiveCategory(id:"8",name:"娱乐",children:[]),LiveCategory(id:"3",name:"手游",children:[])]}
    override func streams(for room:LiveRoom) async throws->[LiveStream]{guard let id=room.roomId,let u=URL(string:"https://mp.huya.com/cache.php?m=Live&do=profileRoom&roomid=\(id)&showSecret=1")else{throw PlatformServiceError.invalidData};let r=HTTP.dict(try await get(u,headers:["User-Agent":HTTP.ua,"Referer":"https://www.huya.com/"]));let flv=HTTP.dict(HTTP.dict(HTTP.dict(r["data"])["stream"])["flv"]);return(flv["multiLine"] as? [[String:Any]] ?? []).compactMap{x in URL(string:HTTP.string(x["url"]))}.map{LiveStream(url:$0,quality:"原画",headers:["User-Agent":HTTP.ua,"Referer":"https://www.huya.com/"])} }
}

final class KuaishouService: JSONPlatformService {
    init(){super.init(.kuaishou)}
    private func page(_ id:String) async throws->String{guard let u=URL(string:"https://live.kuaishou.com/profile/\(id)")else{throw PlatformServiceError.invalidData};return try await PlatformWebSession.shared.loadHTML(url:u)}
    override func search(keyword:String) async throws->[LiveRoom]{guard let q=keyword.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed),let u=URL(string:"https://live.kuaishou.com/search?searchKey=\(q)")else{throw PlatformServiceError.invalidData};let h=try await PlatformWebSession.shared.loadHTML(url:u);let ids=Array(Set(WebExtraction.links(h,pattern:#"/u/([A-Za-z0-9_-]+)"#))).prefix(20);return ids.map{id in room(id,title:"快手直播",nick:id,link:"https://live.kuaishou.com/u/\(id)")}}
    override func categories() async throws->[LiveCategory]{guard let u=URL(string:"https://live.kuaishou.com/graphql")else{throw PlatformServiceError.invalidData};let body:[String:Any]=["operationName":"GetCategoryList","variables":["type":"brief","categoryCardList":true],"query":"query GetCategoryList($limit: Int, $type: String, $categoryCardList: Boolean) { categoryList(limit: $limit, type: $type, categoryCardList: $categoryCardList) { list { id categoryId text category title } } }"];let r=HTTP.dict(try await post(u,body:body,headers:["User-Agent":HTTP.ua,"Referer":"https://live.kuaishou.com/"]));let list=HTTP.dict(HTTP.dict(r["data"])["categoryList"])["list"] as? [[String:Any]] ?? [];return list.map{LiveCategory(id:HTTP.string($0["id"]),name:HTTP.string($0["text"] ?? $0["title"]),children:[])} }
    override func streams(for room:LiveRoom) async throws->[LiveStream]{guard let id=room.roomId else{throw PlatformServiceError.invalidData};var urls=WebExtraction.urls(try await page(id));if urls.isEmpty,let u=URL(string:"https://live.kuaishou.com/graphql"){let body:[String:Any]=["operationName":"LiveDetail","variables":["principalId":id],"query":"query LiveDetail($principalId: String) { liveDetail(principalId: $principalId) { liveStream } }"];let r=HTTP.dict(try await post(u,body:body,headers:["User-Agent":HTTP.ua,"Referer":"https://live.kuaishou.com/"]));let live=HTTP.dict(HTTP.dict(HTTP.dict(r["data"])["liveDetail"])["liveStream"]);if let p=live["playUrls"] as? [[String:Any]]{urls += p.compactMap{x in URL(string:WebExtraction.clean(HTTP.string(x["url"])))} }};guard !urls.isEmpty else{throw PlatformServiceError.missingStream};return urls.map{LiveStream(url:$0,quality:$0.pathExtension,headers:["Referer":"https://live.kuaishou.com/","User-Agent":HTTP.ua])}}
}

final class DouyinService: JSONPlatformService {
    init(){super.init(.douyin)}
    private func page(_ id:String) async throws->String{guard let u=URL(string:"https://live.douyin.com/\(id)")else{throw PlatformServiceError.invalidData};return try await PlatformWebSession.shared.loadHTML(url:u)}
    override func search(keyword:String) async throws->[LiveRoom]{guard let q=keyword.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed),let u=URL(string:"https://live.douyin.com/search/\(q)")else{throw PlatformServiceError.invalidData};let h=try await PlatformWebSession.shared.loadHTML(url:u);let ids=Array(Set(WebExtraction.links(h,pattern:#"/([0-9]{8,22})"#))).prefix(20);return ids.map{id in room(id,title:"抖音直播",nick:id,link:"https://live.douyin.com/\(id)")}}
    override func categories() async throws->[LiveCategory]{[LiveCategory(id:"0",name:"全部",children:[]),LiveCategory(id:"1",name:"娱乐",children:[]),LiveCategory(id:"2",name:"游戏",children:[]),LiveCategory(id:"3",name:"生活",children:[])]}
    override func streams(for room:LiveRoom) async throws->[LiveStream]{guard let id=room.roomId else{throw PlatformServiceError.invalidData};let urls=WebExtraction.urls(try await page(id));guard !urls.isEmpty else{throw PlatformServiceError.missingStream};return urls.map{LiveStream(url:$0,quality:$0.pathExtension,headers:["Referer":"https://live.douyin.com/\(id)","User-Agent":HTTP.ua])}}
}

final class NetEaseCCService: JSONPlatformService {
    init(){super.init(.neteaseCC)}
    private func page(_ id:String) async throws->String{guard let u=URL(string:"https://cc.163.com/\(id)")else{throw PlatformServiceError.invalidData};return try await PlatformWebSession.shared.loadHTML(url:u)}
    override func search(keyword:String) async throws->[LiveRoom]{guard let q=keyword.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed),let u=URL(string:"https://cc.163.com/search/?q=\(q)")else{throw PlatformServiceError.invalidData};let h=try await PlatformWebSession.shared.loadHTML(url:u);let ids=Array(Set(WebExtraction.links(h,pattern:#"/([0-9]{5,15})/?"#))).prefix(20);return ids.map{id in room(id,title:"网易CC直播",nick:id,link:"https://cc.163.com/\(id)")}}
    override func categories() async throws->[LiveCategory]{[LiveCategory(id:"game",name:"游戏",children:[]),LiveCategory(id:"ent",name:"娱乐",children:[])]}
    override func streams(for room:LiveRoom) async throws->[LiveStream]{guard let id=room.roomId else{throw PlatformServiceError.invalidData};let urls=WebExtraction.urls(try await page(id));guard !urls.isEmpty else{throw PlatformServiceError.missingStream};return urls.map{LiveStream(url:$0,quality:$0.pathExtension,headers:["Referer":"https://cc.163.com/\(id)","User-Agent":HTTP.ua])}}
}
