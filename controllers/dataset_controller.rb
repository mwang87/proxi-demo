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

    @datasets =  peptide_db.datasets

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

    @datasets = peptide_db.datasets & protein_db.datasets

    haml :dataset_plain_display
end


get '/peptide/:peptide/modification/:mod/dataset/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    peptide_db = Peptide.first(:sequence => params[:peptide])
    mod_db = Modification.first(:id => params[:mod])

    dataset_variants = DatasetVariant.all(:variant => mod_db.variants)

    @datasets =  dataset_variants.datasets & peptide_db.datasets

    haml :dataset_plain_display
end



#Aggregate View
get '/dataset/aggregateview' do
    protein = params[:protein]
    peptide = params[:peptide]
    modification = params[:mod]



    return "MING"
end





###OLD APIS

get '/dataset/list' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    @datasets = Dataset.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    haml :dataset_all
end


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
