#!/usr/bin/env python3

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.nn.utils.rnn

class RNN(nn.Module):
    def __init__(self, params):
        super(RNN, self).__init__()

        self.hidden_dim = params["HIDDEN_DIM"]
        self.n_rnn_layers = params["RNN_LAYERS"]
        self.n_linear_layers = params["LIN_LAYERS"]
        self.input_size = params["INPUT_SIZE"]
        self.output_size = params["OUTPUT_SIZE"]
        self.dropout_prob = params["DROPOUT_PROB"]

        # RNN Layer
        self.rnn = nn.RNN(self.input_size, self.hidden_dim, self.n_rnn_layers, dropout=self.dropout_prob, batch_first=True)

        # fully connected layers
        for i in range(self.n_linear_layers):
            lin_layer = nn.Linear(self.hidden_dim, self.hidden_dim)
            lin_name = "lin_" + str(i)
            setattr(self, lin_name, lin_layer)

        #self.lin1 = nn.Linear(self.hidden_dim, self.hidden_dim)
        #self.lin2 = nn.Linear(self.hidden_dim, self.hidden_dim)
        self.output = nn.Linear(self.hidden_dim, self.output_size)

    def forward(self, x, seq_len):
        batch_size = x.size(0)

        X = torch.nn.utils.rnn.pack_padded_sequence(x, seq_len, enforce_sorted=False, batch_first=True)

        output, h_n = self.rnn(X)
        X = h_n[-1,:,:]
        
        for i in range(self.n_linear_layers):
            X = F.relu(self.get_linear(i)(X))
        
        Y_hat = self.output(X)

        Y_hat = Y_hat.view(Y_hat.size()[0])

        return Y_hat, h_n

    def get_linear(self, i):
        lin_name = "lin_" + str(i)
        return getattr(self, lin_name)

class LSTM(nn.Module):
    def __init__(self, params):
        super(LSTM, self).__init__()

        self.hidden_dim = params["HIDDEN_DIM"]
        self.n_rnn_layers = params["RNN_LAYERS"]
        self.n_linear_layers = params["LIN_LAYERS"]
        self.input_size = params["INPUT_SIZE"]
        self.output_size = params["OUTPUT_SIZE"]
        self.dropout_prob = params["DROPOUT_PROB"]

        # RNN Layer
        self.rnn = nn.LSTM(self.input_size, self.hidden_dim, self.n_rnn_layers, dropout=self.dropout_prob, batch_first=True)
        
        # linear layers
        for i in range(self.n_linear_layers):
            lin_layer = nn.Linear(self.hidden_dim, self.hidden_dim)
            lin_name = "lin_" + str(i)
            setattr(self, lin_name, lin_layer)

        self.output = nn.Linear(self.hidden_dim, self.output_size)

    def forward(self, x, seq_len):
        batch_size = x.size(0)

        X = torch.nn.utils.rnn.pack_padded_sequence(x, seq_len, enforce_sorted=False, batch_first=True)

        (h_n, c_n) = (torch.zeros(self.n_rnn_layers, batch_size, self.hidden_dim), torch.zeros(self.n_rnn_layers, batch_size, self.hidden_dim))

        output, (h_n, c_n) = self.rnn(X, (h_n, c_n))

        X = h_n[-1,:,:]

        for i in range(self.n_linear_layers):
            X = F.relu(self.get_linear(i)(X))
        
        #X = F.relu(self.lin1(X))
        #X = F.relu(self.lin2(X))
        Y_hat = self.output(X)

        Y_hat = Y_hat.view(Y_hat.size()[0])

        return Y_hat, h_n

    def get_linear(self, i):
        lin_name = "lin_" + str(i)
        return getattr(self, lin_name)

