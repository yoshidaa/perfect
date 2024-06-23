# SOFT DARTS PRO TOURNAMENT PERFECT 成績スクレイピングツール

SOFT DARTS PRO TOURNAMENT "PERFECT" の成績をスクレイピングし、HTML形式で表示するツールです。

## 参考サイト

詳細な成績データの表示例については、以下のサイトを参考にしてください。

https://yoshidaa.github.io/perfect

## 機能

- PERFECT の成績データをスクレイピング
    - 2016 年度以降が対象
- 取得したデータをHTML形式で整形・表示

## インストール方法

本ツールは Ruby で動作します。また、ライブラリとして Nokogiri と Mechanize を使用しますので以下の手順でインストールしておいてください。

```sh
gem install nokogiri mechanize
```

## 動作手順

players.yaml を編集した後、generate.sh を実行します。

```sh
./generate.sh
```

## ライセンス

このプロジェクトはMITライセンスの下で提供されています。
