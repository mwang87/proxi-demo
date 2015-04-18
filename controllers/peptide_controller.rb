#Zero Conditions


#List all the basic peptides
get '/peptide/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    @all_peptides = Peptide.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    haml :peptide_all
end

#Single Conditions

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

    @all_peptides =  Peptide.all(
        :variants => mod_db.variants, 
        :offset => (page_number - 1) * PAGINATION_SIZE, 
        :limit => PAGINATION_SIZE)

    haml :peptide_all
end

get '/protein/:protein/peptide/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    protein_db = Protein.first(:id => params[:protein])

    psms = Datasetvariantspectrummatch.all(:DatasetProtein => DatasetProtein.all(:protein => protein_db))  

    variants_db = psms.DatasetVariant.variant

    @all_peptides = psms.DatasetVariant.variant.peptide

    @all_peptides = Peptide.all(:variants => variants_db)

    haml :peptide_all
end


#Double Conditions



#Aggregate View
get '/peptide/aggregateview' do
    protein = params[:protein]
    peptide = params[:peptide]
    modification = params[:mod]

    filter_protein = false
    filter_peptide = false
    filter_mod = false

    #DB Fields
    peptides_db = nil
    protein_db = nil
    mod_db = nil

    variants_protein_db = nil
    variants_mod_db = nil

    if protein.length > 2
        filter_protein = true
        protein_db = Protein.first(:name => protein)
        psms = Datasetvariantspectrummatch.all(:DatasetProtein => DatasetProtein.all(:protein => protein_db))  
        variants_protein_db = psms.DatasetVariant.variant
    end

    if peptide.length > 2
        filter_peptide = true
        query_peptide = "%" + peptide + "%"
        peptides_db = Peptide.all(:sequence.like => query_peptide)
    end

    if modification.length > 2
        filter_mod = true
        mod_db = Modification.first(:name => modification)
        variants_mod_db = mod_db.variants
    end

    #Now we do a big switch statement
    if filter_protein and filter_peptide and filter_mod
        @all_peptides = peptides_db.all(:variants => variants_protein_db & variants_mod_db)
        return haml :peptide_all
    end

    if filter_protein and filter_peptide
        @all_peptides = peptides_db.all(:variants => variants_protein_db)
        return haml :peptide_all
    end

    if filter_peptide and filter_mod
        @all_peptides = peptides_db.all(:variants => variants_mod_db)
        return haml :peptide_all
    end

    if filter_protein and filter_mod
        @all_peptides = Peptide.all(:variants => variants_protein_db & variants_mod_db)
        return haml :peptide_all
    end

    if filter_protein
        @all_peptides = Peptide.all(:variants => variants_protein_db)
        return haml :peptide_all
    end

    if filter_peptide
        @all_peptides = peptides_db
        return haml :peptide_all
    end

    if filter_mod
        @all_peptides = Peptide.all(:variants => variants_mod_db)
        #puts "variants size: " + mod_db.variants.length.to_s
        #@all_peptides = Peptide.all(:variants => mod_db.variants)
        return haml :peptide_all
    end

    return "MING"
end

