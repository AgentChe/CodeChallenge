//
//  ImageService.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 22/07/2022.
//

import Foundation
import UIKit
import Combine
import SVGKit

protocol ImageServiceProtocol {
    func loadImage(with url: String, cacheEnabled: Bool) -> AnyPublisher<Resolvable<UIImage>, Never>
}

final class ImageService: ImageServiceProtocol {
    private let session: URLSession = {
        let urlCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,
            diskCapacity: 500 * 1024 * 1024,
            directory: nil
        )
        let config = URLSessionConfiguration.default
//        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = urlCache
        config.allowsCellularAccess = true
        config.httpMaximumConnectionsPerHost = 10
        let session = URLSession(configuration: config)
        return session
    }()

    private let imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 10 * 1024 * 1024
        cache.countLimit = 500
        return cache
    }()

    private var urlToPublisher = [String: AnyPublisher<Resolvable<UIImage>, Never>]()

    func loadImage(with url: String, cacheEnabled: Bool) -> AnyPublisher<Resolvable<UIImage>, Never> {
        let cacheKey = url as NSString
        if let image = imageCache.object(forKey: cacheKey), cacheEnabled {
            return Just(.success(image)).eraseToAnyPublisher()
        }
        guard let url = URL(string: url) else {
            return Just(.failure(NetworkError.invalidURL)).eraseToAnyPublisher()
        }
        if let existing = urlToPublisher[cacheKey as String] {
            return existing
        }
        let request = URLRequest(url: url)
        let publisher =
            session
                .dataTaskPublisher(for: request)
                .tryMap { result -> (UIImage, Int) in
                    if let image = UIImage(data: result.data) {
                        return (image, result.data.count)
                    }
                    if let svgImage = SVGKImage(data: result.data) {
                        return (svgImage.uiImage, result.data.count)
                    }
                    throw NetworkError.invalidResponse
                }
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveOutput: { [weak self] (image, cost) in
                    self?.imageCache.setObject(image, forKey: cacheKey, cost: cost)
                }, receiveCompletion: { [weak self] _ in
                    self?.urlToPublisher.removeValue(forKey: cacheKey as String)
                })
                .map { $0.0 }
                .asResolvable()
                .share()
                .eraseToAnyPublisher()
        urlToPublisher[cacheKey as String] = publisher
        return publisher
    }
}
