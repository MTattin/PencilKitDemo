# PencilKitDemo

PencilKitの動作確認用。

## 概要

SwiftUIで動かしたかったので `PKCanvasView` は `UIViewRepresentable` を利用して実装。  

「Draw」をタップしたら、表示されている画面を画像にして書き込み可能な画面を表示。  

書き込み画面には、とりあえず使いそうな操作（UndoやRedoなど）を確認するためのボタンを上部に配置。　　

### メモ

「アルバム保存」（カメラボタン）と「ヘルプ」（？ボタン）は未実装。　　

### Sample Video

<kbd><img src="https://github.com/MTattin/PencilKitDemo/assets/2594225/57378f64-efc1-478b-a63b-6f7bf30b33d1" /></kbd>

## References

* [Drawing with PencilKit](https://developer.apple.com/documentation/pencilkit/drawing_with_pencilkit)
* [PKCanvasView](https://developer.apple.com/documentation/pencilkit/pkcanvasview)
