# Fix CI Failure

CI 失敗を素早く修正するスキル。

## Instructions

1. **失敗ログの取得**
   - `gh pr checks <番号>` で失敗を確認
   - `gh run view <run-id> --log-failed` で失敗ログを取得

2. **原因の分類**
   - RSpec 失敗 → テストまたは実装の修正
   - RuboCop 違反 → `docker compose exec web bundle exec rubocop -a` 実行
   - ChromeDriver 互換性 → Dockerfile / CI 設定の修正
   - schema.rb 不整合 → `rails db:migrate` + schema.rb コミット

3. **修正 & プッシュ**
   - 最小限の修正を適用
   - ローカルでテスト実行して確認
   - コミット & プッシュ

## Rules

- ✅ ログベースで原因特定（推測しない）
- ✅ 最小限の変更で修正
- ❌ 関係ない改善を同時にしない
