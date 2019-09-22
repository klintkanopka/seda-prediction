#!/usr/bin/env python3

import time
import argparse

import pandas as pd
import numpy as np

import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.nn.utils.rnn
from torch.utils.data import DataLoader

import utils
from model import RNN, LSTM


def evaluate(data_set, model, params, criterion, validation=False):
    data_loader = DataLoader(data_set, batch_size=128, shuffle=False, num_workers=4)

    if not validation:
        model.load_state_dict(torch.load(params["PATH"]))
        model.to(params["DEVICE"])

    with torch.set_grad_enabled(False):
        running_loss = 0.0
        model.eval()

        for batch in data_loader:
            x = batch['sequence'].to(params["DEVICE"])
            y = batch['target'].to(params["DEVICE"])
            seq_len = batch['size'].to(params["DEVICE"])

            y_hat, hidden = model(x, seq_len)
            loss = criterion(y_hat, y)
            
            if not validation:
                df = pd.DataFrame({'y': y, 'y_hat':y_hat}, columns=['y', 'y_hat'])
                pred_path = "test_preds/" + params["PATH"][7:-2] + "csv" 
                df.to_csv(pred_path)

            running_loss += loss

    test_loss = running_loss/len(data_set)
    return test_loss

def main():

    parser = argparse.ArgumentParser(description="==========[RNN]==========")
    parser.add_argument("--mode", default="train", help="available modes: train, test, eval")
    parser.add_argument("--model", default="rnn", help="available models: rnn, lstm")
    parser.add_argument("--dataset", default="all", help="available datasets: all, MA, MI, TN")
    parser.add_argument("--rnn_layers", default=3, type=int, help="number of stacked rnn layers")
    parser.add_argument("--hidden_dim", default=16, type=int, help="number of hidden dimensions")
    parser.add_argument("--lin_layers", default=1, type=int, help="number of linear layers before output")
    parser.add_argument("--epochs", default=100, type=int, help="number of max training epochs")
    parser.add_argument("--dropout", default=0.0, type=float, help="dropout probability")
    parser.add_argument("--learning_rate", default=0.01, type=float, help="learning rate")
    parser.add_argument("--verbose", default=2, type=int, help="how much training output?")
    
    options = parser.parse_args()
    verbose = options.verbose

    if torch.cuda.is_available():
        device = torch.device("cuda")
        if verbose > 0:
            print("GPU available, using cuda...")
            print()
    else:
        device = torch.device("cpu")
        if verbose > 0:
            print("No available GPU, using CPU...")
            print()

    params = {
        "MODE": options.mode,
        "MODEL": options.model,
        "DATASET": options.dataset,
        "RNN_LAYERS": options.rnn_layers,
        "HIDDEN_DIM": options.hidden_dim,
        "LIN_LAYERS": options.lin_layers,
        "EPOCHS": options.epochs,
        "DROPOUT_PROB": options.dropout,
        "LEARNING_RATE": options.learning_rate,
        "DEVICE": device,
        "OUTPUT_SIZE": 1
    }

    params["PATH"] = "models/" + params["MODEL"] + "_" + params["DATASET"] + "_" + str(params["RNN_LAYERS"]) + "_" + str(params["HIDDEN_DIM"]) + "_" + str(params["LIN_LAYERS"]) + "_" + str(params["LEARNING_RATE"]) + "_" + str(params["DROPOUT_PROB"]) + "_" + str(params["EPOCHS"]) + "_model.pt"


    #if options.mode == "train":
    #    print("training placeholder...")


    train_data = utils.DistrictData(params["DATASET"], "train")
    val_data = utils.DistrictData(params["DATASET"], "val")

    params["INPUT_SIZE"] = train_data[0]['sequence'].size()[1]
    
    if params["MODEL"] == "rnn":
        model = RNN(params)
    elif params["MODEL"] == "lstm":
        model = LSTM(params)
    model.to(params["DEVICE"])
    criterion = nn.MSELoss(reduction='sum')
    optimizer = torch.optim.Adam(model.parameters(), lr=params["LEARNING_RATE"])

    if verbose == 0:
        print(params["PATH"])
    else:
        utils.print_params(params)
        print("Beginning training...")
        print()
    since = time.time()
    best_val_loss = 10.0
  
    for e in range(params["EPOCHS"]):
        
        running_loss = 0.0
        #model.zero_grad()
        model.train()
        train_loader = DataLoader(train_data, batch_size=32, shuffle=True, num_workers=4)
        
        for batch in train_loader:
            x = batch['sequence'].to(device)
            y = batch['target'].to(device)
            seq_len = batch['size'].to(device)

            optimizer.zero_grad()
            y_hat, hidden = model(x, seq_len)
            loss = criterion(y_hat, y)

            running_loss += loss

            loss.backward()
            optimizer.step()

        mean_loss = running_loss/len(train_data)
        val_loss = evaluate(val_data, model, params, criterion, validation=True) 
        
        if verbose == 2 or (verbose == 1 and (e+1) % 100 == 0):
            print('=' * 25 + ' EPOCH {}/{} '.format(e+1, params["EPOCHS"]) + '=' * 25)
            print('Training Loss: {}'.format(mean_loss))
            print('Validation Loss: {}'.format(val_loss))
            print()

        if e > params["EPOCHS"]/3:
            if val_loss < best_val_loss:
                best_val_loss = val_loss
                best_model = model.state_dict()
                torch.save(best_model, params["PATH"])


    time_elapsed = time.time() - since
    print('Training complete in {:.0f}m {:.0f}s'.format(time_elapsed//60, time_elapsed % 60))
    print('Final Training Loss: {:4f}'.format(mean_loss))
    print('Best Validation Loss: {:4f}'.format(best_val_loss))

    test_data = utils.DistrictData(params["DATASET"], "test")
    test_loss = evaluate(test_data, model, params, criterion)
    print('Test Loss: {}'.format(test_loss))
    print()

if __name__ == "__main__":
    main()
