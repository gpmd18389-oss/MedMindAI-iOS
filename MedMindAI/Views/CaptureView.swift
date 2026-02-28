import SwiftUI
import PhotosUI

struct CaptureView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedImage: UIImage?
    @State private var ocrText: String = ""
    @State private var aiResult: String = ""
    @State private var isAnalyzing = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var errorMessage: String?
    @State private var showResult = false

    var body: some View {
        let colors = themeManager.colors

        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ── 图片预览 ──
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(colors.border, lineWidth: 1)
                            )
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 48))
                                .foregroundColor(colors.primary.opacity(0.5))
                            Text("选择或拍摄一张题目图片")
                                .font(.subheadline)
                                .foregroundColor(colors.textSecondary)
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(colors.border, style: StrokeStyle(lineWidth: 2, dash: [8]))
                                )
                        )
                    }

                    // ── 操作按钮 ──
                    HStack(spacing: 12) {
                        Button {
                            showCamera = true
                        } label: {
                            Label("拍照", systemImage: "camera.fill")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(colors.primary)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Label("相册", systemImage: "photo.fill")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(colors.secondary)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }

                    // ── OCR 文本 ──
                    if !ocrText.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📝 OCR 识别结果")
                                .font(.caption.bold())
                                .foregroundColor(colors.primary)
                            Text(ocrText)
                                .font(.system(size: 13))
                                .foregroundColor(colors.textPrimary)
                                .lineSpacing(4)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colors.surface)
                        )
                    }

                    // ── 分析按钮 ──
                    if selectedImage != nil {
                        Button {
                            Task { await analyzeImage() }
                        } label: {
                            HStack {
                                if isAnalyzing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                Text(isAnalyzing ? "AI 分析中..." : "开始 AI 分析")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [colors.primary, colors.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(isAnalyzing)
                    }

                    // ── 错误提示 ──
                    if let error = errorMessage {
                        Text("⚠️ \(error)")
                            .font(.caption)
                            .foregroundColor(colors.error)
                            .padding(10)
                            .background(colors.error.opacity(0.1).cornerRadius(8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(colors.background.ignoresSafeArea())
            .navigationTitle("拍照识题")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        await performOCR(on: uiImage)
                    }
                }
            }
            .onChange(of: selectedImage) { _, newImage in
                if let image = newImage {
                    Task { await performOCR(on: image) }
                }
            }
            .navigationDestination(isPresented: $showResult) {
                ResultView(
                    questionText: ocrText,
                    ocrText: ocrText,
                    aiRaw: aiResult
                )
            }
        }
    }

    private func performOCR(on image: UIImage) async {
        do {
            ocrText = try await OCRService.shared.recognizeText(from: image)
        } catch {
            errorMessage = "OCR 失败: \(error.localizedDescription)"
        }
    }

    private func analyzeImage() async {
        guard let image = selectedImage else { return }
        isAnalyzing = true
        errorMessage = nil

        do {
            // 压缩图片并转为 base64
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                throw OCRError.invalidImage
            }
            let base64 = imageData.base64EncodedString()

            let result = try await ClaudeAPIService.shared.sendMessageWithImage(
                systemPrompt: PromptProvider.systemPrompt,
                imageBase64: base64
            )

            aiResult = result
            showResult = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }
}

// MARK: - UIKit Camera Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
