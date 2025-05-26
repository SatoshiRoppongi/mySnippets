#!/bin/bash

set -e

# ディレクトリ作成
mkdir -p test_inscriptions
cd test_inscriptions

# 1〜500のファイル作成
for i in $(seq 1 500); do
  echo "$i" > "i${i}.txt"
done

# 各ファイルに対してordとbitcoin-cliを実行
for j in $(seq 1 500); do
  echo "Inscribe: i${j}.txt"
  
  # ord コマンド実行して結果を temp_output.json に保存
  ord_output=$(ord --datadir ../env wallet inscribe --fee-rate 1 --file "i${j}.txt" --no-backup)

  # destinationアドレスをJSONから抽出
  destination=$(echo "$ord_output" | jq -r '.inscriptions[0].destination')

  if [ -z "$destination" ]; then
    echo "Error: destination address not found for i${j}.txt"
    exit 1
  fi

  echo "Generate block to address: $destination"
  bitcoin-cli -datadir=../env generatetoaddress 1 "$destination"
done
