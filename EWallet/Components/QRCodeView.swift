import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let data: String
    let size: CGFloat

    init(_ data: String, size: CGFloat = 200) {
        self.data = data
        self.size = size
    }

    var body: some View {
        if let image = generateQR() {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: size, height: size)
                .overlay(
                    ProgressView()
                )
        }
    }

    private func generateQR() -> UIImage? {
        guard let data = data.data(using: .utf8) else { return nil }
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }

        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }
}
