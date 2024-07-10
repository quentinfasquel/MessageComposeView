//
//  MessageComposeView.swift
//  MessageComposeView
//
//  Created by Quentin Fasquel on 10/07/2024.
//
import SwiftUI
import MessageUI

///
/// A SwiftUI wrapper for MessageUI's `MFMessageComposeViewController`
///
public struct MessageComposeView: UIViewControllerRepresentable {

    public enum Attachment: Equatable {
        case data(Data, typeIdentifier: String, filename: String)
        case url(URL, alternateFilename: String?)

        static func url(_ url: URL) -> Attachment {
            .url(url, alternateFilename: nil)
        }
    }

    public var recipients: [String]?
    public var body: String?
    public var subject: String?
    public var attachments: [Attachment]?
    public var completion: ((MessageComposeResult) -> Void)?

    public init(
        recipients: [String]? = nil,
        body: String? = nil,
        subject: String? = nil,
        attachments: [Attachment]? = nil,
        completion: ((MessageComposeResult) -> Void)? = nil
    ) {
        self.recipients = recipients
        self.body = body
        self.subject = subject
        self.attachments = attachments
        self.completion = completion
    }

    public func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let viewController = MFMessageComposeViewController()
        viewController.recipients = recipients
        viewController.body = body
        if MFMessageComposeViewController.canSendSubject() {
            viewController.subject = subject
        }
        if MFMessageComposeViewController.canSendAttachments(), let attachments {
            for attachment in attachments {
                switch attachment {
                case .data(let data, typeIdentifier: let typeIdentifier, filename: let filename):
                    viewController.addAttachmentData(data, typeIdentifier: typeIdentifier, filename: filename)
                case .url(let url, alternateFilename: let alternateFilename):
                    viewController.addAttachmentURL(url, withAlternateFilename: alternateFilename)
                }
            }
        }
        viewController.messageComposeDelegate = context.coordinator
        return viewController
    }

    public func updateUIViewController(_ viewController: MFMessageComposeViewController, context: Context) {
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(completion: completion)
    }

    public final class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var completion: ((MessageComposeResult) -> Void)?
        init(completion: ((MessageComposeResult) -> Void)?) {
            self.completion = completion
        }

        public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true, completion: nil)
            completion?(result)
        }
    }
}

struct MessageComposeModifier: ViewModifier {
    @Binding var isPresented: Bool
    var recipients: [String]?
    var body: String?
    var subject: String?
    var attachments: [MessageComposeView.Attachment]?
    var onDismiss: ((MessageComposeResult) -> Void)?
    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            if #available(iOS 14.0, *) {
                composeView.ignoresSafeArea()
            } else {
                composeView.edgesIgnoringSafeArea(.all)
            }
        }
    }

    var composeView: some View {
        MessageComposeView(
            recipients: recipients,
            body: body,
            subject: subject,
            attachments: attachments,
            completion: onDismiss
        )
    }
}

extension View {
    ///
    /// Presents a sheet with a `MessageComposeView`
    ///
    @ViewBuilder public func messageComposeSheet(
        isPresented: Binding<Bool>,
        recipients: [String]? = nil,
        body: String? = nil,
        subject: String? = nil,
        attachments: [MessageComposeView.Attachment]? = nil,
        onDismiss: ((MessageComposeResult) -> Void)? = nil
    ) -> some View {
        modifier(MessageComposeModifier(
            isPresented: isPresented,
            recipients: recipients,
            body: body,
            subject: subject,
            attachments: attachments,
            onDismiss: onDismiss
        ))
    }
}

#Preview {
    struct Preview: View {
        @State private var showMessageCompose: Bool = false
        var body: some View {
            VStack {
                Button("Compose a message") {
                    showMessageCompose = true
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .messageComposeSheet(isPresented: $showMessageCompose)
        }
    }
    return Preview()
}
