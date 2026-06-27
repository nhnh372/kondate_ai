# KONDATE AI Firestore Schema

この設計は、SharedPreferences中心の現在実装からFirestoreへ段階的に移行するための初期案です。
Firestore未接続の状態でもアプリがビルドできるよう、まずはコレクション名、保存責務、Repository契約を分離しておきます。

## Collections

### `users`

ユーザーの基本情報を保存する。

- `id`: Firebase Auth UID
- `email`: メールアドレス
- `displayName`: 表示名
- `createdAt`: 作成日時
- `updatedAt`: 更新日時

### `meal_history`

AI献立生成や詳細閲覧など、ユーザーの献立履歴を保存する。

- `id`: ドキュメントID
- `userId`: `users.id`
- `mealName`: 献立名
- `category`: 主菜 / 副菜 / 汁物など
- `aiScore`: AIおすすめ度
- `createdAt`: 作成日時

### `favorites`

お気に入り保存した献立を保存する。

- `id`: ドキュメントID
- `userId`: `users.id`
- `mealName`: 献立名
- `category`: 主菜 / 副菜 / 汁物など
- `createdAt`: 作成日時

### `weekly_plans`

週間献立を保存する。

- `id`: ドキュメントID
- `userId`: `users.id`
- `days`: 月曜日〜日曜日の献立配列
- `totalMinutes`: 1週間の概算調理時間
- `totalCostYen`: 1週間の概算食費
- `createdAt`: 作成日時
- `updatedAt`: 更新日時

### `shopping_lists`

週間献立から生成した買い物リストを保存する。

- `id`: ドキュメントID
- `userId`: `users.id`
- `weeklyPlanId`: `weekly_plans.id`
- `items`: 買い物項目配列
- `createdAt`: 作成日時
- `updatedAt`: 更新日時

### `settings`

ユーザーごとの献立提案設定を保存する。

- `userId`: `users.id`
- `familySize`: 家族人数
- `allergies`: アレルギー
- `dislikedIngredients`: 苦手食材
- `busyLevel`: 忙しさ
- `returnHomeTime`: 帰宅時間
- `favoriteGenres`: 好みの料理ジャンル
- `budgetYenPerWeek`: 週予算
- `updatedAt`: 更新日時

## Migration Policy

- 現在のSharedPreferences保存はすぐに削除しない。
- Repository契約を先に用意し、Local実装からFirestore実装へ差し替える。
- Firebase Auth導入後、匿名またはログイン済みUIDを `userId` として各コレクションに保存する。
- SharedPreferencesの `favorites`、`history`、AI優先度は、初回ログイン後にFirestoreへ移行する。
