
#Given a mod, give me the datasets that have supporting information
get '/modification/:mod/dataset/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    mod_db = Modification.first(:id => params[:mod])

    #fix this
    @datasets =  Dataset.all(:variants => mod_db.variants)

    puts mod_db.variants
    puts @datasets

    haml :dataset_plain_display
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


#List all the basic peptides in a dataset
get '/peptide/:peptide/dataset/list' do
    query_peptide = params[:peptide]
    peptide_object = Basicpeptide.first(:sequence => query_peptide)
    
    if peptide_object == nil
        return "{}"
    end
    
    @datasets = peptide_object.datasets
    @peptide = query_peptide
    haml :peptide_datasets
end