//
//  DownloadView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 25.07.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornTorrent
import PopcornKit
import Kingfisher

struct DownloadView: View {
    @StateObject var viewModel: DownloadViewModel
    @State var showDeleteActionSheet = false
    @State var showActionSheet: Bool = false
    
    var body: some View {
        Group {
            navigationLink
            
            Button(action: {
                showActionSheet = true
            }, label: {
                VStack {
                    ZStack (alignment: .bottom) {
                        KFImage(URL(string: imageUrl))
                            .resizable()
                            .placeholder {
                                Image(placeholderImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        if viewModel.download.downloadStatus == .downloading {
                            ProgressView(value: viewModel.download.torrentStatus.totalProgress)
                                .padding([.leading, .trailing, .bottom], 15)
                        }
                    }
        //                .padding(.bottom, 5)
                    Text(title)
                        .font(.system(size: 28, weight: .medium))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .shadow(color: .init(white: 0, opacity: 0.6), radius: 2, x: 0, y: 1)
                        .padding(0)
                        .zIndex(10)
        //                .frame(height: 80)
                    Text(detailText)
                        .font(.system(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .shadow(color: .init(white: 0, opacity: 0.6), radius: 2, x: 0, y: 1)
                        .padding(0)
                        .zIndex(10)
                }
            })
            .buttonStyle(PlainNavigationLinkButtonStyle())
        }
        .actionSheet(isPresented: $showDeleteActionSheet) {
            deleteActionSheet
        }
        .actionSheet(isPresented: $showActionSheet) {
            actionSheet
        }
    }
    
    @ViewBuilder
    var navigationLink: some View {
        switch viewModel.selection {
        case .some(.preload):
            NavigationLink(
                destination: PreloadTorrentView(viewModel: viewModel.preloadTorrentModel!),
                tag: .preload,
                selection: $viewModel.selection) {
                    EmptyView()
            }
        case .some(.play):
            NavigationLink(
                destination: PlayerView().environmentObject(viewModel.playerModel!),
                tag: .play,
                selection: $viewModel.selection) {
                    EmptyView()
                }
        case nil: EmptyView()
        }
    }
    
    var placeholderImage: String {
        return viewModel.download.show != nil ? "Episode Placeholder" : "Movie Placeholder"
    }
    
    var imageUrl: String {
        return (viewModel.download.show != nil ? viewModel.download.show?.smallCoverImage : viewModel.download.smallCoverImage) ?? ""
    }
    
    var title: String {
        if let episode = Episode(viewModel.download.mediaMetadata) {
            return "\(episode.episode). " + episode.title
        } else {
            return viewModel.download.title
        }
    }
        
    var detailText: String {
        return viewModel.download.isCompleted ? viewModel.download.fileSize.stringValue : downloadingDetailText
    }
    var contentMode: SwiftUI.ContentMode {
        viewModel.download.show != nil ? .fill : .fit
    }
    
    var downloadingDetailText: String {
        let download = viewModel.download
        let speed: String
        let downloadSpeed = TimeInterval(download.torrentStatus.downloadSpeed)
        let sizeLeftToDownload = TimeInterval(download.fileSize.longLongValue - download.totalDownloaded.longLongValue)
        
        if downloadSpeed > 0 {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .full
            formatter.includesTimeRemainingPhrase = true
            formatter.includesApproximationPhrase = true
            formatter.allowedUnits = [.hour, .minute]
            
            let remainingTime = sizeLeftToDownload/downloadSpeed
            
            if let formattedTime = formatter.string(from: remainingTime) {
                speed = " • " + formattedTime
            } else {
                speed = ""
            }
        } else {
            speed = ""
        }
        
        return download.downloadStatus == .paused ?  "Paused".localized : ByteCountFormatter.string(fromByteCount: Int64(download.torrentStatus.downloadSpeed), countStyle: .binary) + "/s" + speed
    }
    
    var deleteActionSheet: ActionSheet {
        ActionSheet(title: Text("Delete Download".localized),
                    message: Text("Are you sure you want to delete the download?".localized),
                    buttons: [
                        .destructive(Text("Delete".localized)) {
                            viewModel.delete()
                        },
                        .cancel()
                    ]
        )
    }
    
    var actionSheet: ActionSheet {
        var buttons: [ActionSheet.Button] = [
            .default(Text("Play".localized)) {
                viewModel.play()
            }
        ]
        
        if (viewModel.download.downloadStatus == .paused) {
            buttons = [
                .default(Text("Continue Download".localized)) {
                    viewModel.continueDownload()
                }
            ]
        }
        
        if (viewModel.download.downloadStatus == .downloading) {
            buttons = [
                .default(Text("Pause".localized)) {
                    viewModel.pause()
                }
            ]
        }
        
        return ActionSheet(title: Text(""),
                    message: nil,
                    buttons: buttons +
                    [
                        .destructive(Text("Delete Download".localized)) {
                            viewModel.delete()
                        },
                        .cancel()
                    ]
        )
    }
}

struct DownloadView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            DownloadView(viewModel: DownloadViewModel(download: PTTorrentDownload.dummy(status: .processing)))
//                .previewDisplayName("Processing")
//            DownloadView(download: PTTorrentDownload.dummy(status: .downloading))
//                        .previewDisplayName("Downloading")
//            DownloadView(download: PTTorrentDownload.dummy(status: .paused))
//                .frame(width: 310, height: 245)
//            .previewDisplayName("Paused")
//            DownloadView(download: PTTorrentDownload.dummy(status: .failed))
//                .previewDisplayName("Failed")
            DownloadView(viewModel: DownloadViewModel(download: PTTorrentDownload.dummy(status: .finished)))
                .frame(width: 250, height: 460, alignment: .center)
                .previewDisplayName("Finished")
        }
        .previewLayout(.sizeThatFits)
    }
}




