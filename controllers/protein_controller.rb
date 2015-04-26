#Zero Conditions
get '/protein/list' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    @all_proteins = Protein.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)
    
    haml :protein_all
end

#Single Conditions




#Double Conditions


#Aggregate View
get '/protein/aggregateview' do
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

    #@all_proteins_autocomplete = Protein.all().map(&:name)
    @all_modifications = Modification.all().map(&:name)

    #Actual Processing  

    filter_protein = false
    filter_peptide = false
    filter_mod = false

    query_peptide = ""
    mod_db = nil

    query_parameters = Hash.new
    query_parameters[:offset]  = (page_number - 1) * PAGINATION_SIZE
    query_parameters[:limit]  = PAGINATION_SIZE

    count_parameters = Hash.new

    if protein.length > 2
        filter_protein = true
        query_parameters[:name] = protein
        count_parameters[:name] = protein
    end

    if peptide.length > 2
        query_peptide = "%" + peptide + "%"
        filter_peptide = true
        query_parameters[:peptideprotein] = PeptideProtein.all(:sequence.like => query_peptide)
        count_parameters[:peptideprotein] = PeptideProtein.all(:sequence.like => query_peptide)
    end

    if modification.length > 2
        filter_mod = true
        mod_db = Modification.first(:name => modification)
        query_parameters[:modificationprotein] = ModificationProtein.all(:modification => mod_db)
        count_parameters[:modificationprotein] = ModificationProtein.all(:modification => mod_db)
    end

    @all_proteins = Protein.all(query_parameters)
    @total_count = Protein.count(count_parameters)

    if (@next_page - 1) * PAGINATION_SIZE > @total_count
        @next_page = nil
    end

    return haml :protein_aggregate
end




### Deprecated Views

get '/protein/:protein/dataset/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    protein_db = Protein.first(:id => params[:protein])

    @datasets = protein_db.datasets(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    @protein_id = params[:protein]

    haml :protein_datasets
end