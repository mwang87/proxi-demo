### ZERO CONDITIONS


get '/dataset/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    @datasets = Dataset.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    haml :dataset_all
end

### SINGLE CONDITIONS

#Given a mod, give me the datasets that have supporting information
get '/modification/:mod/dataset/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    mod_db = Modification.first(:id => params[:mod])

    dataset_variants = DatasetVariant.all(:variant => mod_db.variants)

    @datasets =  dataset_variants.datasets

    haml :dataset_plain_display
end

#Given a peptide, give me the datasets that have supporting information
get '/peptide/:peptide/dataset/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    peptide_db = Peptide.first(:sequence => params[:peptide])

    dataset_peptide_db = peptide_db.DatasetPeptide
    @datasets = Dataset.all(:DatasetPeptide => dataset_peptide_db)

    haml :dataset_plain_display
end

get '/protein/:protein/dataset/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    protein_db = Protein.first(:id => params[:protein])

    @datasets =  protein_db.datasets

    haml :dataset_plain_display
end

#DOUBLE CONDITIONS

#Get Datasets that have peptide on this protein
get '/protein/:protein/peptide/:peptide/dataset/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    peptide_db = Peptide.first(:sequence => params[:peptide])
    protein_db = Protein.first(:id => params[:protein])

    dataset_peptide_db = peptide_db.DatasetPeptide
    dataset_protein_db = protein_db.DatasetProtein
    @datasets = Dataset.all(:DatasetPeptide => dataset_peptide_db, :DatasetProtein => dataset_protein_db)

    haml :dataset_plain_display
end


get '/peptide/:peptide/modification/:mod/dataset/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    peptide_db = Peptide.first(:sequence => params[:peptide])
    mod_db = Modification.first(:id => params[:mod])

    dataset_variants_db = DatasetVariant.all(:variant => mod_db.variants)
    dataset_peptide_db = peptide_db.DatasetPeptide

    @datasets = Dataset.all(:DatasetPeptide => dataset_peptide_db, :DatasetVariant => dataset_variants_db)

    haml :dataset_plain_display
end



#Aggregate View
get '/dataset/aggregateview' do
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

    @param_string = "protein=" + protein + "&peptide=" + peptide + "&mod=" + CGI.escape(modification)
    
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
        filter_protein = true
        protein_db = Protein.first(:name => protein)
        query_parameters[:datasetprotein] = DatasetProtein.all(:protein => protein_db)
        count_parameters[:datasetprotein] = DatasetProtein.all(:protein => protein_db)
    end

    if peptide.length > 2
        filter_peptide = true
        query_peptide = "%" + peptide + "%"
        peptide_db = Peptide.first(:sequence.like => query_peptide)
        query_parameters[:datasetpeptide] = DatasetPeptide.all(:peptide => peptide_db)
        count_parameters[:datasetpeptide] = DatasetPeptide.all(:peptide => peptide_db)
    end

    if modification.length > 2
        filter_mod = true
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





###OLD APIS



get '/dataset/:datasetid/peptide/list' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)

	@all_peptides = Dataset.first(:id => params[:datasetid]).basicpeptides(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)
	@datasetid = params[:datasetid]

	haml :dataset_peptides
end

get '/dataset/:datasetid/protein/list' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)

	@proteins = Dataset.first(:id => params[:datasetid]).proteins(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)
	@datasetid = params[:datasetid]

	haml :dataset_proteins

end
