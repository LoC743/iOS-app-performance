//
//  Feed.swift
//  SocialAppVK
//
//  Created by Alexey on 16.12.2020.
//

import RealmSwift

class News: Object {
    @objc dynamic var sourceID: Int = -1
    @objc dynamic var text: String = ""
    @objc dynamic var date: Int = -1
    @objc dynamic var photo: VKImage?
    @objc dynamic var commentCount: Int = -1
    @objc dynamic var likesCount: Int = -1
    @objc dynamic var isUserLikes: Bool = false
    @objc dynamic var repostsCount: Int = -1
    @objc dynamic var viewsCount: Int = -1
    
    convenience init(sourceID: Int, text: String, date: Int, photo: VKImage, commentCount: Int, likesCount: Int, isUserLikes: Bool, repostsCount: Int, viewsCount: Int) {
        self.init()
        
        self.sourceID = sourceID
        self.text = text
        self.date = date
        self.photo = photo
        self.commentCount = commentCount
        self.likesCount = likesCount
        self.isUserLikes = isUserLikes
        self.repostsCount = repostsCount
        self.viewsCount = viewsCount
    }
}

class Feed: Decodable {
    var newsArray: [News] = []
    var groups: [Group] = []
    var nextFrom = ""
    
    enum ResponseCodingKeys: String, CodingKey {
        case response
    }
    
    enum ItemsCodingKeys: String, CodingKey {
        case items
        case profiles
        case groups
        case nextFrom = "next_from"
    }
    
    enum NewsCodingKeys: String, CodingKey {
        case sourceID = "source_id"
        case date
        case text
        case comments
        case likes
        case views
        case reposts
        case attachments
    }
    
    enum CommentsCodingKeys: String, CodingKey {
        case count
    }
    
    enum LikesCodingKeys: String, CodingKey {
        case count
        case userLikes = "user_likes"
    }
    
    enum RepostsCodingKeys: String, CodingKey {
        case count
    }
    
    enum ViewsCodingKeys: String, CodingKey {
        case count
    }
    
    enum AttachmentsCodingKeys: String, CodingKey {
        case type
        case photo
    }
    
    enum PhotoCodingKeys: String, CodingKey {
        case sizes
    }
    
    enum SizesCodingKeys: String, CodingKey {
        case url
        case width
        case height
    }
    
    enum GroupCodingKeys: String, CodingKey {
        case id
        case isMember = "is_member"
        case name
        case photo_50
        case photo_100
        case photo_200
    }
    
    required init(from decoder: Decoder) throws {
        let response = try decoder.container(keyedBy: ResponseCodingKeys.self)
        let items = try response.nestedContainer(keyedBy: ItemsCodingKeys.self, forKey: .response)
        let nextFrom = try items.decode(String.self, forKey: .nextFrom)
        self.nextFrom = nextFrom
        
        let dispatchGroup = DispatchGroup()

        DispatchQueue.global(qos: .utility).async(group: dispatchGroup) {
            var groups = try! items.nestedUnkeyedContainer(forKey: .groups)

            let groupCount = groups.count ?? 0
            for q in 0..<groupCount {

                let groupContainer = try! groups.nestedContainer(keyedBy: GroupCodingKeys.self)

                let id = try! groupContainer.decode(Int.self, forKey: .id)
                let name = try! groupContainer.decode(String.self, forKey: .name)

                let isMemberInt = try? groupContainer.decode(Int.self, forKey: .isMember)
                let isMemberBool = isMemberInt == 0 ? false : true

                let photo_50 = try! groupContainer.decode(String.self, forKey: .photo_50)
                let photo_100 = try! groupContainer.decode(String.self, forKey: .photo_100)
                let photo_200 = try! groupContainer.decode(String.self, forKey: .photo_200)

                let photo = Photo(photo_50: photo_50, photo_100: photo_100, photo_200: photo_200)
                let group = Group(id: id, isMember: isMemberBool, name: name, photo: photo, order: q)

                DispatchQueue.main.async {
                    self.groups.append(group)
                }
            }
        }
        
        dispatchGroup.wait()

        DispatchQueue.global(qos: .utility).async(group: dispatchGroup) {
            var news = try! items.nestedUnkeyedContainer(forKey: .items)

            let newsCount = news.count ?? 0
            for _ in 0..<newsCount {
                let newsContainer = try! news.nestedContainer(keyedBy: NewsCodingKeys.self)

                let sourceID = try! newsContainer.decode(Int.self, forKey: .sourceID)
                let text = try? newsContainer.decode(String.self, forKey: .text)
                let date = try! newsContainer.decode(Int.self, forKey: .date)

                let commentsContainer = try? newsContainer.nestedContainer(keyedBy: CommentsCodingKeys.self, forKey: .comments)
                let commentsCount = try? commentsContainer?.decode(Int.self, forKey: .count)

                let likesContainer = try? newsContainer.nestedContainer(keyedBy: LikesCodingKeys.self, forKey: .likes)
                let likesCount: Int = try! likesContainer?.decode(Int.self, forKey: .count) ?? 0
                let isUserLikesInt: Int = try! likesContainer?.decode(Int.self, forKey: .userLikes) ?? 0
                let isUserLikesBool = isUserLikesInt == 0 ? false : true

                let repostsContainer = try? newsContainer.nestedContainer(keyedBy: RepostsCodingKeys.self, forKey: .reposts)
                let repostsCount: Int = try! repostsContainer?.decode(Int.self, forKey: .count) ?? 0
                
                let viewsContainer = try? newsContainer.nestedContainer(keyedBy: ViewsCodingKeys.self, forKey: .views)
                let viewsCount: Int = try! viewsContainer?.decode(Int.self, forKey: .count) ?? 0

                let attachments = try? newsContainer.nestedUnkeyedContainer(forKey: .attachments)

                if let attachments = attachments {
                    var attachments = attachments
                    let attachmentsCount = attachments.count ?? 0
                    for _ in 0..<attachmentsCount {
                        let attachmentsContainer = try! attachments.nestedContainer(keyedBy: AttachmentsCodingKeys.self)

                        let type = try! attachmentsContainer.decode(String.self, forKey: .type)

                        if type != "photo" {
                            break
                        }


                        let photoContainer = try! attachmentsContainer.nestedContainer(keyedBy: PhotoCodingKeys.self, forKey: .photo)
                        var sizes = try! photoContainer.nestedUnkeyedContainer(forKey: .sizes)
                        let sizesCount = sizes.count ?? 0
                        for z in 0..<sizesCount {
                            let sizeContainer = try! sizes.nestedContainer(keyedBy: SizesCodingKeys.self)
                            let url = try! sizeContainer.decode(String.self, forKey: .url)
                            let width = try! sizeContainer.decode(Int.self, forKey: .width)
                            let height = try! sizeContainer.decode(Int.self, forKey: .height)

                            if z == sizesCount-1 {
                                let photo = VKImage(url: url, height: height, width: width)
                                let news = News(sourceID: sourceID,
                                                text: text ?? "",
                                                date: date,
                                                photo: photo,
                                                commentCount: commentsCount ?? 0,
                                                likesCount: likesCount,
                                                isUserLikes: isUserLikesBool,
                                                repostsCount: repostsCount,
                                                viewsCount: viewsCount)

                                DispatchQueue.main.async {
                                    self.newsArray.append(news)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        dispatchGroup.wait()

        dispatchGroup.notify(queue: DispatchQueue.main) {
//            print(self.groups)
//            print(self.newsArray)
        }
    }
}
