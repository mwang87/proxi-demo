get '/protein/list' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    @all_proteins = Protein.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)
    
    haml :protein_all
end

get '/protein/:protein/dataset/list' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)

	protein_db = Protein.first(:id => params[:protein])

	@datasets = protein_db.datasets(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

	haml :protein_datasets
end

#Probaby Not Supported
get '/protein/:protein/dataset/:dataset/peptide/list' do

end

get '/protein/:protein/peptide/list' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)

	protein_db = Protein.first(:id => params[:protein])

	#protein_db
	return "WORK IN PROGRESS, UPDATE SCHEMA"
end

