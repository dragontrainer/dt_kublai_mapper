Dragon Trainer - Kublai Network Analysis Experiment
===================================================

In this repository you'll find the data and the code used to analyze the Kublai network. 

In the ```data``` directory there are the json files containing the normalized and anonymized data from the Kublai network: the data has been exported from Ning and its json has been fixed to be valid, it has also been anonymized removing actual names and email addresses, keeping only data that is public in the Ning network.

The ```NingAnonymizer``` ruby class is able to anonymize a set of ning files (for groups, members and discussions), see the ```anonymize_kublai.rb``` for an example of how to use it.

The experiment code is driven by the ```venice.rb``` file and uses the classes defined in the ```kublai_dataset.rb``` and ```kublai_parse.rb``` files. Running the venice.rb file you'll obtain the network exported as various formats (e.g. CSV, PAJEK, FOAF, ...).
