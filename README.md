# android-apk-template

Android アプリの最小構成テンプレートです。  
GitHub Actions を使ってデバッグビルド・署名済みリリースビルドを自動化できます。

---

## 前提

- Java 17（CI は自動セットアップ）
- Android Gradle Plugin 8.7.x / Gradle 8.11.x
- `applicationId`: `com.example.myapp`（`app/build.gradle.kts` で変更可）

---

## ① キーストアの生成と Secrets への登録

初回セットアップ時に **generate-keystore.yml** を一度だけ実行します。

1. GitHub リポジトリの **Actions** タブを開く
2. 左側のワークフロー一覧から **「Generate Android Keystores」** を選択
3. **「Run workflow」** をクリックし、必要に応じて入力項目を埋めて実行
   - `key_alias` : リリースキーのエイリアス（デフォルト: `release`）
   - `key_cn` : Common Name（空欄だとリポジトリ名が使われます）
   - `key_o` : Organization（空欄だとオーナー名が使われます）
   - `key_c` : 国コード（デフォルト: `US`）
   - `validity_days` : 有効期間（日数、デフォルト: `10000` ≒ 27 年）
4. ジョブが完了したら **「Summary」** タブを開き、表示された値を以下の Secrets に登録する  
   **Settings → Secrets and variables → Actions → New repository secret**

   | Secret 名 | 説明 |
   |---|---|
   | `ANDROID_KEYSTORE_BASE64` | リリース用キーストア（Base64） |
   | `ANDROID_KEYSTORE_PASSWORD` | キーストアのパスワード |
   | `ANDROID_KEY_ALIAS` | キーのエイリアス |
   | `ANDROID_KEY_PASSWORD` | キーのパスワード |
   | `ANDROID_DEBUG_KEYSTORE_BASE64` | デバッグ用キーストア（Base64、任意） |

   > ⚠️ パスワードはジョブサマリーにしか表示されません。必ずその場でコピーしてください。

---

## ② デバッグビルド（main push で自動実行）

`main`（または `master`/`develop`）ブランチへの push・Pull Request 時に  
**android-ci.yml** が自動で動作し、デバッグ APK を生成します。

1. コードを `main` ブランチへ push する
2. Actions タブで **「Android CI」** ジョブが緑になるのを確認
3. ジョブの **「Artifacts」** セクションから `app-debug` をダウンロード  
   → `app-debug.apk` が含まれています（保存期間: 30 日）

デバッグキーストア（`ANDROID_DEBUG_KEYSTORE_BASE64`）を登録しておくと、  
毎回同じ証明書でビルドされます。登録しない場合は CI ランナーの標準デバッグキーが使われます。

---

## ③ 署名済みリリースビルド（手動実行）

**release.yml** を手動実行すると、署名済みリリース APK が生成されます。

1. Actions タブで **「Release Build」** を選択
2. **「Run workflow」** をクリック
3. `tag_name` に `v1.0.0` などのバージョンタグを入力して実行
4. ジョブ完了後、Artifacts から `app-release-signed` をダウンロード  
   → `app-release.apk`（署名済み、保存期間: 90 日）が含まれています

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

合わせて `app/src/main/AndroidManifest.xml` の `package` 属性と  
`app/src/main/java/` 以下のパッケージ名も変更してください。