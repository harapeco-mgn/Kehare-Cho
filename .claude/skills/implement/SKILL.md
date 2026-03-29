# Implement GitHub Issue

GitHub Issue を効率的に実装するスキル。
実装と同時にコードレビューを並行実施する。

## Instructions

1. **Issue の確認（2分以内）**
   - `gh issue view <番号>` で要件を把握
   - 関連ファイルを Grep で特定（最大3ファイル読む）

2. **チームを起動（Agent Teams が有効な場合）**
   - チームメイトA（実装者）: ブランチ作成 → テストファースト → 実装
   - チームメイトB（レビュアー）: Aの変更を監視し、以下を即フィードバック
     - N+1 クエリ（includes 漏れ）
     - バリデーション漏れ・エッジケース
     - RuboCop 違反
     - Rails ベストプラクティス違反（Fat Controller など）
   - Agent Teams が無効な場合 → 実装完了後にレビューを実施

3. **ブランチ作成 & 即実装**
   - `git checkout -b feature/<issue番号>-<概要>`
   - テストファースト: まず RSpec を書く
   - 実装: 1ファイル編集 → テスト実行 → 次のファイル

4. **品質チェック**
   - `docker compose exec web bundle exec rspec`（全テスト）
   - `docker compose exec web bundle exec rubocop -a`

5. **PR 作成**
   - CLAUDE.md の PR テンプレートに従う

## Rules

- ❌ 5分以上の調査・計画をしない
- ❌ 同じファイルを2回読まない
- ✅ 1ファイル編集ごとにテスト実行
- ✅ 実装しながら不明点を解決する
- ✅ レビューは実装と並行して実施する（デフォルト動作）
