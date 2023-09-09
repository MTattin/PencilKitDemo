# PencilKitDemo

PencilKitの動作確認用。

## 概要

SwiftUIで動かしたかったので `PKCanvasView` は `UIViewRepresentable` を利用して実装。  

「Draw」をタップしたら、表示されている画面を画像にして書き込み可能な画面を表示。  

書き込み画面には、とりあえず使いそうな操作（UndoやRedoなど）を確認するためのボタンを上部に配置。　　

写真アプリへ保存する機能は「描いたもののみ」と「画像と描いたもの両方」を選択可能。

左上の`color well`から背景色を変更可能。

### メモ

「ヘルプ」（？ボタン）は未実装。　　

### Sample Video

| Sample 1 | Sample 2 (Save function) |
|-----|-----|
| <kbd><img src="https://github.com/MTattin/PencilKitDemo/assets/2594225/57378f64-efc1-478b-a63b-6f7bf30b33d1" /></kbd> | <kbd><img src="https://github.com/MTattin/PencilKitDemo/assets/2594225/f1c35857-aca3-4dea-993b-fdc80611793f)" /></kbd> |
| Sample ３ (背景色変更) |  |
| <kbd><img src="https://github.com/MTattin/PencilKitDemo/assets/2594225/6c964e4e-150c-4154-96a8-3f388ff5709a" /></kbd> |  |

## 参考資料

* [Drawing with PencilKit](https://developer.apple.com/documentation/pencilkit/drawing_with_pencilkit)
* [PKCanvasView](https://developer.apple.com/documentation/pencilkit/pkcanvasview)
* [How to let users select a color with ColorPicker](https://www.hackingwithswift.com/quick-start/swiftui/how-to-let-users-select-a-color-with-colorpicker)
