# android-apk-template

A minimal Android project template that automates debug and signed-release APK builds using GitHub Actions.

---

## What this is

Use this template as a starting point for any Android app.  
Three GitHub Actions workflows are included out of the box:

| Workflow | Trigger | Output |
|---|---|---|
| `android-ci.yml` | Push / PR to `main` | Debug APK (Artifact, 30 days) |
| `release.yml` | Manual dispatch or `v*` tag push | Signed release APK (Artifact, 90 days) + GitHub Release |
| `generate-keystore.yml` | Manual dispatch (once) | Keystore + passwords auto-saved as repository Secrets |

---

## Prerequisites

- Java 17 (set up automatically in CI)
- Android Gradle Plugin 8.7.x / Gradle 8.11.x
- `applicationId`: `com.example.myapp` (change in `app/build.gradle.kts`)

---

## Step ① — Generate a keystore (auto-saves Secrets)

Run **generate-keystore.yml** once when you first set up the repository.

1. Open the **Actions** tab of your repository
2. Select **"Generate Android Keystores"** from the workflow list on the left
3. Click **"Run workflow"** and fill in the optional fields if needed
   - `key_alias` : alias for the release key (default: `release`)
   - `key_cn` : Common Name (defaults to repository name if blank)
   - `key_o` : Organization (defaults to owner name if blank)
   - `key_c` : country code (default: `US`)
   - `validity_days` : validity in days (default: `10000` ≈ 27 years)
4. The workflow automatically registers the following repository Secrets — no manual copy-paste needed:

   | Secret name | Description |
   |---|---|
   | `ANDROID_KEYSTORE_BASE64` | Release keystore (Base64) |
   | `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
   | `ANDROID_KEY_ALIAS` | Key alias |
   | `ANDROID_KEY_PASSWORD` | Key password |
   | `ANDROID_DEBUG_KEYSTORE_BASE64` | Debug keystore (Base64) |

   Verify they were registered under **Settings → Secrets and variables → Actions**.

   > ⚠️ The keystore files are **not** stored in the repository. If you lose the release
   > keystore after publishing to Google Play, you'll need to generate a new one and
   > bump the app's `applicationId`. Running this workflow again will **overwrite** the
   > existing Secrets.

---

## Step ② — Debug build (runs automatically on push)

**android-ci.yml** triggers automatically on every push or Pull Request to `main` (or `master`/`develop`) and produces a debug APK.

1. Push your code to the `main` branch
2. Confirm the **"Android CI"** job turns green in the Actions tab
3. Download the APK from the **"Artifacts"** section of the job  
   → Artifact name: **`app-debug`** → contains `app-debug.apk` (kept for 30 days)

If `ANDROID_DEBUG_KEYSTORE_BASE64` is registered, every build will use the same certificate.  
Otherwise the CI runner's default debug key is used.

---

## Step ③ — Signed release build (manual)

Run **release.yml** manually to produce a signed release APK.

1. Select **"Release Build"** in the Actions tab
2. Click **"Run workflow"**
3. Enter a version tag such as `v1.0.0` in the `tag_name` field and run
4. After the job completes, download the APK from Artifacts  
   → Artifact name: **`app-release-signed`** → contains `app-release.apk` (signed, kept for 90 days)

Pushing a `v*` tag triggers the release build automatically and attaches the APK to a GitHub Release.

> **Prerequisite**: Step ① Secrets (`ANDROID_KEYSTORE_BASE64`, etc.) must be registered first.

---

## File structure

```
.
├── app/
│   ├── build.gradle.kts         # App module build config
│   ├── proguard-rules.pro
│   └── src/
│       ├── main/
│       │   ├── AndroidManifest.xml
│       │   ├── java/com/example/myapp/
│       │   │   └── MainActivity.kt
│       │   └── res/
│       └── test/
├── build.gradle.kts             # Root build config
├── settings.gradle.kts          # Project settings
├── gradle.properties
├── gradlew / gradlew.bat
└── .github/workflows/
    ├── android-ci.yml           # Debug build
    ├── release.yml              # Release build
    └── generate-keystore.yml   # Keystore generation
```

---

## Changing the applicationId

Edit `app/build.gradle.kts`:

```kotlin
defaultConfig {
    applicationId = "com.example.myapp"  // ← change this
    ...
}
```

Also rename the package directory under `app/src/main/java/`.

---

<details>
<summary>🔒 About security: why Actions are pinned to commit SHAs</summary>

The workflow files in this template reference third-party Actions like this:

```yaml
uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6
```

The long hex string is a **commit SHA**, not a version tag.

### Why not just use `@v6`?

A tag like `v6` is a mutable pointer — the owner of that repository can silently move it to a different commit at any time.  
If that happens (whether by an accident, a supply-chain attack, or a compromised account), every project using `@v6` would run the attacker's code the next time the workflow triggers — with full access to your repository secrets.

### Why a SHA is safer

A commit SHA is immutable. Once a commit exists, its SHA can never be made to point to different code.  
Pinning to a SHA guarantees you run exactly the code you reviewed, nothing more.

The human-readable tag is kept as a comment (`# v6`) so you can still tell at a glance which version is in use.

### Further reading

- [Security hardening for GitHub Actions — Using third-party Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions#using-third-party-actions) (GitHub Docs, official)

</details>

---
---

# android-apk-template（日本語）

Android アプリの最小構成テンプレートです。  
GitHub Actions を使ってデバッグビルド・署名済みリリースビルドを自動化できます。

---

## このリポジトリについて

Android アプリ開発の出発点として使えるテンプレートです。  
以下の 3 つの GitHub Actions ワークフローが最初から含まれています。

| ワークフロー | トリガー | 出力 |
|---|---|---|
| `android-ci.yml` | `main` への Push / PR | デバッグ APK（Artifact、30 日保存） |
| `release.yml` | 手動実行 または `v*` タグ push | 署名済みリリース APK（Artifact、90 日保存）+ GitHub Release |
| `generate-keystore.yml` | 手動実行（初回のみ） | キーストア＋パスワードを Secrets に自動登録 |

---

## 前提

- Java 17（CI は自動セットアップ）
- Android Gradle Plugin 8.7.x / Gradle 8.11.x
- `applicationId`: `com.example.myapp`（`app/build.gradle.kts` で変更可）

---

## ① キーストアの生成（Secrets を自動登録）

初回セットアップ時に **generate-keystore.yml** を一度だけ実行します。

1. GitHub リポジトリの **Actions** タブを開く
2. 左側のワークフロー一覧から **「Generate Android Keystores」** を選択
3. **「Run workflow」** をクリックし、必要に応じて入力項目を埋めて実行
   - `key_alias` : リリースキーのエイリアス（デフォルト: `release`）
   - `key_cn` : Common Name（空欄だとリポジトリ名が使われます）
   - `key_o` : Organization（空欄だとオーナー名が使われます）
   - `key_c` : 国コード（デフォルト: `US`）
   - `validity_days` : 有効期間（日数、デフォルト: `10000` ≒ 27 年）
4. ワークフローが以下の Secrets を**自動的に登録**します — 手動コピーは不要です:

   | Secret 名 | 説明 |
   |---|---|
   | `ANDROID_KEYSTORE_BASE64` | リリース用キーストア（Base64） |
   | `ANDROID_KEYSTORE_PASSWORD` | キーストアのパスワード |
   | `ANDROID_KEY_ALIAS` | キーのエイリアス |
   | `ANDROID_KEY_PASSWORD` | キーのパスワード |
   | `ANDROID_DEBUG_KEYSTORE_BASE64` | デバッグ用キーストア（Base64） |

   登録されたかどうかは **Settings → Secrets and variables → Actions** で確認できます。

   > ⚠️ キーストアファイルはリポジトリに保存されません。Google Play 公開後にリリースキーストアを失った場合は、新しく生成し `applicationId` を変更する必要があります。このワークフローを再実行すると既存の Secrets が**上書き**されます。

---

## ② デバッグビルド（main push で自動実行）

`main`（または `master`/`develop`）ブランチへの push・Pull Request 時に  
**android-ci.yml** が自動で動作し、デバッグ APK を生成します。

1. コードを `main` ブランチへ push する
2. Actions タブで **「Android CI」** ジョブが緑になるのを確認
3. ジョブの **「Artifacts」** セクションから APK をダウンロード  
   → Artifact 名: **`app-debug`** → `app-debug.apk` が含まれています（保存期間: 30 日）

デバッグキーストア（`ANDROID_DEBUG_KEYSTORE_BASE64`）を登録しておくと、  
毎回同じ証明書でビルドされます。登録しない場合は CI ランナーの標準デバッグキーが使われます。

---

## ③ 署名済みリリースビルド（手動実行）

**release.yml** を手動実行すると、署名済みリリース APK が生成されます。

1. Actions タブで **「Release Build」** を選択
2. **「Run workflow」** をクリック
3. `tag_name` に `v1.0.0` などのバージョンタグを入力して実行
4. ジョブ完了後、Artifacts から APK をダウンロード  
   → Artifact 名: **`app-release-signed`** → `app-release.apk`（署名済み、保存期間: 90 日）が含まれています

`v*` タグを push した場合は自動でリリースビルドが走り、  
GitHub Releases にも APK が添付されます。

> **前提**: ① で Secrets（`ANDROID_KEYSTORE_BASE64` 等）が登録済みであること。

---

## ファイル構成

```
.
├── app/
│   ├── build.gradle.kts         # アプリモジュールのビルド設定
│   ├── proguard-rules.pro
│   └── src/
│       ├── main/
│       │   ├── AndroidManifest.xml
│       │   ├── java/com/example/myapp/
│       │   │   └── MainActivity.kt
│       │   └── res/
│       └── test/
├── build.gradle.kts             # ルートビルド設定
├── settings.gradle.kts          # プロジェクト設定
├── gradle.properties
├── gradlew / gradlew.bat
└── .github/workflows/
    ├── android-ci.yml           # デバッグビルド
    ├── release.yml              # リリースビルド
    └── generate-keystore.yml   # キーストア生成
```

---

## applicationId の変更方法

`app/build.gradle.kts` の以下の箇所を編集してください。

```kotlin
defaultConfig {
    applicationId = "com.example.myapp"  // ← ここを変更
    ...
}
```

`app/src/main/java/` 以下のパッケージ名も変更してください。

---

<details>
<summary>🔒 セキュリティについて：Action をコミット SHA でピン留めしている理由</summary>

このテンプレートのワークフローファイルでは、サードパーティの Action を次のように参照しています。

```yaml
uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6
```

長い 16 進数の文字列が**コミット SHA** です。バージョンタグではありません。

### `@v6` だとなぜ問題があるのか

`v6` のようなタグは「可変ポインター」です。そのリポジトリのオーナーがいつでも別のコミットへ指し直すことができます。  
万が一それが起きた場合（ミス・サプライチェーン攻撃・アカウント侵害など）、`@v6` を使っているすべてのプロジェクトで、次にワークフローが走った瞬間から攻撃者のコードが実行されます。しかもリポジトリの Secrets に完全アクセスできる状態で。

### SHA が安全な理由

コミット SHA は不変です。一度存在したコミットは、その SHA が別のコードを指すことは絶対にありません。  
SHA にピン留めすることで、レビューしたそのコードだけが実行されることを保証できます。

コメントとしてタグ名（`# v6`）を残してあるので、どのバージョンを使っているかは一目でわかります。

### 参考資料

- [GitHub Actions のセキュリティ強化 — サードパーティアクションの使用](https://docs.github.com/ja/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions#using-third-party-actions)（GitHub 公式ドキュメント）

</details>