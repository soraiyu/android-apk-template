# 📦 Android APK Template

> **Build & ship signed Android APKs — entirely in GitHub Actions. No Android Studio required.**

[![Android CI](https://img.shields.io/github/actions/workflow/status/soraiyu/android-apk-template/android-ci.yml?label=Debug%20Build&logo=android)](https://github.com/soraiyu/android-apk-template/actions/workflows/android-ci.yml)
[![Release](https://img.shields.io/github/actions/workflow/status/soraiyu/android-apk-template/release.yml?label=Release%20Build&logo=android)](https://github.com/soraiyu/android-apk-template/actions/workflows/release.yml)
[![AGP](https://img.shields.io/badge/AGP-8.7.x-blue?logo=gradle)](https://developer.android.com/build/releases/gradle-plugin)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.x-7F52FF?logo=kotlin&logoColor=white)](https://kotlinlang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## ✨ Why this template?

| 🙋 You are… | ✅ This template helps because… |
|---|---|
| Tired of installing Android Studio on a slow PC | Everything runs in GitHub Actions — zero local setup needed |
| Building a side project or quick prototype | Minimal boilerplate, ready to build in minutes |
| New to Android signing / keystores | **Keystore is auto-generated and saved as Secrets** — no manual keytool commands |
| Shipping to friends or testers | Download signed APKs straight from the Actions Artifacts tab |
| Security-conscious | All third-party Actions are pinned to immutable commit SHAs |

---

## 🚀 Quick Start

```
Use this template → Add one Secret (GH_PAT) → Run generate-keystore → Push code → Download APK
```

**Total setup time: ~5 minutes.**

---

## 🛠 Three Workflows, One Goal

| Workflow | Trigger | Output | Retention |
|---|---|---|---|
| `android-ci.yml` | Push / PR → `main` | Debug APK | 30 days |
| `release.yml` | Manual or `v*` tag push | **Signed** release APK + GitHub Release | 90 days |
| `generate-keystore.yml` | Manual (once) | Keystore auto-saved as repository Secrets | — |

---

## ⚡ Step 0 — Customize your app ID

> **Do this first** — before running any workflow.

Edit `app/build.gradle.kts`:

```kotlin
defaultConfig {
    applicationId = "com.yourname.yourapp"  // ← change from com.example.myapp
    // ...
}
```

Also update `namespace` at the top of the same file, and rename the package directory:

```
app/src/main/java/com/example/myapp/  →  app/src/main/java/com/yourname/yourapp/
```

---

## 🔑 Step 1 — One-time setup: create `GH_PAT`

> GitHub's built-in `GITHUB_TOKEN` cannot write repository Secrets. You need a Personal Access Token once.

1. Go to **GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens**
2. Click **"Generate new token"**
3. **Repository access** → *Only select repositories* → choose this repo
4. **Permissions → Repository permissions → Secrets** → set to **Read and write**
5. Click **"Generate token"** — copy the value
6. In your repo: **Settings → Secrets and variables → Actions → New repository secret**
   - Name: `GH_PAT` — Value: paste the token → **"Add secret"**

> ✅ Done. This is a one-time step. After this everything runs automatically.

---

## 🗝 Step 2 — Generate your keystore (auto-saves Secrets)

Run **"Generate Android Keystores"** once from the Actions tab:

1. **Actions** → **"Generate Android Keystores"** → **"Run workflow"**
2. Fill in optional fields (all have sensible defaults):

   | Input | Default | Description |
   |---|---|---|
   | `key_alias` | `release` | Key alias |
   | `key_cn` | repo name | Common Name |
   | `key_o` | owner name | Organization |
   | `key_c` | `US` | Country code |
   | `validity_days` | `10000` (~27 yrs) | Key validity |

3. The workflow automatically registers these Secrets — **no copy-paste needed**:

   | Secret | Description |
   |---|---|
   | `ANDROID_KEYSTORE_BASE64` | Release keystore (Base64-encoded) |
   | `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
   | `ANDROID_KEY_ALIAS` | Key alias |
   | `ANDROID_KEY_PASSWORD` | Key password |
   | `ANDROID_DEBUG_KEYSTORE_BASE64` | Debug keystore (consistent cert across builds) |

   Confirm at **Settings → Secrets and variables → Actions**.

> [!NOTE]
> Re-running this workflow overwrites the existing Secrets with a new keystore.

---

## 🔨 Step 3 — Debug build (automatic on every push)

Push code to `main` — that's it.

- **Workflow**: `android-ci.yml` triggers on push / PR to `main`, `master`, or `develop`
- **Artifact**: `app-debug` → `app-debug.apk` (30-day retention)
- If `ANDROID_DEBUG_KEYSTORE_BASE64` is set, every build uses the same signing certificate

---

## 📦 Step 4 — Signed release build

**Option A — Manual:**
1. **Actions** → **"Release Build"** → **"Run workflow"**
2. Enter a version tag (e.g. `v1.0.0`) and run

**Option B — Tag push (automatic):**
```bash
git tag v1.0.0
git push origin v1.0.0
```
GitHub automatically builds and attaches the APK to a **GitHub Release**.

> **Prerequisite**: Secrets from Step 2 must be registered first.

- **Artifact**: `app-release-signed` → `app-release.apk` (signed, 90-day retention)

---

## 🏗 Build locally (optional)

If you have Java 17+ installed, you can build without Android Studio:

```bash
# Debug APK
./gradlew assembleDebug
# Output: app/build/outputs/apk/debug/app-debug.apk

# Release APK (requires signing env vars)
./gradlew assembleRelease
```

---

## 📁 File structure

```
.
├── app/
│   ├── build.gradle.kts         # ← App ID, SDK versions, signing config
│   ├── proguard-rules.pro
│   └── src/
│       ├── main/
│       │   ├── AndroidManifest.xml
│       │   ├── java/com/example/myapp/
│       │   │   └── MainActivity.kt
│       │   └── res/
│       └── test/
├── build.gradle.kts             # Root build config
├── settings.gradle.kts
├── gradle.properties
├── gradlew / gradlew.bat
└── .github/workflows/
    ├── android-ci.yml           # Auto debug build
    ├── release.yml              # Signed release build
    └── generate-keystore.yml   # Keystore generation + secret registration
```

---

<details>
<summary>🔒 Security: why Actions are pinned to commit SHAs</summary>

Workflow files reference Actions like this:

```yaml
uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v4
```

**Why not `@v4`?**  
A version tag is a mutable pointer — the action author can silently redirect it to different code at any time. If that happens via an accident or supply-chain attack, every repo using `@v4` would execute the attacker's code with full access to your Secrets on the next run.

**Why a SHA is safer**  
A commit SHA is immutable. Pinning to a SHA guarantees you run exactly the code you audited — nothing more. The human-readable tag stays as a comment (`# v4`) so you can identify the version at a glance.

📖 [GitHub Docs: Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions#using-third-party-actions)

</details>

---

<details>
<summary>🇯🇵 日本語版 README（クリックで展開）</summary>

## android-apk-template（日本語）

**Android Studio不要** — GitHub Actions だけで署名済みAPKを自動ビルドできる最小構成テンプレートです。

### こんな方におすすめ

- 🐢 **Android Studioが重くて使いたくない人**（非力PC勢）
- ⚡ **GitHub Actionsだけで完結させたい人**
- 🔑 **署名済みAPKを簡単に作りたい人**（keystoreの自動生成が一番の売り）
- 🚀 **最小構成でサクッとAndroidアプリを始めたい人**

### ワークフロー一覧

| ワークフロー | トリガー | 出力 |
|---|---|---|
| `android-ci.yml` | `main` への Push / PR | デバッグ APK（30日保存） |
| `release.yml` | 手動 または `v*` タグ push | 署名済みリリース APK + GitHub Release（90日保存） |
| `generate-keystore.yml` | 手動（初回のみ） | キーストア＋パスワードを Secrets に自動登録 |

### ステップ 0 — アプリIDの変更（最初にやること）

`app/build.gradle.kts` を編集:

```kotlin
defaultConfig {
    applicationId = "com.yourname.yourapp"  // ← com.example.myapp から変更
}
```

`app/src/main/java/` 以下のパッケージディレクトリ名も合わせて変更してください。

### ステップ 1 — `GH_PAT` の作成（初回のみ）

> `GITHUB_TOKEN` はリポジトリの Secrets に書き込めないため、Fine-grained PAT が必要です。

1. **GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens**
2. **「Generate new token」** をクリック
3. **Repository access** → このリポジトリを選択
4. **Permissions → Secrets → Read and write**
5. トークンを生成してコピー
6. リポジトリの **Settings → Secrets → New secret** → 名前: `GH_PAT`、値: コピーしたトークン

### ステップ 2 — キーストアの自動生成

Actions タブから **「Generate Android Keystores」** を手動実行するだけ。  
以下の Secrets が**自動的に登録**されます（手動コピー不要）：

| Secret 名 | 内容 |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | リリース用キーストア |
| `ANDROID_KEYSTORE_PASSWORD` | キーストアパスワード |
| `ANDROID_KEY_ALIAS` | キーエイリアス |
| `ANDROID_KEY_PASSWORD` | キーパスワード |
| `ANDROID_DEBUG_KEYSTORE_BASE64` | デバッグ用キーストア |

### ステップ 3 — デバッグビルド（自動）

`main` ブランチに push するだけ。Actions タブの **「Android CI」** が緑になったら、  
Artifacts セクションから `app-debug.apk` をダウンロードできます。

### ステップ 4 — 署名済みリリースビルド

**手動実行**: Actions → **「Release Build」** → **「Run workflow」** → バージョンタグを入力して実行

**タグ push で自動実行**:
```bash
git tag v1.0.0
git push origin v1.0.0
```
GitHub Releases に自動で APK が添付されます。

### ローカルビルド（任意）

Java 17 があればAndroid Studio不要でビルド可能:

```bash
./gradlew assembleDebug   # デバッグAPK
./gradlew assembleRelease # リリースAPK（署名環境変数が必要）
```

### セキュリティについて

このテンプレートのワークフローはサードパーティの Action をすべて**コミットSHA**でピン留めしています。  
バージョンタグ（`@v4` など）は可変ポインターのため、サプライチェーン攻撃のリスクがあります。  
SHA は不変なので、レビューしたコードだけが実行されることを保証できます。

</details>