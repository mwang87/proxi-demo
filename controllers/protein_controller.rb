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
    protein = params[:protein]
    peptide = params[:peptide]
    modification = params[:mod]

    filter_protein = false
    filter_peptide = false
    filter_mod = false


    if protein.length > 2
        filter_protein = true
    end

    if peptide.length > 2
        filter_peptide = true
    end

    if modification.length > 2
        filter_mod = true
    end

    #Now we do a big switch statement
    if filter_protein and filter_peptide and filter_mod

    end

    if filter_mod
        mod_db = Modification.first(:name => modification)
        datasetvariants_mod_db = DatasetVariant.all(:variant => mod_db.peptides.variants)
        psms = Datasetvariantspectrummatch.all(:DatasetVariant => datasetvariants_mod_db)
        @all_proteins = psms.DatasetProtein.protein

        return haml :protein_all
    end

    if filter_peptide
    	query_peptide = "%" + peptide + "%"
    	peptides_db = Peptide.all(:sequence.like => query_peptide)
        datasetvariants_peptide_db = DatasetVariant.all(:variant => peptides_db.variants)
        psms = Datasetvariantspectrummatch.all(:DatasetVariant => datasetvariants_peptide_db)
        @all_proteins = psms.DatasetProtein.protein

        return haml :protein_all
    end


end




### Deprecated Views

get '/protein/:protein/dataset/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    protein_db = Protein.first(:id => params[:protein])

    @datasets = protein_db.datasets(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    @protein_id = params[:protein]

    haml :protein_datasets
end