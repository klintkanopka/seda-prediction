#!/usr/bin/env python3

import os
import pandas as pd
import numpy as np
import torch
import torch.nn.functional as F
from torch.utils.data import Dataset


class DistrictData(Dataset):
    """ Dataset of districts. """

    def __init__(self, data, partition):
        csv_path = 'data/' + data + '_' + partition + '.csv'
        df = pd.read_csv(csv_path)

        self.cov_seqs = []
        self.targets = []
        self.max_seq_len = 0

        colsToDrop = ['nces_id', 'cohort_year', 'discrepancy']

        for id in df.nces_id.unique():
            tmp = df.loc[df.nces_id == id]
            disc = tmp.discrepancy.iloc[0]
            if disc < -0.8152678:
                target = torch.tensor(0)
            elif disc > 0.7366931:
                target = torch.tensor(2)
            else:
                target = torch.tensor(1)
            self.targets.append(target)
            tmp_x = torch.tensor(tmp.drop(colsToDrop, axis=1).values, dtype=torch.float)
            self.cov_seqs.append(tmp_x)
            if tmp_x.size()[0] > self.max_seq_len:
                self.max_seq_len = tmp_x.size()[0]

    def __len__(self):
        return len(self.cov_seqs)

    def __getitem__(self, idx):
        sequence = self.cov_seqs[idx]
        seq_size = sequence.size()[0]
        if seq_size < self.max_seq_len:
            sequence = F.pad(input=sequence, pad = (0, 0, 0, self.max_seq_len - seq_size), value=0)
        target = self.targets[idx]
        sample = {'sequence': sequence, 'size': seq_size, 'target': target}
        return sample
        
def print_params(params):
    print("="*25 + " CLASSIFICATION MODEL OVERVIEW " + "="*25)
    print("MODE:", params["MODE"])
    print("MODEL:", params["MODEL"])
    print("DATASET:", params["DATASET"])
    print("EPOCHS:", params["EPOCHS"])
    print("RNN LAYERS:", params["RNN_LAYERS"])
    print("HIDDEN DIMENSIONS:", params["HIDDEN_DIM"])
    print("LINEAR LAYERS:", params["LIN_LAYERS"])
    print("DROPOUT PROB:", params["DROPOUT_PROB"])
    print("LEARNING RATE:", params["LEARNING_RATE"])
    print()
