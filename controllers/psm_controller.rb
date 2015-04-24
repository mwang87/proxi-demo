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


get '/modification/:mod/psm/list' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    mod_db = Modification.first(:id => params[:mod])

    @psms = Datasetvariantspectrummatch.all(:DatasetVariant => DatasetVariant.all(:variant => mod_db.variants), :offset => (page_number - 1) * PAGINATION_SIZE, :limit => PAGINATION_SIZE)

    haml :psms_all

end

get '/peptide/:peptide/psm/list' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)

	peptide_db = Peptide.first(:sequence => params[:peptide])

	@psms = Datasetvariantspectrummatch.all(
		:DatasetVariant => DatasetVariant.all(:variant => peptide_db.variants), 
		:offset => (page_number - 1) * PAGINATION_SIZE, 
		:limit => PAGINATION_SIZE)	

    haml :psms_all
end


get '/protein/:protein/psm/list' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)

	protein_db = Protein.first(:id => params[:protein])

	@psms = Datasetvariantspectrummatch.all(
		:DatasetProtein => DatasetProtein.all(:protein => protein_db), 
		:offset => (page_number - 1) * PAGINATION_SIZE, 
		:limit => PAGINATION_SIZE)	

    haml :psms_all
end


#Aggregate View

#Aggregate View
get '/psms/aggregateview' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)
	@page_number = page_number

    protein = params[:protein]
    peptide = params[:peptide]
    modification = params[:mod]

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

    #Web Rendering Code
    @protein_input = protein
    @peptide_input = peptide
    @modification_input = modification

    @param_string = "protein=" + protein + "&peptide=" + peptide + "&mod=" + modification

    #@all_proteins_autocomplete = Protein.all().map(&:name)
    @all_modifications = Modification.all().map(&:name)

    #Actual Processing
    filter_protein = false
    filter_peptide = false
    filter_mod = false

    #DB Fields
    peptides_db = nil
    protein_db = nil
    mod_db = nil

    query_parameters = Hash.new
    query_parameters[:offset]  = (page_number - 1) * PAGINATION_SIZE
    query_parameters[:limit]  = PAGINATION_SIZE

    count_parameters = Hash.new

    if protein.length > 2
        filter_protein = true
        protein_db = Protein.first(:name => protein)
        query_parameters[:protein] = protein_db
        count_parameters[:protein] = protein_db
    end

    if peptide.length > 2
        filter_peptide = true
        query_peptide = "%" + peptide + "%"
        peptides_db = Peptide.all(:sequence.like => query_peptide)
        query_parameters[:peptide] = peptides_db
        count_parameters[:peptide] = peptides_db
    end

    if modification.length > 2
        filter_mod = true
        mod_db = Modification.first(:name => modification)
        query_parameters[:modificationpeptidespectrummatch] = ModificationPeptidespectrummatch.all(:modification => mod_db)
        count_parameters[:modificationpeptidespectrummatch] = ModificationPeptidespectrummatch.all(:modification => mod_db)
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

    return haml :psms_aggregate

end
