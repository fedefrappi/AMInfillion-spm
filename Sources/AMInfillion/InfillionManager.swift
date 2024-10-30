import Foundation
import UIKit

public class InfillionManager {
    public struct Ad {
        public struct Response: Decodable {
            let name: String?
            let revenue_amount: String?
            let session_id: String?
            let request_id: String?
            let id: Int?
            let campaign_id: Int?
            let partner_id: Int?
            let error: String?
        }

        public let response: Response
        public let rawString: String
        public let userId: String
        public let placementKey: String
    }

    public init() {}

    public func request(userId: String, placementKey: String) async throws -> Ad {
        // can pass other parameters like age/gender
        // https://github.com/socialvibe/truex-ads-docs/blob/master/web_service_ad_api.md#get-parameters
        let requestParams = [
            URLQueryItem(name: "user.id", value: userId),
            URLQueryItem(name: "placement.key", value: placementKey)
        ]

        // build URL
        var urlComponents = URLComponents(string: "https://get.truex.com/v2")!
        urlComponents.queryItems = requestParams
        let url = urlComponents.url!

        print("fetchAdJson() Ad Request Url: ", url)

        // make ad request
        var adRequest = URLRequest(url: url)
        adRequest.httpMethod = "GET"

        let (data, _) = try await URLSession.shared.data(from: url)

        let jsonString = String(data: data, encoding: .utf8) ?? "{ \"error\": \"Failed to decode JSON\" }"
        let adResponse = try JSONDecoder().decode(Ad.Response.self, from: data)

        if let error = adResponse.error {
            throw NSError(domain: "Infillion", code: 1, userInfo: [NSLocalizedDescriptionKey: error])
        }

        return Ad(response: adResponse, rawString: jsonString, userId: userId, placementKey: placementKey)
    }

    @MainActor
    public func showAd(
        _ ad: Ad,
        on viewController: UIViewController,
        onStart: @escaping (_ ad: Ad) -> Void = { _ in },
        onCredit: @escaping (_ ad: Ad) -> Void = { _ in },
        onClickthrough: @escaping (_ ad: Ad) -> Void = { _ in },
        onFinish: @escaping (_ ad: Ad) -> Void = { _ in },
        onClose: @escaping (_ ad: Ad) -> Void = { _ in }
    ) {
        let vc = TruexAdViewController.instantiate(
            ad: ad,
            onStart: { _ in
                onStart(ad)
            },
            onCredit: { _ in
                onCredit(ad)
            },
            onClickthrough: { _ in
                onClickthrough(ad)
            },
            onFinish: { _ in
                onFinish(ad)
            },
            onClose: { vc in
                vc.dismiss(
                    animated: true,
                    completion: {
                        onClose(ad)
                    }
                )
            }
        )
        viewController.present(vc, animated: true, completion: nil)
    }
}
