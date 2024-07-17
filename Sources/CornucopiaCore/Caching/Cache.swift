//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let logger = Cornucopia.Core.Logger(category: "Cache")

public extension Cornucopia.Core {

    protocol UrlCache {

        typealias DataCompletionHandler = (Data?) -> ()

        func loadDataFor(url: URL, then: @escaping(DataCompletionHandler))
        func loadDataFor(urlRequest: URLRequest, then: @escaping(DataCompletionHandler))
    }
    /// A simple cache for data gathered using a HTTP(s) GET call
    class Cache: UrlCache {

        var memoryCache = ThreadSafeDictionary<String, Data>()
        let name: String
        let path: String
        let urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.ephemeral)

        /// Loads the data for the specified `URL` and calls the completion handler with the data unless all cache levels fail.
        /// NOTE: The completion handler will be called in a background thread context.
        public func loadDataFor(url: URL, then: @escaping (DataCompletionHandler)) {
            let urlRequest = URLRequest(url: url)
            self.loadDataFor(urlRequest: urlRequest, then: then)
        }

        /// Loads the data for the specified `URLRequest` and calls the completion handler with the data unless all cache levels fail.
        /// NOTE: The completion handler will be called in a background thread context.
        public func loadDataFor(urlRequest: URLRequest, then: @escaping (DataCompletionHandler)) {
            // We're dispatching into a seperate parallel queue to not block the main queue with disk operations
            //FIXME: I'm almost sure that this is not fully concurrency safe. It is due for a rewrite when Swift 5.5 `actor`s are available
            DispatchQueue.global().async {

                let url = urlRequest.url!
                let md5 = url.absoluteString.CC_md5
                if let data = self.memoryCache[md5] {
                    logger.trace("Memory HIT for \(url)")
                    then(data)
                    return
                }
                logger.trace("Memory MISS \(url)")
                let pathInCache = self.path + "/\(md5)"
                let urlInCache = URL(fileURLWithPath: pathInCache)
                if FileManager.default.fileExists(atPath: pathInCache) {
                    logger.trace("Disk HIT for \(url)")
                    do {
                        let data = try Data(contentsOf: urlInCache, options: .alwaysMapped)
                        then(data)
                        self.memoryCache[md5] = data
                        return
                    } catch {
                        logger.debug("Can't load \(pathInCache): \(error)")
                    }
                }
                logger.trace("Disk MISS for \(url)")
                let task = self.urlSession.dataTask(with: urlRequest) { data, urlResponse, error in
                    guard error == nil else {
                        logger.notice("Network MISS for \(url): \(error!)")
                        then(nil)
                        return
                    }
                    let httpUrlResponse = urlResponse as! HTTPURLResponse
                    guard 199...299 ~= httpUrlResponse.statusCode else {
                        logger.notice("Network MISS for \(url): \(httpUrlResponse.statusCode)")
                        then(nil)
                        return
                    }
                    guard let data = data, data.count > 0 else {
                        logger.notice("Network MISS (0 bytes received) for \(url)")
                        then(nil)
                        return
                    }
                    logger.trace("Network HIT for \(url)")
                    then(data)
                    do {
                        try data.write(to: urlInCache, options: .atomic)
                    } catch {
                        logger.error("Can't write to \(urlInCache): \(error)")
                    }
                    self.memoryCache[md5] = data
                }
                task.resume()
            }
        }

        public init(name: String) {
            self.name = name
            self.path = FileManager.CC_pathInCachesDirectory(suffix: "Cornucopia.Core.Cache/\(name)/")
            do {
                try FileManager.default.createDirectory(atPath: self.path, withIntermediateDirectories: true)
                logger.debug("Using cache directory \(self.path)")
            } catch {
                logger.error("Can't create cache directory \(self.path): \(error)")
            }
        }
    }
}
