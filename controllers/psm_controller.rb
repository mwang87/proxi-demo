require 'rack'


get '/psm/:psmid' do
    @psm = Peptidespectrummatch.first(:id => params[:psmid])

    remote_server_url = "http://massive.ucsd.edu" + "/ProteoSAFe/DownloadResultFile?"
    

    parameters_string = Rack::Utils.build_query({   :invoke => "annotatedSpectrumImageText", 
        :task => @psm.dataset.task_id,
        :block => "0",
        :file => "FILE->peak/" + @psm.filename,
        :scan => @psm.scan,
        :peptide => "*..*",
        :dataset => @psm.dataset.name,
        :jsonp => "1"})
    
    @remote_peaks_url = remote_server_url + parameters_string



    haml :psm_page
end

#Aggregate View
get '/psms/aggregateview' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)
	@page_number = page_number

    protein = params[:protein]
    peptide = params[:peptide]
    modification = params[:mod]
    dataset_query = params[:dataset]

    sort_direction = params[:sort]
    sort_type = params[:sorttype]

    if protein == nil
        protein = ""
    end

    if peptide == nil
        peptide = ""
    end

    if modification == nil
        modification = ""
    end

    if dataset_query == nil
        dataset_query = ""
    end

    if sort_direction == nil
        sort_direction = ""
    end

    if sort_type == nil
        sort_type = ""
    end


    #Web Rendering Code
    @protein_input = protein
    @peptide_input = peptide
    @modification_input = modification
    @dataset_input = dataset_query

    @param_string = "protein=" + protein + "&peptide=" + peptide + "&mod=" + CGI.escape(modification) + "&dataset=" + dataset_query
    @sort_string = "&sort=" + sort_direction + "&sorttype=" + sort_type

    #@all_proteins_autocomplete = Protein.all().map(&:name)
    @all_modifications = Modification.all().map(&:name)
    @all_datasets = Dataset.all().map(&:name)

    #Actual Processing

    #DB Fields
    peptides_db = nil
    protein_db = nil
    mod_db = nil

    query_parameters = Hash.new
    query_parameters[:offset]  = (page_number - 1) * PAGINATION_SIZE
    query_parameters[:limit]  = PAGINATION_SIZE

    count_parameters = Hash.new

    if protein.length > 2
        protein_db = Protein.first(:name => protein)
        query_parameters[:protein] = protein_db
        count_parameters[:protein] = protein_db
    end

    if peptide.length > 2
        query_peptide = "%" + peptide + "%"
        peptides_db = Peptide.all(:sequence.like => query_peptide)
        query_parameters[:peptide] = peptides_db
        count_parameters[:peptide] = peptides_db
    end

    if modification.length > 2
        mod_db = Modification.first(:name => modification)
        query_parameters[:modificationpeptidespectrummatch] = ModificationPeptidespectrummatch.all(:modification => mod_db)
        count_parameters[:modificationpeptidespectrummatch] = ModificationPeptidespectrummatch.all(:modification => mod_db)
    end

    if dataset_query.length > 2
        #Pipes separate multiple queries
        multi_dataset_query = dataset_query.split("|")
        full_datasets_db = nil

        multi_dataset_query.each { |each_dataset_query|
            dataset_sql_query = "%" + each_dataset_query + "%"
            dataset_db = Dataset.all(:name.like => dataset_sql_query)
            puts dataset_db
            if full_datasets_db == nil
                full_datasets_db = dataset_db
            else
                full_datasets_db += dataset_db
            end
        }

        
        query_parameters[:dataset] = full_datasets_db
        count_parameters[:dataset] = full_datasets_db
    end

    #Determining the sorting direction and for what field
    if sort_type == "sequence"
        if sort_direction == "up"
            query_parameters[:order] = [:sequence.desc]
        else
            query_parameters[:order] = [:sequence.asc]
        end
    end

    @psms = Peptidespectrummatch.all(query_parameters)
    @total_count = Peptidespectrummatch.count(count_parameters)

    if (@next_page - 1) * PAGINATION_SIZE > @total_count
        @next_page = nil
    end

    return haml :psms_aggregate

end
