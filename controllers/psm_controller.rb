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
	
    protein = params[:protein]
    peptide = params[:peptide]
    modification = params[:mod]

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

    @all_proteins_autocomplete = Protein.all().map(&:name)
    @all_modifications = Modification.all().map(&:name)

    #Actual Processing

    filter_protein = false
    filter_peptide = false
    filter_mod = false

    #DB Fields
    peptides_db = nil
    protein_db = nil
    mod_db = nil

    if protein.length > 2
        filter_protein = true
        protein_db = Protein.first(:name => protein)
    end

    if peptide.length > 2
        filter_peptide = true
        query_peptide = "%" + peptide + "%"
        peptides_db = Peptide.all(:sequence.like => query_peptide)
    end

    if modification.length > 2
        filter_mod = true
        mod_db = Modification.first(:name => modification)
    end

    #Now we do a big switch statement
    if filter_protein and filter_peptide and filter_mod
        @psms = Peptidespectrummatch.all(
    		:peptide => peptides_db,
    		:protein => protein_db,
    		:modificationpeptidespectrummatch => ModificationPeptidespectrummatch.all(:modification => mod_db),
    		:offset => (page_number - 1) * PAGINATION_SIZE, 
        	:limit => PAGINATION_SIZE)

        @total_count = Peptidespectrummatch.count(
            :peptide => peptides_db,
            :protein => protein_db,
            :modificationpeptidespectrummatch => ModificationPeptidespectrummatch.all(:modification => mod_db))

        return haml :psms_aggregate
    end

    if filter_protein and filter_peptide
        @psms = Peptidespectrummatch.all(
    		:peptide => peptides_db,
    		:protein => protein_db,
    		:offset => (page_number - 1) * PAGINATION_SIZE, 
        	:limit => PAGINATION_SIZE)

        @total_count = Peptidespectrummatch.count(
            :peptide => peptides_db,
            :protein => protein_db)

        return haml :psms_aggregate
    end

    if filter_peptide and filter_mod
    	#likely need to write custom sql to optimize, TODO
    	@psms = Peptidespectrummatch.all(
    		:peptide => peptides_db,
    		:modificationpeptidespectrummatch => ModificationPeptidespectrummatch.all(:modification => mod_db),
    		:offset => (page_number - 1) * PAGINATION_SIZE, 
        	:limit => PAGINATION_SIZE)
        
        @total_count = Peptidespectrummatch.count(
            :peptide => peptides_db,
            :modificationpeptidespectrummatch => ModificationPeptidespectrummatch.all(:modification => mod_db))

        return haml :psms_aggregate
    end

    if filter_protein and filter_mod
    	#likely need to write custom sql to optimize, TODO
    	@psms = Peptidespectrummatch.all(
    		:protein => protein_db,
    		:modificationpeptidespectrummatch => ModificationPeptidespectrummatch.all(:modification => mod_db),
        	:offset => (page_number - 1) * PAGINATION_SIZE, 
        	:limit => PAGINATION_SIZE)

        @total_count = Peptidespectrummatch.count(
            :protein => protein_db,
            :modificationpeptidespectrummatch => ModificationPeptidespectrummatch.all(:modification => mod_db))

        return haml :psms_aggregate
    end

    if filter_protein
        @psms = Peptidespectrummatch.all(
        	:protein => protein_db,
        	:offset => (page_number - 1) * PAGINATION_SIZE, 
        	:limit => PAGINATION_SIZE)

    	@total_count = Peptidespectrummatch.count(
            :protein => protein_db)

        return haml :psms_aggregate
    end

    if filter_peptide
        @psms = Peptidespectrummatch.all(
        	:peptide => peptides_db,
        	:offset => (page_number - 1) * PAGINATION_SIZE, 
        	:limit => PAGINATION_SIZE)

        @total_count = Peptidespectrummatch.count(
            :peptide => peptides_db)

        return haml :psms_aggregate
    end

    if filter_mod
    	#likely need to write custom sql to optimize, TODO
        @psms = Peptidespectrummatch.all(
        	:modificationpeptidespectrummatch => ModificationPeptidespectrummatch.all(:modification => mod_db),
        	:offset => (page_number - 1) * PAGINATION_SIZE, 
        	:limit => PAGINATION_SIZE)

        @total_count = Peptidespectrummatch.count(
            :modificationpeptidespectrummatch => ModificationPeptidespectrummatch.all(:modification => mod_db))

        return haml :psms_aggregate
    end

    @psms = Peptidespectrummatch.all(
        	:offset => (page_number - 1) * PAGINATION_SIZE, 
        	:limit => PAGINATION_SIZE)

    @total_count = Peptidespectrummatch.count

    return haml :psms_aggregate
end

