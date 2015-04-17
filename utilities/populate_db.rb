#!/usr/bin/env ruby

require 'json'
require '../settings'
require '../models'

require '../utils/utils'
require '../utils/protein_utils'
require '../utils/peptide_utils'
require '../utils/modification_utils'

require 'net/http'



def http_get(url)
    url = URI.parse(url)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    return res.body
end

def import_results_dataset(dataset_id)
    #Get task_id for dataset_id
    #http://gnps.ucsd.edu/ProteoSAFe/MassiveServlet?massiveid=MSV000078711&function=massiveinformation
    root_url = "http://massive.ucsd.edu"
    dataset_information = root_url + "/ProteoSAFe/MassiveServlet?massiveid=" + dataset_id + "&function=massiveinformation"
    puts dataset_information
    result = http_get(dataset_information)
    #print result
    
    dataset_information = JSON.parse(result)
    task_id = dataset_information["task"]
    print task_id
    tab_list_url = root_url + "/ProteoSAFe/result_json.jsp?task=" + task_id + "&view=view_result_list"
    
    tabs_list = JSON.parse(http_get(tab_list_url))["blockData"]
    tabs_list.each { |tab_object| 
        tab_file = tab_object["MzTab_file"]
        import_dataset_tab_psm_file(dataset_id, task_id, tab_file, root_url)
    }
end

def import_dataset_tab_psm_file(dataset_id, task_id, tsv_id, root_url)
    tab_information_url = root_url + "/ProteoSAFe/result_json.jsp?task=" + task_id + "&view=group_by_spectrum&file=" + tsv_id
    tab_data = JSON.parse(http_get(tab_information_url))["blockData"]
    
    psm_count = 0
    dataset_db = get_create_dataset(dataset_id)
    
    tab_data.each{ |psm_object|
        psm_count += 1
        puts psm_count.to_s + " of " + tab_data.length.to_s
        spectrum_file = psm_object["#SpecFile"]
        scan =  psm_object["nativeID_scan"]
        peptide = psm_object["modified_sequence"]
        protein = psm_object["accession"]
        modification_string = psm_object["modifications"]

        modifications_list = Array.new
        if modification_string != "null"
            modifications_list = modification_string.split(',')
        end

	
        variant_db, peptide_db = get_create_peptide(peptide, modifications_list)
        #join_db = create_dataset_peptide_link(peptide_db, basicpeptide_db, dataset_db)
        #get_create_psm(peptide_db, dataset_db, join_db, tsv_id, scan, spectrum_file)

        #Adding Proteins
        #protein_db = get_create_protein(protein)
        #protein_dataset_join = create_dataset_protein_link(protein_db, dataset_db)
    }
end


#create_library_db_name(ARGV[1])
#parse_mgf_library(ARGV[0], ARGV[1])

import_results_dataset(ARGV[0])

