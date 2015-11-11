#!/usr/bin/env bash
nohup /home/ubuntu/bts/muse/programs/witness_node/witness_node -d /home/ubuntu/bts/muse/data_dir --rpc-endpoint 127.0.0.1:8090 -s 54.165.143.33:5197 --genesis-json /home/ubuntu/bts/muse/genesis.json > /home/ubuntu/bts/muse/wn0.log 2>&1 &
nohup /home/ubuntu/bts/muse/programs/witness_node/witness_node -d /home/ubuntu/bts/muse/data_dir1 --rpc-endpoint 127.0.0.1:8091 -s 54.165.143.33:5197 --genesis-json /home/ubuntu/bts/muse/genesis.json > /home/ubuntu/bts/muse/wn1.log 2>&1 &
nohup /home/ubuntu/bts/muse/programs/witness_node/witness_node -d /home/ubuntu/bts/muse/data_dir2 --rpc-endpoint 127.0.0.1:8092 -s 54.165.143.33:5197 --genesis-json /home/ubuntu/bts/muse/genesis.json > /home/ubuntu/bts/muse/wn2.log 2>&1 &
nohup /home/ubuntu/bts/muse/programs/witness_node/witness_node -d /home/ubuntu/bts/muse/data_dir3 --rpc-endpoint 127.0.0.1:8093 -s 54.165.143.33:5197 --genesis-json /home/ubuntu/bts/muse/genesis.json > /home/ubuntu/bts/muse/wn3.log 2>&1 &
