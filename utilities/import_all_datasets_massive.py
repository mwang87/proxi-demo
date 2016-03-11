#!/usr/bin/python

import requests
import json

#Returns all datasets as a list of dataset objects
def get_all_datasets():
    SERVER_URL = "http://gnps.ucsd.edu/ProteoSAFe/datasets_json.jsp"

    url = SERVER_URL
    r = requests.get(url)
    json_object = json.loads(r.text)

    return json_object["datasets"];


def main():
    all_datasets = get_all_datasets()
    for dataset in all_datasets:
        if dataset["status"] == "Complete":
            cmd = "ruby ./populate_db.rb " + dataset["dataset"] + " &"
            print cmd


if __name__ == "__main__":
    main()
