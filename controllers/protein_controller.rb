#Zero Conditions

get '/protein/list' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    @all_proteins = Protein.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)
    
    haml :protein_all
end

#Single Conditions

get '/protein/:protein/dataset/list' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)

	protein_db = Protein.first(:id => params[:protein])

	@datasets = protein_db.datasets(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

	@protein_id = params[:protein]

	haml :protein_datasets
end


#Double Conditions