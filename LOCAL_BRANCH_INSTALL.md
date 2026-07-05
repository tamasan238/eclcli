# PyPI未公開版 eclsdk/eclcli ローカルインストール手順

この手順は、PyPIにまだ公開されていない以下のブランチ版をローカル環境で利用するためのものです。

- eclsdk: `queens-python314-deps`
- eclcli: `feat/python-312-314-support`

## 前提

- Python 3.14 がインストール済みであること
- `git` が利用できること
- GitHub の `tamasan238/eclsdk` と `tamasan238/eclcli` を clone できること

確認:

```bash
python3.14 --version
git --version
```

## スクリプトでインストールする場合

このリポジトリにあるスクリプトを使うと、clone、venv作成、ローカルタグ付け、インストール、`pip check` までまとめて実行できます。

```bash
git clone -b feat/python-312-314-support https://github.com/tamasan238/eclcli.git ~/work/ecl-local/eclcli
cd ~/work/ecl-local/eclcli
scripts/install-local-branches.sh
```

インストール先はデフォルトで以下です。

```text
~/work/ecl-local
~/work/ecl-local/venv
```

別の場所に入れたい場合:

```bash
WORKDIR=/path/to/ecl-local scripts/install-local-branches.sh
```

インストール後は仮想環境を有効化して利用します。

```bash
source ~/work/ecl-local/venv/bin/activate
ecl --version
```

スクリプトでアンインストールする場合:

```bash
cd ~/work/ecl-local/eclcli
scripts/install-local-branches.sh --uninstall
```

以降は、手動で実行する場合の手順です。

## 1. 作業ディレクトリを作成

```bash
mkdir -p ~/work/ecl-local
cd ~/work/ecl-local
```

## 2. 対象ブランチを clone

```bash
git clone -b queens-python314-deps https://github.com/tamasan238/eclsdk.git
git clone -b feat/python-312-314-support https://github.com/tamasan238/eclcli.git
```

## 3. Python 3.14 の仮想環境を作成

```bash
python3.14 -m venv ~/work/ecl-local/venv
source ~/work/ecl-local/venv/bin/activate
python -m pip install -U pip setuptools wheel
```

以降のコマンドは、この仮想環境を有効化した状態で実行してください。

## 4. eclsdk をローカル正式バージョンとしてインストール

eclcli は `eclsdk>=1.10.0` を要求します。PyPI にはまだ `eclsdk 1.10.0` がないため、先にローカルの eclsdk ブランチを `1.10.0` としてインストールします。

```bash
cd ~/work/ecl-local/eclsdk
git status
git tag -f 1.10.0 HEAD
pip install .
```

確認:

```bash
pip show eclsdk
```

`Version: 1.10.0` と表示されればOKです。

`git tag -f 1.10.0 HEAD` は、ローカルの `1.10.0` タグを現在のブランチ先端へ付け直すためのコマンドです。既に古い位置に同名タグがある場合も、この手順で問題ありません。

## 5. eclcli をローカル正式バージョンとしてインストール

```bash
cd ~/work/ecl-local/eclcli
git status
git tag -f 4.7.1 HEAD
pip install .
```

確認:

```bash
pip show eclcli
```

`Version: 4.7.1` と表示されればOKです。

`git tag -f 4.7.1 HEAD` は、ローカルの `4.7.1` タグを現在のブランチ先端へ付け直すためのコマンドです。既に古い位置に同名タグがある場合も、この手順で問題ありません。

## 6. インストール確認

```bash
pip check
ecl --version
```

期待する結果:

```text
No broken requirements found.
ecl 4.7.1
```

## 7. CLIの起動確認

認証情報が未設定の場合、`ecl` コマンドは `auth_url` などの認証パラメータ不足で終了することがあります。CLIのロード確認だけを行う場合は、以下のようにダミー値を設定してください。

```bash
export OS_AUTH_URL=http://example.invalid
export OS_USERNAME=dummy
export OS_PASSWORD=dummy
export OS_PROJECT_NAME=dummy
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default

ecl module list
ecl help compute server list
```

`ecl module list` が表を表示し、`ecl help compute server list` が usage を表示すれば、CLIとしては起動できています。

## 8. 実環境で利用する場合

実際の Enterprise Cloud 2.0 環境に接続する場合は、ダミー値ではなく実際の認証情報を設定してください。

例:

```bash
export OS_AUTH_URL=<実際の認証URL>
export OS_USERNAME=<ユーザー名>
export OS_PASSWORD=<パスワード>
export OS_PROJECT_NAME=<プロジェクト名>
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
```

読み取り系のコマンドで確認します。

```bash
ecl module list
ecl compute server list
ecl compute flavor list
ecl image list
```

## 9. アンインストール

仮想環境から eclcli と eclsdk を削除する場合:

```bash
source ~/work/ecl-local/venv/bin/activate
pip uninstall -y eclcli eclsdk
```

削除できたことを確認します。

```bash
pip show eclcli
pip show eclsdk
```

どちらも `Package(s) not found` と表示されればOKです。

仮想環境ごと使わなくなった場合は、ターミナルを開き直すか `deactivate` してから、作業ディレクトリを削除できます。

```bash
deactivate
rm -rf ~/work/ecl-local
```

## よくあるエラー

### `No matching distribution found for eclsdk>=1.10.0`

PyPIから `eclsdk>=1.10.0` を探している状態です。PyPIにはまだ `1.10.0` がないため失敗します。

この手順の「4. eclsdk をローカル正式バージョンとしてインストール」を先に実行してください。

### `Version: 1.10.0.devN` と表示される

eclsdk に `1.10.0` タグがない状態でインストールされています。

以下を実行してから入れ直してください。

```bash
cd ~/work/ecl-local/eclsdk
git tag -f 1.10.0 HEAD
pip uninstall -y eclsdk
pip install .
```

### `Version: 4.7.1.devN` と表示される

eclcli に `4.7.1` タグがない状態でインストールされています。

以下を実行してから入れ直してください。

```bash
cd ~/work/ecl-local/eclcli
git tag -f 4.7.1 HEAD
pip uninstall -y eclcli
pip install .
```

### `pkg_resources is deprecated` という警告が出る

古いローカルインストールが残っている可能性があります。最新の eclcli ブランチでは、通常の `ecl` コマンド実行時にこの警告が表示されないようにしています。

以下のように eclcli を入れ直してください。

```bash
cd ~/work/ecl-local/eclcli
git pull
pip uninstall -y eclcli
pip install .
```

この警告は実行不能エラーではありません。表示された場合でも、コマンド自体が成功していれば利用は可能です。

### `Auth plugin requires parameters which were not given: auth_url`

認証情報が未設定です。CLIのロード確認だけであれば、手順7のダミー値を設定してください。実環境に接続する場合は、手順8のように実際の認証情報を設定してください。

## 再度利用するとき

新しいターミナルを開いた場合は、仮想環境を有効化してから `ecl` を実行してください。

```bash
source ~/work/ecl-local/venv/bin/activate
ecl --version
```
