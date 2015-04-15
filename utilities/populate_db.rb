#!/usr/bin/env ruby

require 'json'
require '../settings'
require '../models'
require '../controller_peptide'
require 'net/http'



def http_get(url)
    url = URI.parse(url)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    return res.body
end


#Parses an MGF spectral library. See Ming about this stuff.
def parse_mgf_library(library_name, library_db_name)
    spectra_object = nil
    peaks_list = []
    
    library_db = Library.first_or_create(:name => library_db_name)
    
    File.open(library_name, "r").each_line do |line|
        if line.include? "BEGIN IONS"
            spectra_object = Spectrum.new
            peaks_list = []
            next
        end
        
        if line.include? "END IONS"
            puts "SAVING " + spectra_object.peptide
            spectra_object.peaks = peaks_list.to_json
            spectra_object.library = library_db
            spectra_object.save
            next
        end
        
        if line.include? "="
            field = line.split("=")[0]
            value = line.split("=")[1].rstrip
            
            if field == "CHARGE"
                spectra_object.charge = Integer(value.gsub(/[+]/,''))
            end
            
            if field == "SEQ"
                spectra_object.peptide = value
                spectra_object.unmodifiedpeptide = value.gsub(/[().+-,0-9]+/,'')
            end
            
            
            if field == "PRECURSOR"
                spectra_object.precursor = Float(value)
            end
            
            if field == "PEPMASS"
                spectra_object.precursor = Float(value)
            end
        else
            if line.length > 5
                #these are probably peaks
                splits = line.split("\t")
                peaks_list.push([Float(splits[0]), Float(splits[1])])
            end
        end
    end
end


def create_library_db_name(library_db_name)
    Library.first_or_create(:name => library_db_name)
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
    
    tab_data.each{ |psm_object|
        psm_count += 1
        puts psm_count.to_s + " of " + tab_data.length.to_s
	spectrum_file = psm_object["#SpecFile"]
	scan =  psm_object["nativeID_scan"]
        peptide = psm_object["modified_sequence"]
	
    
        peptide_db = get_create_peptide(peptide)
        #puts peptide_db
        dataset_db = get_create_dataset(dataset_id)
        #puts dataset_db
        
        join_db = create_dataset_peptide_link(peptide_db, dataset_db)
    
        get_create_psm(peptide_db, dataset_db, tsv_id, scan, spectrum_file)
    }
end


#create_library_db_name(ARGV[1])
#parse_mgf_library(ARGV[0], ARGV[1])

import_results_dataset(ARGV[0])

