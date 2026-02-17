//
//  ResourceUtils.swift
//  GamificationPackage
//
//  Created by Kashif Hussain on 16/11/25.
//

import Foundation


public struct ResourceUtils {
    
    public static func launchS3Resourse(_ filePath: String) -> String {
       
        let isBlobeEnabled =  SwiftUtilityEnvironment.shared.isBlobEnabled
        
        if filePath.contains("content.gogetempowered.com") {
            return filePath
        }
        var pathFinal = filePath
        if pathFinal.contains(":10000"){
            pathFinal = pathFinal.replace(":10000", replacement: APIConst.lxpPath)
        }
       // pathFinal = pathFinal.replace("https:", replacement: "http:")
        pathFinal = pathFinal.replace("\\", replacement: "/")
        if !isBlobeEnabled {
            if pathFinal.contains("https://assets") {
                if let url = URL(string: pathFinal),
                   var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let baseURL = URL(string: APIConst.baseURL),
                   let baseComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) {
                    
                    // Replace scheme and host with values from APIConst.baseURL.
                    components.scheme = baseComponents.scheme
                    components.host = baseComponents.host
                    
                    // Directly replace "org-content" with the static oilPath value.
                    components.path = components.path.replacingOccurrences(of: "org-content", with: APIConst.lxpOPath)
                    
                    if let updatedURL = components.url {
                        pathFinal = updatedURL.absoluteString
                    }
                }
            }else if(pathFinal.contains("assets")){
                pathFinal = APIConst.baseURL+"/"+pathFinal
            }else if pathFinal.first == "/"{
                pathFinal = APIConst.baseURL+APIConst.lxpBlobPath+pathFinal
            } else if pathFinal.contains(APIConst.lxpOPath) {
                
            }else  if pathFinal.contains("org-content"){
                pathFinal = pathFinal.replace("org-content", replacement: APIConst.lxpOPath)
            }else{
                pathFinal = APIConst.baseURL+APIConst.lxpBlobPath1+pathFinal
            }
            
        }else{
            if let url = URL(string: pathFinal), url.scheme?.hasPrefix("https") == true {
                pathFinal = pathFinal.replacingHost(with: "content.gogetempowered.com")
                let orgcode = SwiftUtilityEnvironment.shared.orgCode
                if !orgcode.isEmpty {
                    if pathFinal.contains(orgcode), let arrayPath = pathFinal.components(separatedBy: orgcode).last {
                        pathFinal = [APIConst.ContentPath,orgcode].joinWithPathSeparator()
                        pathFinal += arrayPath
                    } else if pathFinal.contains(APIConst.lxpOPath) || pathFinal.contains("org-content") {
                        if let arrayPath = pathFinal.components(separatedBy: "org-content").last {
                            pathFinal = [APIConst.ContentPath, orgcode].joinWithPathSeparator()
                            pathFinal += arrayPath
                        }
                    }
                } else if pathFinal.contains(APIConst.lxpOPath) || pathFinal.contains("org-content") {
                    if let arrayPath = pathFinal.components(separatedBy: "org-content").last {
                        pathFinal = APIConst.ContentPath + arrayPath
                    }
                }
            } else if pathFinal.first == "/" {
                pathFinal = APIConst.ContentPath + pathFinal
            } else if pathFinal.contains(APIConst.lxpOPath) || pathFinal.contains("org-content") {
                if let arrayPath = pathFinal.components(separatedBy: "org-content").last {
                    pathFinal = APIConst.ContentPath + arrayPath
                }
            } else if pathFinal.contains("www") {
                pathFinal = pathFinal.replacingOccurrences(of: "www", with: "content")
            } else {
                pathFinal = APIConst.ContentPath + "/" + pathFinal
            }
        }
        
        //pathFinal = pathFinal.replace("https:", replacement: "http:")
        pathFinal = pathFinal.replace("\\", replacement: "/")
        
        return pathFinal
    }

   

    public static func s3_thumbnail_path(filePath: String) -> String {
        
        let isBlobStorageEnabled =  SwiftUtilityEnvironment.shared.isBlobEnabled
        
        if  !isBlobStorageEnabled {
            var pathFinal = filePath.removeExtraCharactor()
            if pathFinal.contains("https://") {
                return pathFinal
            } else if(pathFinal.contains("assets")){
                pathFinal = APIConst.baseURL+"/"+pathFinal
            }else if pathFinal.first == "/"{
                pathFinal = APIConst.baseURL+APIConst.lxpBlobPath+pathFinal
            } else if pathFinal.contains(APIConst.lxpOPath) {
                
            }else  if pathFinal.contains("org-content"){
                pathFinal = pathFinal.replace("org-content", replacement: APIConst.lxpOPath)
            }else{
                pathFinal = APIConst.baseURL+APIConst.lxpBlobPath1+pathFinal
            }
            //  strUrl = strUrl.replace("https:", replacement: "http:")
            pathFinal = pathFinal.replace("\\", replacement: "/")
            return pathFinal
        } else {
            
            if filePath.contains("https://") {
                return filePath
            }
            
            if filePath.contains("content.gogetempowered.com")  {
                return filePath
            }
            var pathFinal = filePath.removeExtraCharactor()
            let orgCode = SwiftUtilityEnvironment.shared.orgCode

            
            pathFinal = pathFinal.replace("http:", replacement: "https:")
            pathFinal = pathFinal.replace("\\", replacement: "/")
            pathFinal = pathFinal.replace(" ", replacement: "%20")
            
            if(pathFinal.contains("assets")){
                if pathFinal.hasPrefix("/") {
                    return APIConst.ContentPath+pathFinal
                } else {
                    return APIConst.ContentPath+"/"+pathFinal
                }
            }
            
            if pathFinal.contains(orgCode) {
                let imgURLs = pathFinal.components(separatedBy: orgCode)
                if imgURLs[1].hasPrefix("/") {
                    return APIConst.ContentPath+"/"+orgCode+imgURLs[1]
                } else {
                    return APIConst.ContentPath+"/"+orgCode+"/"+imgURLs[1]
                }
                
            } else {
                if filePath.contains(APIConst.baseURL) {
                    if pathFinal.contains(APIConst.lxpOPath) {
                        return pathFinal
                    } else if pathFinal.contains(":10000"){
                        pathFinal = pathFinal.replace(":10000", replacement: APIConst.lxpBlobPath)
                        return pathFinal
                    } else if pathFinal.contains("org-content") {
                        pathFinal = pathFinal.replace("org-content", replacement: APIConst.lxpOPath)
                        return pathFinal
                    }
                    return pathFinal
                } else {
                    if pathFinal.hasPrefix("/") {
                        return APIConst.ContentPath+pathFinal
                    } else {
                        return APIConst.ContentPath+"/"+pathFinal
                    }
                }
            }
            
        }
    }
    

    public static func sanatiseUrlString(_ urlString: String) -> String {
        return urlString.removeExtraCharactor().manageExtraCha()
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }

    public static func getResourceURLPath(_ path: String?) -> URL? {
        guard let path = path else { return nil }
        
        let sanitizedPath = sanatiseUrlString(path)
        let resourceFilePath = ResourceUtils.launchS3Resourse(sanitizedPath)
        
        return URL(string: resourceFilePath)
    }
    

    

    public static func getParsedThumbnailPath(_ thumbnailPath: String) -> String {
        let path = sanatiseUrlString(thumbnailPath)
        return ResourceUtils.s3_thumbnail_path(filePath: path)
    }
    
    public static func getParsedThumbnailPathURL(_ thumbnailPath: String) -> URL? {
        let resourceURL = ResourceUtils.getParsedThumbnailPath(thumbnailPath)
        return URL(string: resourceURL)
    }
    
    
    public static func getResourcPath(_ path: String?) -> String {
        guard let path = path else { return "" }
        
        let sanitizedPath = sanatiseUrlString(path)
        let resourceFilePath = ResourceUtils.launchS3Resourse(sanitizedPath)
        
        return  resourceFilePath
    }
    
    
    public static func convertDateFormatBasedOnConfigParam(_ dateStr: String, forceIncludeTime: Bool = true) -> String {
        
        let (parsedDate , hasTimeComponent) = dynamicDateFormat(dateStr)
        
        guard let date = parsedDate else {
            return "Invalid date"
        }
        
        // Build output format based on detected time component and force flag
        var configFormat = SwiftUtilityEnvironment.shared.getConfiguaredDate
        if hasTimeComponent && forceIncludeTime {
            configFormat += ", h:mm a"
        }
        
        Self.outputFormatter.dateFormat = configFormat
        
        return Self.outputFormatter.string(from: date)
    }
    
    
    public static func dynamicDateFormat(_ dateStr: String) -> (date: Date?, hasTimeComponent: Bool) {
        
        // Try parsing with all formatters
        var parsedDate: Date?
        var hasTimeComponent = false
        
        // Check which formatter successfully parses and whether it has time
        if let date = Self.isoFormatter.date(from: dateStr) {
            parsedDate = date
            // Check for time component and exclude midnight (00:00:00)
            if dateStr.contains("T") && dateStr.count > 10 {
                let timeComponent = String(dateStr.split(separator: "T").last ?? "")
                hasTimeComponent = !timeComponent.hasPrefix("00:00:00")
            }
        } else if let date = Self.isoWithFractionalFormatter.date(from: dateStr) {
            parsedDate = date
            // Check for time component and exclude midnight (00:00:00)
            if dateStr.contains("T") && dateStr.count > 10 {
                let timeComponent = String(dateStr.split(separator: "T").last ?? "")
                hasTimeComponent = !timeComponent.hasPrefix("00:00:00")
            }
        } else if let date = Self.standardWithTimezoneFormatter.date(from: dateStr) {
            parsedDate = date
            // Check for time component (format: yyyy-MM-dd HH:mm:ss +0000)
            let components = dateStr.components(separatedBy: " ")
            if components.count >= 2 {
                let timeComponent = components[1]
                hasTimeComponent = !timeComponent.hasPrefix("00:00:00")
            }
        } else if let date = Self.standardDateOnlyFormatter.date(from: dateStr) {
            parsedDate = date
            // Date only format, no time component
            hasTimeComponent = false
        } else if let date = Self.usFormatter.date(from: dateStr) {
            parsedDate = date
            // Check if US format includes time (e.g., "MM/dd/yyyy HH:mm:ss")
            if dateStr.components(separatedBy: " ").count > 1 {
                let components = dateStr.components(separatedBy: " ")
                if components.count > 1 {
                    let timeComponent = components[1]
                    hasTimeComponent = !timeComponent.hasPrefix("00:00:00")
                }
            }
        }
        
        return (parsedDate, hasTimeComponent)
    }
    
    
    // Static formatters - created once and reused
    private static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    // New formatter for ISO dates with fractional seconds
    private static let isoWithFractionalFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let usFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let outputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()

    
    // Add this static formatter with your other formatters
    public static let standardWithTimezoneFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    public static let standardDateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

}
