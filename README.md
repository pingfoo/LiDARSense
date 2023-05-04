#  LiDARViewer3D

## 概要

このリポジトリは研究開発目的の簡易LiDAR計測アプリのコードです。
実装にあたり、下記のコードをベースとして拡張しました。

 [OPTiM TECH BLOG](https://tech-blog.optim.co.jp) 記事「[ARKit と LiDAR で 3 次元空間認識して SceneKit でリアルタイム描画](https://tech-blog.optim.co.jp/entry/2021/05/06/100000)」のサンプルコードです．

## 実行環境

AR 機能を用いるためシミュレータでは使用できません．

- Xcode 12 以降
- iOS/iPadOS 14 以降
- LiDAR スキャナ搭載の iPhone または iPad

## 実行方法

1. Xcode で LiDARViewer3D.xcodeproj を開く
1. 必要に応じてターゲット設定の "Signing & Capabilities" の "Team" と "Bundle Identifier" をあなたのものに変更
1. 実機デバッグで実行

## ライセンス

[MIT Licesne](./LICENSE)