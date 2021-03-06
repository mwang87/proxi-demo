#!/usr/bin/env ruby

require 'json'
require './populate_settings'
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
    ###SHOULD CHECK IF DATASET IS ALREADY IN THERE, IF SO, STOP

    result = http_get(dataset_information)
    #print result

    dataset_information = JSON.parse(result)
    task_id = dataset_information["task"]
    #puts task_id
    tab_list_url = root_url + "/ProteoSAFe/result_json.jsp?task=" + task_id + "&view=view_result_list"

    tabs_list = JSON.parse(http_get(tab_list_url))["blockData"]

    #Singly Threaded
    import_all_tab_files(tabs_list, dataset_id, task_id, root_url)

    #Multiprocess
    #import_all_tab_files_parallel(tabs_list, dataset_id, task_id, root_url)
end

def import_results_task(task_id)
    #Get task_id for dataset_id
    #http://gnps.ucsd.edu/ProteoSAFe/MassiveServlet?massiveid=MSV000078711&function=massiveinformation
    root_url = "http://proteomics2.ucsd.edu"

    task_status_info = root_url + "/ProteoSAFe/status_json.jsp?task=" + task_id
    puts task_status_info
    task_information = JSON.parse(http_get(task_status_info))
    task_description = task_information["description"]
    task_workflow = task_information["workflow"]
    puts task_description

    #puts task_id
    tab_list_url = root_url + "/ProteoSAFe/result_json.jsp?task=" + task_id + "&view=view_result_list"
    puts tab_list_url

    tabs_list = JSON.parse(http_get(tab_list_url))["blockData"]

    task_label = task_workflow + " - " + task_id + " - " + task_description
    puts task_label

    #Singly Threaded
    import_all_tab_files(tabs_list, task_label, task_id, root_url)

    #Multiprocess
    #import_all_tab_files_parallel(tabs_list, dataset_id, task_id, root_url)
end

#Takes a list of tab files, single threaded, one process
def import_all_tab_files(tabs_list, dataset_id, task_id, root_url)
    tabs_list.each { |tab_object|
        tab_file = tab_object["MzTab_file"]
        import_dataset_tab_psm_file(dataset_id, task_id, tab_file, root_url)
    }
end

#Takes a list of tab files, multiprocess threaded
def import_all_tab_files_parallel(tabs_list, dataset_id, task_id, root_url)
    max_parallelism = 10
    running_parallelism = 0
    wait_seconds = 10

    tabs_list.each { |tab_object|
        tab_file = tab_object["MzTab_file"]

        running_parallelism += 1

        fork do
            #import_dataset_tab_psm_file(dataset_id, task_id, tab_file, root_url)
            import_tab_cmd = "ruby ./populate_parallel_tab.rb "
            import_tab_cmd += dataset_id + " "
            import_tab_cmd += task_id + " "
            import_tab_cmd += tab_file + " "
            import_tab_cmd += root_url

            puts import_tab_cmd
            `#{import_tab_cmd}`

            abort
        end

        sleep(wait_seconds)
        if running_parallelism == max_parallelism
            Process.waitall
            running_parallelism = 0
        end
    }

    Process.waitall
end

def import_dataset_tab_psm_page(dataset_id, task_id, tsv_id, db_filename, root_url, offset, pageSize)
    tab_db_filename = db_filename
    tab_information_url = root_url + "/ProteoSAFe/QueryResult?task=" + task_id + "&file=" + tab_db_filename
    tab_information_url += "&pageSize=" + pageSize.to_s() + "&offset=" + offset.to_s()

    puts tab_information_url

    tab_data = JSON.parse(http_get(tab_information_url))["row_data"]
    #puts tab_data

    dataset_db = get_create_dataset(dataset_id, task_id)

    tab_data.each{ |psm_object|
        spectrum_file = psm_object["#SpecFile"]
        internal_spectrum_file = psm_object["internalFilename"]
        scan =  psm_object["nativeID_scan"]
        peptide = psm_object["modified_sequence"]
        protein = psm_object["accession"]
        modification_string = psm_object["modifications"]
        #puts modification_string

        #Adding Proteins
        protein_db = get_create_protein(protein)
        protein_dataset_join = create_dataset_protein_link(protein_db, dataset_db)

        modifications_list = Array.new
        if modification_string != "null"
            modifications_list = modification_string.split(',')
        end

        #puts modifications_list


        peptide_db, variant_db = get_create_peptide(peptide, dataset_db, protein_db)
        psm_db = get_create_psm(variant_db, dataset_db, protein_db, peptide_db, tsv_id, scan, spectrum_file, internal_spectrum_file, peptide)
        get_create_modification(modifications_list, peptide_db, variant_db, dataset_db, protein_db, psm_db)
    }

    return tab_data.length
end

def import_dataset_tab_psm_file(dataset_id, task_id, tsv_id, root_url)
    offset = 0
    pageSize = 100

    #Hit the URL first to make sure the sqlite database is available
    tab_url = root_url + "/ProteoSAFe/result_json.jsp?task=" + task_id + "&view=group_by_spectrum" + "&file=" + tsv_id
    db_filename = JSON.parse(http_get(tab_url))["blockData"]["file"]


    while(1) do
        results_gotten = import_dataset_tab_psm_page(dataset_id, task_id, tsv_id, db_filename, root_url, offset, pageSize)
        offset += pageSize

        if results_gotten < pageSize then
            return
        end

        #puts tsv_id
        #tab_db_filename = "group_by_spectrum" + "-main_" + tsv_id.gsub(".mzTab", ".db")
        #tab_information_url = root_url + "/ProteoSAFe/QueryResult?task=" + task_id + "&file=" + tab_db_filename
        #tab_information_url += "&pageSize=" + pageSize.to_s() + "&offset=" + offset.to_s()
        #puts tab_information_url
        #tab_data = JSON.parse(http_get(tab_information_url))["row_data"]

        #puts tab_data.length.to_s()

        #puts "Parsing Tab: " + tsv_id + " with " + tab_data.length.to_s + " entries "

        #psm_count = 0
        #dataset_db = get_create_dataset(dataset_id, task_id)

        # tab_data.each{ |psm_object|
        #     psm_count += 1
        #     #puts psm_count.to_s + " of " + tab_data.length.to_s
        #     spectrum_file = psm_object["#SpecFile"]
        #     internal_spectrum_file = psm_object["internalFilename"]
        #     scan =  psm_object["nativeID_scan"]
        #     peptide = psm_object["modified_sequence"]
        #     protein = psm_object["accession"]
        #     modification_string = psm_object["modifications"]
        #     puts modification_string
        #
        #     #Adding Proteins
        #     protein_db = get_create_protein(protein)
        #     protein_dataset_join = create_dataset_protein_link(protein_db, dataset_db)
        #
        #     modifications_list = Array.new
        #     if modification_string != "null"
        #         modifications_list = modification_string.split(',')
        #     end
        #
        #     puts modifications_list
        #
        #
        #     peptide_db, variant_db = get_create_peptide(peptide, dataset_db, protein_db)
        #     psm_db = get_create_psm(variant_db, dataset_db, protein_db, peptide_db, tsv_id, scan, spectrum_file, internal_spectrum_file, peptide)
        #     get_create_modification(modifications_list, peptide_db, variant_db, dataset_db, protein_db, psm_db)
        #
        # }


    end

end

###Testing Fork Logic
def test_fork()
    max_parallelism = 4
    running_parallelism = 0

    10.times do |i|
        puts i

        running_parallelism += 1
        fork do
            puts "Child"
            abort
        end

        if running_parallelism == max_parallelism
            Process.waitall
            running_parallelism = 0
        end
    end
end
