# Obsidian Note Generator

最近マージされたPRからObsidian形式のドキュメントを生成します。

## Instructions

1. **PRの情報を取得する**
   - `gh pr list --state merged --limit 1` で最新のマージ済みPRを確認
   - `gh pr view <番号>` でPRの詳細を取得
   - `gh pr diff <番号>` で変更差分を取得
   - `gh issue view <番号>` で関連Issueを取得

2. **Git履歴を確認する**
   - PRに含まれる全コミットを取得
   - 各コミットのメッセージと変更内容を確認

3. **Obsidianノートを作成する**
   - 保存先: `/mnt/c/Users/toshi/OneDrive/Documents/Obsidian_Vault/obsidian/Kehare-Cho/`
   - ファイル名: `YYYY-MM-DD_Issue番号_変更内容の要約.md`
   - CLAUDE.mdの「変更差分メモ（Obsidian連携）」テンプレートに従う

4. **含めるべき内容**
   - ブランチ名・関連Issue・PR番号
   - 変更概要
   - 講義ノート（概念解説・処理フロー図・パターン比較）
   - Q&A（理解確認の質問と回答）
   - 思考プロセス（Before/After、設計判断）
   - 実装パターンの検討（比較表）
   - 変更ファイル一覧
   - 実装コマンド（Rails関連のみ）
   - テーブル設計解説（該当する場合）
   - ロジック・メソッド解説
   - コード差分（全ファイル）
   - 用語解説（技術用語に `[[用語名]]` 内部リンク）
   - 学んだこと・メモ
   - コミット履歴

## Rules

- ❌ RSpec（テストコード）の解説は含めない
- ❌ 一時ファイルを使わず、直接Writeツールで書き込む
- ✅ 技術用語には必ず `[[用語名]]` の内部リンクを付ける
- ✅ コード差分は省略せず、全ファイル記載する
- ✅ 処理フローはツリー図で可視化する
- ✅ パターン比較は表形式で整理する
