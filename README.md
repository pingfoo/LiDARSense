#  LiDARSense

## 概要

このリポジトリは研究開発目的の簡易LiDAR計測アプリのコードです。
実装にあたり、下記のコードをベースとさせていただき、拡張しました。

 [OPTiM TECH BLOG](https://tech-blog.optim.co.jp) 
 記事「[ARKit と LiDAR で 3 次元空間認識して SceneKit でリアルタイム描画](https://tech-blog.optim.co.jp/entry/2021/05/06/100000)」
 の[サンプルコード](https://github.com/optim-corp/techblog-arscnview-mesh-demo)


## 機能
- Point と Mesh で点群表示かメッシュ表示を切り替えられます (現在、Mesh 表示は不安定です)
- Take を押すとLiDAR点群の収集を開始します。Stopを押すと収集を終了すると同時に、カメラで写真を撮影します。（どこで撮影した点群かを記録する目的です）
- Share を押すとこれまでに記録したデータを zip ファイルにして共有することができます。(AirDrop、メール、メッセンジャーなど)
- Exit を押すと終了します

## 実行環境
- Xcode 12 以降
- iOS/iPadOS 14 以降
- LiDAR スキャナ搭載の iPhone または iPad (実機のみ)

## 実行方法
1. Xcode で LiDARSense.xcodeproj をビルドします
2. 実機で実行します

## ライセンス

[MIT Licesne](./LICENSE)
