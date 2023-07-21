#! /bin/bash


# CONSTANTS
MIN_SHAMT=0
MAX_SHAMT=$(( 2 ** 5 ))

MAX_IMMEDIATE_UNSIGNED=$(( 2 ** 16 - 1))
MIN_IMMEDIATE=$(( - 2 ** 15  ))
MAX_IMMEDIATE=$(( - MIN_IMMEDIATE - 1 ))

MAX_WORD_UNSIGNED=$(( 2 ** 32 - 1))
MIN_WORD=$(( - 2 ** 31  ))
MAX_WORD=$(( - MIN_WORD - 1 ))

MAX_DWORD_UNSIGNED=$(( 2 ** 64 - 1))
MIN_DWORD=$(( - 2 ** 63 ))
MAX_DWORD=$(( - MAX_DWORD -1  ))