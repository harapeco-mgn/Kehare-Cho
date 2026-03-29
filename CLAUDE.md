# CLAUDE.md — ケハレ帖 開発ガイド

このファイルは Claude Code がプロジェクトのコンテキストを理解するためのガイドです。

---

## 📑 目次

1. [⚠️ 最重要ルール](#️-最重要ルール絶対に守る)
   - [授業形式・3フェーズ構造](#授業形式3フェーズ構造で進める)
   - [質問のルール](#質問のルール)
   - [実装のルール](#実装のルール)
   - [コミット前の必須作業](#コミット前の必須作業)
   - [PR マージ前の確認](#pr-マージ前の確認)
   - [実装開始のタイムリミット](#実装開始のタイムリミット)
2. [プロジェクト概要](#プロジェクト概要)
3. [技術スタック](#技術スタック)
4. [開発ワークフロー](#開発ワークフロー)
5. [Git 運用](#git-運用)
6. [Claude Code 操作ガイドライン](#claude-code-操作ガイドライン)
7. [コーディング規約](#コーディング規約)
8. [テスト方針](#テスト方針)
9. [CI/CD](#cicdgithub-actions)
10. [DB 設計の方針](#db-設計の方針)
11. [重要な設計判断](#重要な設計判断)
12. [変更差分メモ（Obsidian 連携）](#変更差分メモobsidian-連携)
13. [その他](#その他)

---

## ⚠️ 最重要ルール（絶対に守る）

**🚨 このセクションのルールを守らないと、ユーザーの学習機会を奪います**

### 授業形式・3フェーズ構造で進める

```
フェーズ1: 講義（概念解説） → フェーズ2: 質問（15問以上） → フェーズ3: 実践（ユーザーが実装）
```

**フェーズ1: 講義（概念解説）**

1. **全体像の説明:** このステップで何を作るか、アプリ全体のどこに位置するか
2. **概念解説:** Rails/Ruby の仕組みを教科書のように解説
   - 処理フロー図・ツリー図で視覚的に説明
   - 比較表でパターンのメリット・デメリットを示す
   - Before/After の対比で変更の意図を明確にする
   - 段階的にズームイン（全体像 → ファイル単位 → メソッド単位）

**フェーズ2: 理解確認（質問）** 3. **理解確認の質問を出す:** 概念の理解を確認する質問（「なぜ?」「予測」「比較」を含む）4. **ユーザーが回答する（任意）:** 自分の理解を言葉にして答える5. **Claude が解説:**

- 回答があった場合 → 答え合わせ・解説・ヒント・補足を追加
- 回答がなかった場合 → 各質問の正解と解説を Claude が提示

**フェーズ3: 実践（実装）** 6. **ブランチ準備（Claude が実行）:**

- main ブランチの最新化: `git pull origin main`
- feature ブランチの作成: `git checkout -b feature/<issue番号>-<概要>`

7. **Claude が実装する:** ファイル編集・コマンド実行
8. **動作確認:** 実装後にテストを実行し、結果を報告
9. **Claude がフィードバックし、次のステップへ**

### 質問のルール

**絶対に守ること:**

- ✅ **1 Issue あたり 15 問以上**の質問を出す
- ✅ 実装前に必ず質問を出す
- ✅ 7種類の質問タイプを使用（下記参照）
- ❌ 質問をスキップしない
- ❌ RSpec（テストコード）・コミット・ブランチ・PRに関する質問は不要

**質問の種類（7種類）:**

1. **gem/ライブラリの機能:** 「このモジュールは何をするか?」
2. **Rails 規約・パターン:** 「この書き方の意味は?」
3. **設定の影響範囲:** 「この設定を変更すると何に影響するか?」
4. **インフラ・Docker:** 「このコンテナ設定の役割は?」
5. **「なぜ?」系（設計理由）:** 「なぜこのパターンを使うのか?」
6. **「予測」系:** 「この変更をしたら何が起きると思いますか?」
7. **「比較」系:** 「A と B の違いは?」「メリット・デメリットは?」

**質問のタイミング:**

- 新しい gem やライブラリを導入するとき
- Rails の規約やパターンを使うとき
- 設定ファイルを変更するとき
- コントローラーのアクションを定義するとき
- ルーティングを設定するとき
- ビューでヘルパーやパーシャルを使うとき
- バリデーションやコールバックを設定するとき

### 実装のルール

**Claude が実装する（ユーザーの依頼に応じて）:**

- ✅ Claude がコードを実装する
- ✅ RSpec テストコードも Claude が自動生成
- ✅ ユーザーが「実装お願いします」と依頼した場合はそのまま実装する

### コミット前の必須作業

**🚨 `git add` 前に必ず RuboCop 自動修正を実行:**

```bash
docker compose exec web bundle exec rubocop -a
```

- **必ず `-a` を使用**（`-A` ではない - 安全な自動修正のみ）
- これにより、不要なコミット修正を防ぐ
- CI でのエラーを事前に防ぐ

### PR マージ前の確認

**🚨 Claude が PR をマージする際は必ず GitHub Actions の通過を確認:**

```bash
gh pr checks <PR番号>
# または
gh pr view <PR番号>
```

- 全てのチェック（RSpec、RuboCop）が ✅ であることを確認
- CI が失敗している場合は原因を調査・修正してからマージ
- **CI 通過前のマージは厳禁**

### コミット・PR作成の厳守事項

- ❌ コミットメッセージに `Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>` を含めない
- ❌ PR本文に `🤖 Generated with Claude Code` を含めない
- ⚠️ ルール違反時: 即座に `git commit --amend` で修正 → `git push --force` で上書き

### 実装開始のタイムリミット

GitHub Issue の実装を依頼された場合:

- ❌ 調査・計画に5分以上使わない
- ❌ 同じファイルを2回以上読まない
- ✅ 5分以内にコードを書き始める
- ✅ 不明点は実装しながら逐次確認する
- ✅ 計画が必要な場合は3行以内のメンタルモデルで十分

---

## プロジェクト概要

- **アプリ名:** ケハレ帖（仮）
- **概要:** 日常の食事（ケ）に「小さなハレ」を足す行動を記録・可視化するサービス
- **ターゲット:** 一人暮らしの料理初心者（スマホ中心）

---

## 技術スタック

| カテゴリ       | 技術                       |
| -------------- | -------------------------- |
| 言語           | Ruby 3.3.2                 |
| フレームワーク | Rails 8.1                  |
| 認証           | Devise                     |
| フロントエンド | Hotwire (Turbo + Stimulus) |
| CSS            | Tailwind CSS + daisyUI     |
| DB             | PostgreSQL (本番: Neon)    |
| テスト         | RSpec                      |
| コンテナ       | Docker                     |
| ホスティング   | Render                     |
| CI/CD          | GitHub Actions             |
| 環境変数       | dotenv-rails (.env)        |

**言語・命名規則:**

- 変数名・メソッド名・クラス名: 英語（Rails 標準）
- コミットメッセージ: 日本語
- コードコメント: 日本語
- PR タイトル・説明: 日本語
- Claude の応答: 日本語

---

## 開発ワークフロー

### 全体の流れ

```
1. Issue 選定（GitHub Projects のカンバンから選ぶ）
2. TDD で開発（テスト→実装→リファクタリング）
   └─ 授業形式・3フェーズ構造で進める
   └─ フェーズ3冒頭で Claude が git pull + ブランチ作成を自動実行
3. RuboCop 自動修正（git add 前に必ず実行）
4. コミット（日本語メッセージ）
5. PR 作成（Claude Code で gh pr create → main 向け）
6. CI 通過確認
7. マージ
8. Obsidian 変更差分メモ自動生成（マージ後）
```

### 1. Issue 選定

GitHub Issues + GitHub Projects（カンバンボード）で管理。

**カンバンのカラム:**

- Backlog: 未着手
- In Progress: 作業中
- In Review: PR 作成済み
- Done: マージ完了

### 2. ブランチ作成

```bash
git checkout main
git pull origin main
git checkout -b feature/<issue番号>-<概要>
# 例: git checkout -b feature/27-hare-entry-tags-create
```

**命名規則:** `feature/<issue番号>-<kebab-case の概要>`

### 3. TDD 開発（授業形式で進める）

**必ず「授業形式・3フェーズ構造」で進める（最重要ルール参照）**

1. **講義:** 概念解説（図解・比較表を使う）
2. **質問:** 15問以上の理解確認質問
3. **実践:** ユーザーが実装（Claudeはヒントのみ）

**RSpec テストコード:** Claude が自動生成（質問不要）

### 4. コミット

**タイミング:**

- ファイル生成・削除時
- 実装が一区切り付いたとき
- 正常に動作確認したとき
- Lint・テスト修正時

**手順:**

1. **RuboCop 自動修正を実行**（必須）
   ```bash
   docker compose exec web bundle exec rubocop -a
   ```
2. **ファイルをステージング**
   ```bash
   git add <変更ファイル>
   ```
3. **コミット**
   ```bash
   git commit -m "$(cat <<'EOF'
   コミットメッセージの本文
   詳細な説明
   EOF
   )"
   ```

**注意:** `Co-Authored-By` を付けない

### 5. PR 作成

**マージ先:** `main`

**タイトル形式:** `[Feature/Fix/Refactor/...] 日本語の説明`

**コマンド例:**

```bash
gh pr create --title "[Feature] タイトル" --body "$(cat <<'EOF'
## 概要
- 変更内容

## 関連 Issue
closes #XX

## 変更ファイル一覧
| ファイル | 種別 | 変更理由 |
|---------|------|---------|
| `path/to/file` | 追加 | 理由 |

## 実装のポイント
- ポイント

## テスト計画
- [ ] テスト項目

## 残件・TODO
- なし
EOF
)"
```

**注意:** PR 本文に `🤖 Generated with Claude Code` を含めない

### 6. CI 通過確認・マージ

**マージ前に必ず確認:**

```bash
gh pr checks <PR番号>
```

**全てのチェックが ✅ になってからマージ**

### 7. Obsidian メモ自動生成

PR マージ後に変更差分メモを自動生成（詳細は後述）

---

## Git 運用

### ブランチ戦略: GitHub Flow

```
main        ← 本番・開発統合ブランチ
feature/*   ← 機能開発
hotfix/*    ← 緊急修正
```

### PR 運用

**マージ方針:**

- CI（GitHub Actions）全通過後のみマージ可能
- Branch Protection Rules を設定

**マージ後の処理:**

- Obsidian メモ自動生成
- `git checkout main && git pull origin main` で main を最新化

### .gitignore と追跡状態

- `.claude/` ディレクトリ全体が無視される
- `**/CLAUDE.md` パターンで全ディレクトリの CLAUDE.md が無視対象
- **例外:** プロジェクトルートの CLAUDE.md は既に追跡中のためコミット可能

### マイグレーション後の必須チェック

マイグレーションファイルを変更・追加した場合:

- ✅ `git diff --name-only` で schema.rb が含まれていることを確認
- ✅ PR 作成前に `db/schema.rb` がステージングされていることを確認
- ❌ schema.rb なしでマイグレーション関連の PR を作成しない

### CRLF/LF 問題の対処

1. `.gitattributes` で適切なファイル属性を設定
2. `git config core.autocrlf` を確認・修正
3. `git add --renormalize .` で正規化

**注意:** 根本原因を修正せずに `git rm --cached` や `git checkout` を実行すると、インデックスが非同期化する

---

## Claude Code 操作ガイドライン

### 実行環境

| コマンド                  | 実行環境     | 備考                      |
| ------------------------- | ------------ | ------------------------- |
| Rails, RSpec, bundle, gem | Docker 経由  | Ruby/Node.js 依存コマンド |
| git, gh                   | WSL 直接実行 | システムコマンド          |

### Docker 環境の注意事項

- このプロジェクトは Docker で動作
- `docker-compose.yml` の `DATABASE_URL` 環境変数に注意
- **Docker の起動、RuboCop 実行、ポート競合デバッグは明示的指示がない限り行わない**

### ファイル権限の修正

Docker 経由でファイル生成時、root 所有になる場合がある。

**Claude の役割:** 権限修正コマンドは実行せず、ユーザーに依頼
**ユーザーが実行:** `sudo chown -R $USER:$USER .`

### コマンド提示ルール

- 実行コマンドは必ず提示
- コピペで実行可能な形式
- 各コマンドに簡潔なコメント
- 長いメッセージは HEREDOC でインライン指定

### 改行コード

作成するファイルは全て LF（`\n`）で統一

### CI/Docker 環境の制約

- **ChromeDriver:** CI では GitHub Actions の `setup-chrome` で Chrome をインストール。ローカルの Docker 環境とはバージョンが異なる場合がある
- **System Spec:** Selenium + headless Chrome を使用。Cuprite は使わない
- **Docker 権限:** seccomp 制限あり。Chrome の `--no-sandbox` フラグが必要
- **DATABASE_URL:** Docker 環境で設定済み。テスト実行時は RAILS_ENV=test を明示

---

## コーディング規約

### RuboCop

- RuboCop デフォルトルールに従う
- `.rubocop.yml` でプロジェクト固有の設定を管理
- **`git add` 前に必ず `rubocop -a` を実行**

### Rails ベストプラクティス

- **Thin Controller / Fat Model:** コントローラーにはロジックを書かず、モデルやサービスに委譲
- **サービスクラス:** 複数モデルにまたがるビジネスロジックは `app/services/` に配置
- **スコープ活用:** 頻繁に使うクエリ条件は `scope` で定義
- **N+1 回避:** `includes` / `preload` を意識
- **Strong Parameters:** コントローラーで必ず使用
- **バリデーション:** モデル層で厳密に定義

### ディレクトリ構成

```
app/
├── controllers/     # Thin Controller
├── models/          # バリデーション・アソシエーション・スコープ
├── services/        # ビジネスロジック
├── helpers/         # ビューヘルパー
├── views/           # ERB テンプレート
│   └── shared/      # パーシャル
└── javascript/
    └── controllers/ # Stimulus コントローラー
```

---

## テスト方針

### RSpec で網羅的にテストを書く

- **モデルスペック:** バリデーション、アソシエーション、スコープ、メソッド
- **リクエストスペック:** 各エンドポイントの正常系・異常系・認可チェック
- **システムスペック:** E2E テスト
- **サービススペック:** サービスクラスのユニットテスト

### 変更のたびにテストを実行

- ファイルを編集したら、関連するテストを即座に実行する
- 全ファイル編集後にまとめてテストを実行するのではなく、1ファイルごとに確認する
- リファクタリング時は、変更前の機home\toshi\.claude\usage-data\report.html能が全て動作することを確認してから次に進む

### テスト実行コマンド

```bash
# 全テスト
docker compose exec web bundle exec rspec

# 特定ファイル
docker compose exec web bundle exec rspec spec/models/user_spec.rb

# 特定タグ
docker compose exec web bundle exec rspec --tag focus
```

---

## CI/CD（GitHub Actions）

PR 作成・push 時に自動実行:

- RSpec（全テスト）
- RuboCop（構文チェック）
- SimpleCov（カバレッジ測定・90%以上必須）

**設定ファイル:** `.github/workflows/ci.yml`

**ルール:**

- CI が通らない PR は main にマージ不可
- **Claude が PR をマージする際は必ず `gh pr checks` で確認**

---

## DB 設計の方針

- **マスタデータ:** `hare_tags`, `genres`, `point_rules` は seed で管理
- **冪等性:** `find_or_create_by(key: ...)` で重複しない
- **key は不変、label は変更可**
- **ポイント履歴:** `point_transactions` でトランザクション台帳として記録

---

## 重要な設計判断

- レシピ DB は持たない（Google 検索へ誘導）
- ポイントルールは `point_rules` テーブルで管理
- 画像投稿は MVP では実装しない
- 公開投稿のタイムライン機能は MVP では実装しない

---

## 変更差分メモ（Obsidian 連携）

> **📝 Note:** 詳細は MEMORY.md の「ドキュメント自動生成 > 1. Obsidian 変更差分メモ」セクションを参照

### 生成タイミング

PR マージ後に Claude Code がメモを生成（CI 修正・レビュー対応含む最終差分を反映）

**トリガー条件:**

- ユーザーが「マージした」と報告 → メモ作成 + `git checkout main && git pull origin main`
- ユーザーが「Obsidian メモを作成して」と依頼 → メモ作成
- 新しい Issue 開始時 → 前回 PR のメモ未作成ならリマインド

**データソース:** `gh pr diff`, `gh pr view`, `gh issue view`

### 保存先・命名規則

```
/mnt/c/Users/toshi/OneDrive/Documents/Obsidian_Vault/obsidian/Kehare-Cho/
YYYY-MM-DD_Issue番号_変更内容の要約.md
```

例: `2026-02-09_Issue27_ハレ投稿にタグ付与機能実装.md`

### 含める内容

※ RSpec（テストコード）の解説は含めない
※ 技術用語には Obsidian 内部リンク `[[用語名]]` を付ける（1 Issue あたり 15〜20個）

1. ブランチ名・関連 Issue・PR
2. 変更概要（1〜3行）
3. 思考プロセス（要件整理 → 現状分析 → 設計判断）
4. 実装パターンの検討（比較表）
5. 変更ファイル一覧
6. 実装コマンド（Rails コマンドのみ、Git・RuboCop は除外）
7. テーブル設計解説（該当ある場合のみ）
8. ロジック・メソッド解説（処理フロー図）
9. コード差分（全変更ファイルの diff）
10. 用語解説（技術用語を個別に解説、`[[用語名]]` 付き）
11. 学んだこと・メモ
12. コミット履歴（全コミットのハッシュ・メッセージ・内容）

### Q&A セクションのクオリティ基準

- ❌ ユーザーの回答は記述不要
- ✅ 正解・解説を詳しく記述（1問あたり15〜30行）：
  - 仕組みの詳細説明（内部動作、処理フロー）
  - なぜそうなのかの理由
  - 具体的なコード例・SQL例・HTML出力例
  - メリット・デメリット
  - 代替案との比較（表形式）
  - 実際の使用例・ユースケース
  - 関連する概念の解説

**リファレンス:** `2026-02-07_Issue26_ハレ投稿削除機能実装.md`

---

## その他

### 環境変数の管理

- dotenv-rails（`.env` ファイル）を使用
- `.env` は `.gitignore` に追加
- `.env.example` をリポジトリに含める

### 日本語化（i18n）

- `rails-i18n` gem を導入
- `config.i18n.default_locale = :ja` に設定
- `config/locales/ja.yml` でプロジェクト固有の翻訳を管理

### Docker コマンド

```bash
# コンテナ起動
docker compose up

# Rails コマンド
docker compose exec web rails db:create
docker compose exec web rails db:migrate
docker compose exec web rails db:seed
docker compose exec web rails console

# テスト・Lint
docker compose exec web bundle exec rspec
docker compose exec web bundle exec rubocop -a  # git add 前に必ず実行
```

### サブエージェントのモデル選択

Task tool でサブエージェントを起動する際のモデル使い分け：

| タスク                         | モデル | 理由                   |
| ------------------------------ | ------ | ---------------------- |
| ファイル検索・パターン探し     | haiku  | 単純な検索で十分       |
| 既存コードの構造把握           | haiku  | 読み取りだけなので軽量 |
| 複雑な設計・アーキテクチャ判断 | sonnet | 深い思考が必要         |
| バグの根本原因分析             | sonnet | 推論力が必要           |
