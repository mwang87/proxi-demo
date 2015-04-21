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

    query_peptide = ""
    mod_db = nil

    if protein.length > 2
        filter_protein = true
    end

    if peptide.length > 2
        query_peptide = "%" + peptide + "%"
        filter_peptide = true
    end

    if modification.length > 2
        filter_mod = true
        mod_db = Modification.first(:name => modification)
    end

    #Now we do a big switch statement
    if filter_protein and filter_peptide and filter_mod
        @all_proteins = Protein.all(
            :modificationprotein => ModificationProtein.all(:modification => mod_db),
            :peptideprotein => PeptideProtein.all(:sequence.like => query_peptide),
            :name => protein)
        return haml :protein_all
    end

    if filter_peptide and filter_mod
        @all_proteins = Protein.all(
            :modificationprotein => ModificationProtein.all(:modification => mod_db),
            :peptideprotein => PeptideProtein.all(:sequence.like => query_peptide))
        return haml :protein_all
    end

    if filter_protein and filter_mod
        @all_proteins = Protein.all(
            :modificationprotein => ModificationProtein.all(:modification => mod_db),
            :name => protein)
        return haml :protein_all
    end

    if filter_protein and filter_peptide
        @all_proteins = Protein.all(
            :peptideprotein => PeptideProtein.all(:sequence.like => query_peptide),
            :name => protein)
        return haml :protein_all
    end

    if filter_mod
        @all_proteins = Protein.all(:modificationprotein => ModificationProtein.all(:modification => mod_db))

        return haml :protein_all
    end

    if filter_peptide
        #puts PeptideProtein.all(:sequence.like => query_peptide)
        #puts "SEPARATOR"
        #puts PeptideProtein.all(:unique => true, :fields => [:protein_id], :sequence.like => query_peptide)
        #Likely need grouping for further optimization
        @all_proteins = Protein.all(:peptideprotein => PeptideProtein.all(:sequence.like => query_peptide))

        return haml :protein_all
    end

    if filter_protein
        @all_proteins = Protein.all(:name => protein)

        return haml :protein_all
    end

    ##Need to optimize peptide proteins 


end




### Deprecated Views

get '/protein/:protein/dataset/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    protein_db = Protein.first(:id => params[:protein])

    @datasets = protein_db.datasets(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    @protein_id = params[:protein]

    haml :protein_datasets
end