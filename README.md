# 📦 Android APK Template

### No Android Studio. No keytool. No hassle. — Build & ship signed APKs entirely in GitHub Actions.

[![Debug Build](https://img.shields.io/github/actions/workflow/status/soraiyu/android-apk-template/android-ci.yml?label=Debug%20Build&logo=android&logoColor=white&color=3DDC84)](https://github.com/soraiyu/android-apk-template/actions/workflows/android-ci.yml)
[![Release Build](https://img.shields.io/github/actions/workflow/status/soraiyu/android-apk-template/release.yml?label=Release%20Build&logo=android&logoColor=white&color=3DDC84)](https://github.com/soraiyu/android-apk-template/actions/workflows/release.yml)
[![AGP 8.7](https://img.shields.io/badge/AGP-8.7.x-blue?logo=gradle&logoColor=white)](https://developer.android.com/build/releases/gradle-plugin)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.x-7F52FF?logo=kotlin&logoColor=white)](https://kotlinlang.org/)
[![Min SDK 26](https://img.shields.io/badge/minSdk-26-orange?logo=android&logoColor=white)](https://developer.android.com/tools/releases/platforms)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/soraiyu/android-apk-template?style=social)](https://github.com/soraiyu/android-apk-template/stargazers)

> 🔑 **The killer feature:** Run one workflow → keystore auto-generated → all signing secrets auto-registered. Zero manual keytool commands.

---

## ✨ Why this template?

| 🙋 You are… | ✅ This template delivers… |
|---|---|
| On a slow/low-spec PC, can't run Android Studio | **Zero local setup** — GitHub Actions handles everything |
| Starting a side project or quick prototype | Minimal boilerplate, push-to-build in minutes |
| Struggling with Android keystores & signing | **Auto-generated keystore + secrets** — no keytool required |
| Shipping APKs to friends, testers, or yourself | Download signed APKs directly from the Actions Artifacts tab |
| Security-aware | All third-party Actions pinned to immutable commit SHAs |

---

## 🚀 How it works — 5 minutes to your first signed APK

```
① Use this template  →  ② Add GH_PAT secret  →  ③ Run generate-keystore
→  ④ Push your code   →  ⑤ Download signed APK from Artifacts
```

![Actions tab — Android CI, Generate Android Keystores, and Release Build listed](https://github.com/user-attachments/assets/58296361-aa50-4c29-be0d-3cc00684100e)

---

## 🛠 Three Workflows, One Goal

| Workflow | Trigger | Output | Kept for |
|---|---|---|---|
| `android-ci.yml` | Push / PR on `main`, `master`, `develop` (**paths filtered** — Android/build files only) | Debug APK | 30 days |
| `release.yml` | Manual **or** push a `v*` tag | **Signed** release APK + GitHub Release | 90 days |
| `generate-keystore.yml` | Manual — **run once** | Keystore auto-saved as repo Secrets | — |

---

## ⚡ Step 0 — Set your app ID first

> Do this before running any workflow.

Open **`app/build.gradle.kts`** and update both lines:

```diff
- namespace   = "com.example.myapp"
- applicationId = "com.example.myapp"
+ namespace   = "com.yourname.yourapp"
+ applicationId = "com.yourname.yourapp"
```

Then rename the source directory to match, and update the `package` declaration inside each Kotlin file:

```
app/src/main/java/com/example/myapp/   →   app/src/main/java/com/yourname/yourapp/
app/src/test/java/com/example/myapp/   →   app/src/test/java/com/yourname/yourapp/
```

Also update the first line of every `.kt` file:

```diff
- package com.example.myapp
+ package com.yourname.yourapp
```

---

## 🔑 Step 1 — Create `GH_PAT` (one-time, ~2 min)

GitHub's built-in `GITHUB_TOKEN` can't write repository Secrets — you need a Personal Access Token once.

1. **GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens**
2. Click **Generate new token** · Scope: *Only select repositories* → pick this repo
3. **Permissions → Repository permissions → Secrets → Read and write** · Generate & copy the token
4. **Repo → Settings → Secrets and variables → Actions → New repository secret**
   Name: `GH_PAT` · Value: *paste token* → **Add secret**

> ✅ One-time only. Everything after this is fully automated.

---

## 🗝 Step 2 — Generate your keystore (auto-saves Secrets)

**Actions → "Generate Android Keystores" → Run workflow**

All fields have sensible defaults — just click Run if you're unsure:

| Input | Default | Notes |
|---|---|---|
| `key_alias` | `release` | Name for the signing key |
| `key_cn` | repo name | Certificate Common Name |
| `key_o` | owner name | Organization field |
| `key_c` | `US` | ISO country code |
| `validity_days` | `10000` (~27 yrs) | How long the cert is valid |

After the workflow finishes, these Secrets appear automatically — **no copy-paste needed**:

| Secret | What it contains |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Release keystore (Base64-encoded) |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_DEBUG_KEYSTORE_BASE64` | Debug keystore (same cert on every build) |

Verify at **Settings → Secrets and variables → Actions**.

![Generate Android Keystores — workflow sidebar showing the three key workflows](https://github.com/user-attachments/assets/41e0da8a-2085-482e-a6c0-98f8baf2462f)

> [!NOTE]
> Re-running this workflow replaces all five Secrets with a freshly generated keystore.

---

## 🔨 Step 3 — Debug build (automatic)

Push Android/build file changes to `main` and the debug build runs on its own.

> **Note:** `android-ci.yml` uses `paths` filters. Pushes that touch only unrelated files (e.g., README edits) will not trigger the workflow — that is expected behavior.

- **Trigger**: push or PR to `main`, `master`, or `develop` when the changed files match the path filters
- **Download**: Actions → job → Artifacts → **`app-debug`** → `app-debug.apk`
- **Retention**: 30 days
- If `ANDROID_DEBUG_KEYSTORE_BASE64` is set, the same signing certificate is used every time

---

## 📦 Step 4 — Signed release build

**Option A — click to release:**
1. Push and create the tag first: `git tag v1.0.0 && git push origin v1.0.0`
2. **Actions → "Release Build" → Run workflow**
3. Enter the tag you just pushed (e.g. `v1.0.0`) → Run

> **Important:** Manual dispatch checks out the tag you enter. The tag **must already exist** in the repo before you run the workflow, or the checkout step will fail.

**Option B — tag to release (fully automatic):**
```bash
git tag v1.0.0
git push origin v1.0.0
# → workflow triggers, APK built and attached to a GitHub Release automatically
```

- **Download**: Actions → job → Artifacts → **`app-release-signed`** → `app-release.apk`
- **Retention**: 90 days
- The APK is also attached to a **GitHub Release** on the Releases page

> **Prerequisite**: Secrets from Step 2 must be registered before running this.

---

## 🏗 Build locally (optional)

Requires **Java 17+** and the **Android SDK** (command-line tools, platform, and build-tools) — GitHub-hosted runners have these pre-installed, but you need to install the SDK locally if it isn't already set up ([Android SDK setup guide](https://developer.android.com/tools)):

```bash
# Debug APK → app/build/outputs/apk/debug/app-debug.apk
./gradlew assembleDebug

# Release APK (needs signing env vars set — normally handled by CI)
./gradlew assembleRelease
```

---

## 📁 File structure

```
.
├── app/
│   ├── build.gradle.kts         # ← App ID, SDK versions, signing config
│   ├── proguard-rules.pro
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── java/com/yourname/yourapp/
│       │   └── MainActivity.kt
│       └── res/
├── build.gradle.kts             # Root build config
├── settings.gradle.kts
├── gradle.properties
├── gradlew / gradlew.bat
└── .github/workflows/
    ├── android-ci.yml           # Auto debug build on push
    ├── release.yml              # Signed release build
    └── generate-keystore.yml   # One-time keystore + secret setup
```

---

<details>
<summary>🔒 Security: why Actions are pinned to commit SHAs</summary>

Workflows in this template reference Actions like this:

```yaml
uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6
```

**Why not `@v6`?**  
Version tags are mutable — the action author can silently point `v6` at entirely different code. If that happens (accident, compromised account, or supply-chain attack), every repo using `@v6` would execute the attacker's code on the next run — with full access to your repository Secrets.

**Why a SHA is safer**  
A commit SHA is immutable. Pinning to a SHA guarantees you always run exactly the code you reviewed. The human-readable tag stays as a comment so you know which version you're on.

📖 [GitHub Docs: Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions#using-third-party-actions)

</details>

---

<details>
<summary>🇯🇵 日本語版 README（クリックで展開）</summary>

## android-apk-template（日本語）

**Android Studio不要** — GitHub Actions だけで署名済みAPKを自動ビルドできる最小構成テンプレートです。

> 🔑 **一番の売り：** ワークフローを1回実行するだけで、keystoreが自動生成されてすべての署名Secretsが自動登録されます。keytoolコマンドは一切不要。

### こんな方におすすめ

| 🙋 こんな方に | ✅ このテンプレートが解決します |
|---|---|
| 非力PCでAndroid Studioが重くて使えない | **ローカル環境不要** — GitHub Actionsが全部やってくれる |
| サイドプロジェクトをさっさと始めたい | 最小構成ですぐbuild可能 |
| keystoreや署名の仕組みがわからない | **keystore自動生成＋Secrets自動登録** — keytool不要 |
| 友人・テスター・自分にAPKを配りたい | ActionsのArtifactsタブから署名済みAPKをダウンロード |
| セキュリティを意識している | サードパーティActionを全てコミットSHAでピン留め |

### ワークフロー一覧

| ワークフロー | トリガー | 出力 | 保存期間 |
|---|---|---|---|
| `android-ci.yml` | `main` / `master` / `develop` への Push / PR（**対象 `paths` の変更時のみ**） | デバッグ APK | 30日 |
| `release.yml` | 手動 または `v*` タグ push | **署名済み**リリース APK + GitHub Release | 90日 |
| `generate-keystore.yml` | 手動（**初回のみ**） | キーストア＋Secretsを自動登録 | — |

### ステップ 0 — アプリIDの変更（最初にやること）

**`app/build.gradle.kts`** を開いて両方の行を変更:

```diff
- namespace   = "com.example.myapp"
- applicationId = "com.example.myapp"
+ namespace   = "com.yourname.yourapp"
+ applicationId = "com.yourname.yourapp"
```

ソースディレクトリ名も合わせて変更し、各Kotlinファイルの `package` 行も更新してください:

```
app/src/main/java/com/example/myapp/   →   app/src/main/java/com/yourname/yourapp/
app/src/test/java/com/example/myapp/   →   app/src/test/java/com/yourname/yourapp/
```

各 `.kt` ファイルの先頭行も変更:

```diff
- package com.example.myapp
+ package com.yourname.yourapp
```

### ステップ 1 — `GH_PAT` の作成（初回のみ、約2分）

`GITHUB_TOKEN` はリポジトリのSecretsに書き込めないため、Personal Access Tokenが1回だけ必要です。

1. **GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens**
2. **Generate new token** をクリック · *Only select repositories* → このリポジトリを選択
3. **Permissions → Repository permissions → Secrets → Read and write** · 生成してコピー
4. **リポジトリ → Settings → Secrets and variables → Actions → New repository secret**
   名前: `GH_PAT` · 値: コピーしたトークン → **Add secret**

> ✅ 初回のみの作業です。以降はすべて自動で動きます。

### ステップ 2 — キーストアの自動生成（Secrets自動登録）

**Actions → "Generate Android Keystores" → Run workflow**

すべての入力項目にデフォルト値があるので、迷ったらそのまま Run でOKです:

| 入力項目 | デフォルト | 説明 |
|---|---|---|
| `key_alias` | `release` | 署名キーの名前 |
| `key_cn` | リポジトリ名 | 証明書のCommon Name |
| `key_o` | オーナー名 | 組織名 |
| `key_c` | `US` | ISO国コード |
| `validity_days` | `10000`（約27年） | 証明書の有効期間 |

ワークフロー完了後、以下のSecretsが**自動的に登録**されます（手動コピー不要）:

| Secret名 | 内容 |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | リリース用キーストア（Base64） |
| `ANDROID_KEYSTORE_PASSWORD` | キーストアパスワード |
| `ANDROID_KEY_ALIAS` | キーエイリアス |
| `ANDROID_KEY_PASSWORD` | キーパスワード |
| `ANDROID_DEBUG_KEYSTORE_BASE64` | デバッグ用キーストア（毎回同じ証明書） |

**Settings → Secrets and variables → Actions** で確認できます。

> [!NOTE]
> このワークフローを再実行すると、5つのSecretsがすべて新しいキーストアで上書きされます。

### ステップ 3 — デバッグビルド（自動）

Android/ビルド関連ファイルを `main` ブランチに push するとデバッグビルドが自動で実行されます。

> **注意:** `android-ci.yml` には `paths` フィルタがあります。READMEだけの変更など、対象外のファイルのみを変更したpushではワークフローが起動しません（これは正常な動作です）。

- **トリガー**: `main`、`master`、`develop` へのpush または PR（pathsフィルタに合致する変更のみ）
- **ダウンロード**: Actions → ジョブ → Artifacts → **`app-debug`** → `app-debug.apk`
- **保存期間**: 30日間
- `ANDROID_DEBUG_KEYSTORE_BASE64` を登録していれば、毎回同じ証明書でビルドされます

### ステップ 4 — 署名済みリリースビルド

**方法A — 手動実行:**
1. 先にタグを作成してpush: `git tag v1.0.0 && git push origin v1.0.0`
2. **Actions → "Release Build" → Run workflow**
3. 作成したタグ（例: `v1.0.0`）を入力して Run

> **重要:** 手動実行時はタグ名で `checkout` します。**タグが事前にpush済みでないと checkout で失敗**します。

**方法B — タグpushで自動実行:**
```bash
git tag v1.0.0
git push origin v1.0.0
# → ワークフローが自動起動し、GitHub Releaseに署名済みAPKが添付される
```

- **ダウンロード**: Actions → ジョブ → Artifacts → **`app-release-signed`** → `app-release.apk`
- **保存期間**: 90日間
- Releasesページの **GitHub Release** にもAPKが自動添付されます

> **前提**: ステップ2のSecretsが登録済みであること。

### ローカルビルド（任意）

**Java 17以上** と **Android SDK**（コマンドラインツール・platform・build-tools）が必要です。GitHub Actions のランナーにはプリインストールされていますが、ローカル環境では別途インストールが必要です（[Android SDK セットアップガイド](https://developer.android.com/tools)）:

```bash
# デバッグAPK → app/build/outputs/apk/debug/app-debug.apk
./gradlew assembleDebug

# リリースAPK（署名用の環境変数が必要 — 通常はCIが処理）
./gradlew assembleRelease
```

### ファイル構成

```
.
├── app/
│   ├── build.gradle.kts         # ← アプリID・SDKバージョン・署名設定
│   ├── proguard-rules.pro
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── java/com/yourname/yourapp/
│       │   └── MainActivity.kt
│       └── res/
├── build.gradle.kts             # ルートビルド設定
├── settings.gradle.kts
├── gradle.properties
├── gradlew / gradlew.bat
└── .github/workflows/
    ├── android-ci.yml           # push時の自動デバッグビルド
    ├── release.yml              # 署名済みリリースビルド
    └── generate-keystore.yml   # キーストア生成＋Secret登録（初回のみ）
```

### セキュリティについて

このテンプレートのワークフローはサードパーティのActionをすべて**コミットSHA**でピン留めしています。

```yaml
uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6
```

`@v6` のようなバージョンタグは可変ポインターのため、リポジトリオーナーがいつでも別のコードに差し替えられます。サプライチェーン攻撃やアカウント侵害が起きた場合、`@v6` を使っている全プロジェクトで次回実行時に攻撃者のコードが動きます（リポジトリのSecretsに完全アクセスした状態で）。

コミットSHAは不変なので、レビュー済みのコードだけが実行されることを保証できます。コメント（`# v6`）でバージョンも一目でわかります。

📖 [GitHub Actions セキュリティ強化ガイド](https://docs.github.com/ja/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions#using-third-party-actions)（GitHub公式）

</details>