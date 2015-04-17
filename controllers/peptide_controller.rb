
#List all the basic peptides
get '/peptide/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    @all_peptides = Peptide.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    haml :peptide_all
end

#Gets all the peptides per dataset
get '/dataset/:dataset/peptide/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    dataset_db = Dataset.first(:id => params[:dataset])

    @all_peptides = dataset_db.peptide(:offset => (page_number - 1) * PAGINATION_SIZE, :limit => PAGINATION_SIZE,)

    haml :peptide_all
end

#Gets all the peptides with a given modification
get '/modification/:mod/peptide/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    mod_db = Modification.first(:id => params[:mod])

    @all_peptides =  Peptide.all(:variants => mod_db.variants, :offset => (page_number - 1) * PAGINATION_SIZE, :limit => PAGINATION_SIZE)

    haml :peptide_all
end

get '/protein/:protein/peptide/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    protein_db = Protein.first(:id => params[:protein])

    #protein_db
    return "WORK IN PROGRESS, UPDATE SCHEMA"
end

