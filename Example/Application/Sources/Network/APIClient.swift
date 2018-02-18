//
//  APIClient.swift
//  Example
//
//  Created by David Jennes on 04/01/2017.
//  Copyright © 2017 Appwise. All rights reserved.
//

import Alamofire
import AlamofireCoreData
import AppwiseCore
import CocoaLumberjack
import Nuke
import NukeAlamofirePlugin
import p2_OAuth2

final class APIClient: Client {
	typealias RouterType = APIRouter

	static let shared = APIClient()

	let oauth2 = OAuth2CodeGrant(settings: env(
		.dev([
			"client_id": "",
			"client_secret": "",
			"authorize_uri": "https://test.com/authorize",
			"token_uri": "https://test.com/token",
			"redirect_uris": ["https://test.com/authorization_callback"]
		]),
		.stg([
			"client_id": "",
			"client_secret": "",
			"authorize_uri": "https://test.com/authorize",
			"token_uri": "https://test.com/token",
			"redirect_uris": ["https://test.com/authorization_callback"]
		]),
		.prd([
			"client_id": "",
			"client_secret": "",
			"authorize_uri": "https://test.com/authorize",
			"token_uri": "https://test.com/token",
			"redirect_uris": ["https://test.com/authorization_callback"]
		])
	)).then {
		$0.authConfig.authorizeEmbedded = true
		$0.clientConfig.secretInBody = true
		#if DEBUG
		$0.logger = OAuth2DebugLogger(.trace)
		#endif
		}

	lazy private(set) var sessionManager: SessionManager = SessionManager().then {
		let retrier = OAuth2RetryHandler(oauth2: self.oauth2)
		$0.adapter = retrier
		$0.retrier = retrier
	}

	lazy private(set) var nuke: Nuke.Manager = {
		let loader = Nuke.Loader(loader: NukeAlamofirePlugin.DataLoader(manager: self.sessionManager))
		return Nuke.Manager(loader: loader, cache: Cache.shared)
	}()
}

extension APIClient {
	enum ServerError: Swift.Error, LocalizedError {
		case invalidData
		case message(String)
		case unauthorized

		var errorDescription: String? {
			switch self {
			case .invalidData:
				return "Invalid data response."
			case .message(let message):
				return message
			case .unauthorized:
				return "Unauthorized access, session may have expired."
			}
		}
	}

	static func extract<T>(from response: DataResponse<T>, error: Error) -> Error {
		if let status = response.response?.statusCode, status == 401 || status == 403 {
			return ServerError.unauthorized
		}

		guard let data = response.data,
			let json = try? JSONSerialization.jsonObject(with: data, options: []),
			let result = json as? [[String: String]],
			let message = result.first?["message"] else { return error }

		return ServerError.message(message)
	}
}
