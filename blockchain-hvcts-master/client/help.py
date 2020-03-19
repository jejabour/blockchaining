import csv

# The purpose of this script was to check the contents of the dataset.
# This plays no role in the execution of the CLI or the blockchain.

file=open( "ASAP_Master_v2.csv", "r")
reader = csv.reader(file)
for line in reader:
    t=line
    print(t)
    break