#!/usr/bin/python

import requests
import json
import ming_parallel_library
import os

#Returns all datasets as a list of dataset objects
def get_all_datasets():
    SERVER_URL = "http://gnps.ucsd.edu/ProteoSAFe/datasets_json.jsp"

    url = SERVER_URL
    r = requests.get(url)
    json_object = json.loads(r.text)

    return json_object["datasets"];

def get_metadata_for_tab_file(root_url, task_id, tab_id):
    tab_url = root_url + "/ProteoSAFe/result_json.jsp?task=" + task_id + "&view=group_by_spectrum" + "&file=" + tab_id
    print tab_url
    result = json.loads(requests.get(tab_url).text)
    return_meta_data = {}
    return_meta_data["total_rows"] = result["blockData"]["total_rows"]
    return_meta_data["db_file"] = result["blockData"]["file"]

    return return_meta_data

def process_all_populate_parameters(parameters_list, parallel=False):
    if parallel:
        ming_parallel_library.run_parallel_job(run_populate_parameters, parameters_list, 100)
    else:
        for parameter in parameters_list:
            run_populate_parameters(parameter)


def run_populate_parameters(parameters):
    #print parameters
    cmd = "ruby ./populate_parallel_tab_pages.rb "
    cmd += parameters["datasetid"] + " "
    cmd += parameters["taskid"] + " "
    cmd += parameters["tab_file"] + " "
    cmd += parameters["db_file"] + " "
    cmd += parameters["rooturl"] + " "
    cmd += str(parameters["offset"]) + " "
    cmd += str(parameters["pagesize"]) + " "
    os.system(cmd)
    return "DONE"

PAGE_SIZE = 50
root_url = "http://massive.ucsd.edu"

def main():
    all_populate_parameters = []

    all_datasets = get_all_datasets()
    for dataset in all_datasets:
        if dataset["status"] == "Complete":
            dataset_id = dataset["dataset"]
            dataset_information_url = root_url + "/ProteoSAFe/MassiveServlet?massiveid=" + dataset_id + "&function=massiveinformation"

            ###SHOULD CHECK IF DATASET IS ALREADY IN THERE, IF SO, STOP
            result = requests.get(dataset_information_url)

            dataset_information = json.loads(result.text)
            task_id = dataset_information["task"]
            #puts task_id
            tab_list_url = root_url + "/ProteoSAFe/result_json.jsp?task=" + task_id + "&view=view_result_list"

            tabs_list = json.loads(requests.get(tab_list_url).text)["blockData"]

            for tab_obj in tabs_list:
                #print dataset_id + "\t" + tab_obj["MzTab_file"]
                tab_meta_data = get_metadata_for_tab_file(root_url, task_id, tab_obj["MzTab_file"])
                range_of_offsets = range(0, int(tab_meta_data["total_rows"]), PAGE_SIZE)
                for offset in range_of_offsets:
                    db_populate_parameters = {}
                    db_populate_parameters["total_rows"] = tab_meta_data["total_rows"]
                    db_populate_parameters["tab_file"] = tab_obj["MzTab_file"]
                    db_populate_parameters["db_file"] = tab_meta_data["db_file"]
                    db_populate_parameters["offset"] = offset
                    db_populate_parameters["pagesize"] = PAGE_SIZE
                    db_populate_parameters["rooturl"] = root_url
                    db_populate_parameters["datasetid"] = dataset_id
                    db_populate_parameters["taskid"] = task_id

                    all_populate_parameters.append(db_populate_parameters)


            #Testing
            #break
    #Testing
    exit(0)
    process_all_populate_parameters(all_populate_parameters, True)

    #print "MING"
    #cmd = "ruby ./populate_db.rb " + dataset["dataset"] + " &"
    #print cmd


if __name__ == "__main__":
    main()
