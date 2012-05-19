Dragon Trainer - Kublai Network Analysis Experiment
===================================================

In this repository you'll find the data and the code used to analyze the Kublai network. 

The ```NingAnonymizer``` ruby class is able to anonymize a set of ning files (for groups, members and discussions), see the ```anonymize_kublai.rb``` for an example of how to use it.

The experiment code is driven by the ```venice.rb``` file and uses the classes defined in the ```kublai_dataset.rb``` and ```kublai_parse.rb``` files. Running the venice.rb file you'll obtain the network exported as various formats (e.g. CSV, PAJEK, FOAF, ...).

Running the script
------------------

#### Prerequisites

To run the script you need to prepare your computer installing the Ruby interpreter, see here for details on how to do it for your OS: http://www.ruby-lang.org/

#### Downloading the code

Download the code from github and save it in a directory on your computer

#### Preparing the data

In the ```data``` directory there are the json files containing the normalized and anonymized data from the Kublai network: the data has been exported from Ning and its json has been fixed to be valid, it has also been anonymized removing actual names and email addresses, keeping only data that is public in the Ning network.

If you wish to use the script to analyze other ning networks you'll need to download the data and put it in the json files as follows:

* _ning-discussions-anonymized.json_ for the file containing the discussion objects
* _ning-groups-anonymized.json_ for the file containing the groups objects
* _ning-mambers-anonymized.json_ for the file containing the user objects

#### Extracting the network

From the command line:

* cd into the dt_kublai_mapper directory
* run the command ```ruby -rubygems venice.rb```

While running the script will log to the screen traces and eventually errors or warnings it finds.

In the ```data/extracted``` directory you'll find the extracted network exported in different formats: CSV, graphml, FOAF (.rdf files), Pajek (.net files, this is usable also in Tulip via the import function.) For each format there are 3 files exported:

* _alltime_ contains the network extracted without any filter on the date
* _20091231_ contains the network extracted excluding all the data after December 31, 2009
* _20090315_ contains the network extracted excluding all the data after March 15, 2009

N.B. Each CSV export is split in an edges file and a nodes file.

