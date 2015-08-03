
get '/dataset/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    @datasets = Dataset.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    haml :dataset_all
end


#Aggregate View
get '/dataset/aggregateview' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    sequence = params[:sequence]
    protein = params[:protein]
    peptide = params[:peptide]
    modification = params[:mod]

    if sequence == nil
        sequence = ""
    end

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
    @sequence_input = sequence
    @protein_input = protein
    @peptide_input = peptide
    @modification_input = modification

    @param_string = "protein=" + protein + "&peptide=" + peptide + "&mod=" + CGI.escape(modification) + "&sequence=" + sequence
    
    #@all_proteins = Protein.all().map(&:name)
    @all_modifications = Modification.all().map(&:name)

    #Actual Processing  

    filter_protein = false
    filter_peptide = false
    filter_mod = false

    #DB Fields
    peptide_db = nil
    protein_db = nil
    mod_db = nil

    query_parameters = Hash.new
    query_parameters[:offset]  = (page_number - 1) * PAGINATION_SIZE
    query_parameters[:limit]  = PAGINATION_SIZE

    count_parameters = Hash.new

    if protein.length > 2
        protein_db = Protein.first(:name => protein)
        query_parameters[:datasetprotein] = DatasetProtein.all(:protein => protein_db)
        count_parameters[:datasetprotein] = DatasetProtein.all(:protein => protein_db)
    end

    if peptide.length > 2
        query_peptide = "%" + peptide + "%"
        peptide_db = Peptide.all(:sequence.like => query_peptide)
        query_parameters[:datasetpeptide] = DatasetPeptide.all(:peptide => peptide_db)
        count_parameters[:datasetpeptide] = DatasetPeptide.all(:peptide => peptide_db)
    end

    if sequence.length > 2
        query_sequence = "%" + sequence + "%"
        psm_db = Peptidespectrummatch.all(:sequence.like => query_sequence)
        query_parameters[:peptidespectrummatch] = psm_db
        count_parameters[:peptidespectrummatch] = psm_db
    end

    if modification.length > 2
        mod_db = Modification.first(:name => modification)
        query_parameters[:datasetmodification] = DatasetModification.all(:modification => mod_db)
        count_parameters[:datasetmodification] = DatasetModification.all(:modification => mod_db)
    end

    @datasets = Dataset.all(query_parameters)
    @total_count = Dataset.count(count_parameters)

    if (@next_page - 1) * PAGINATION_SIZE > @total_count
        @next_page = nil
    end


    return haml :dataset_aggregate

end
