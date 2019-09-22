#!/bin/bash

models='rnn lstm'
epochs=2500
lin_layers='5 10 25'
rnn_layers='1 2 3'
dims='64 128 256'
lambdas='0.001'
dropouts='0.0 0.1 0.2'

for model in $models
do
    for epoch in $epochs
    do
        for lin_layer in $lin_layers
        do
            for dim in $dims
            do
                for lambda in $lambdas
                do
                    for rnn_layer in $rnn_layers
                    do
                        if [ $rnn_layer -eq '1' ]
                        then
                            python3 run.py --dataset level_std --model $model --epochs $epoch --rnn_layers $rnn_layer --lin_layers $lin_layer --hidden_dim $dim --learning_rate $lambda --verbose 1  | tee -a train_log.txt
                        else
                            for dropout in $dropouts
                            do
                                python3 run.py --dataset level_std --model $model --epochs $epoch --rnn_layers $rnn_layer --lin_layers $lin_layer --hidden_dim $dim --learning_rate $lambda --dropout $dropout --verbose 1  | tee -a train_log.txt
                            done
                        fi
                    done
                done
            done
        done
    done
    echo 
    python3 notify_slack.py "all $model tests complete"
done
echo "done!"
