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

    @param_string = "protein=" + protein + "&peptide=" + peptide + "&mod=" + modification

    #@all_proteins_autocomplete = Protein.all().map(&:name)
    @all_modifications = Modification.all().map(&:name)

    #Actual Processing  

    filter_protein = false
    filter_peptide = false
    filter_mod = false

    #DB Fields
    peptides_db = nil
    protein_db = nil
    mod_db = nil

    variants_protein_db = nil

    if protein.length > 2
        filter_protein = true
        protein_db = Protein.first(:name => protein)
    end

    if peptide.length > 2
        filter_peptide = true
        query_peptide = "%" + peptide + "%"
        peptides_db = Peptide.all(:sequence.like => query_peptide)
    end

    if modification.length > 2
        filter_mod = true
        mod_db = Modification.first(:name => modification)
    end

    #Now we do a big switch statement
    if filter_protein and filter_peptide and filter_mod
        @all_peptides = peptides_db.all(
            :peptideprotein => PeptideProtein.all(:protein => protein_db),
            :modificationpeptide => {:modification => mod_db},
            :offset => (page_number - 1) * PAGINATION_SIZE, 
            :limit => PAGINATION_SIZE)

        @total_count = peptides_db.count(
            :peptideprotein => PeptideProtein.count(:protein => protein_db),
            :modificationpeptide => {:modification => mod_db});


        return haml :peptide_aggregate
    end

    if filter_protein and filter_peptide
        @all_peptides = peptides_db.all(
            :peptideprotein => PeptideProtein.all(:protein => protein_db),
            :offset => (page_number - 1) * PAGINATION_SIZE, 
            :limit => PAGINATION_SIZE)

        @total_count = peptides_db.count(
            :peptideprotein => PeptideProtein.all(:protein => protein_db));

        return haml :peptide_aggregate
    end

    if filter_peptide and filter_mod
        @all_peptides = peptides_db.all(
            :modificationpeptide => {:modification => mod_db},
            :offset => (page_number - 1) * PAGINATION_SIZE, 
            :limit => PAGINATION_SIZE)

        @total_count = peptides_db.count(
            :modificationpeptide => {:modification => mod_db});

        return haml :peptide_aggregate
    end

    if filter_protein and filter_mod
        @all_peptides = Peptide.all(
            :peptideprotein => PeptideProtein.all(:protein => protein_db),
            :modificationpeptide => {:modification => mod_db},
            :offset => (page_number - 1) * PAGINATION_SIZE, 
            :limit => PAGINATION_SIZE)

        @total_count = Peptide.count(
            :peptideprotein => PeptideProtein.count(:protein => protein_db),
            :modificationpeptide => {:modification => mod_db})

        return haml :peptide_aggregate
    end

    if filter_protein
        @all_peptides = Peptide.all(
            :peptideprotein => PeptideProtein.all(:protein => protein_db),
            :offset => (page_number - 1) * PAGINATION_SIZE, 
            :limit => PAGINATION_SIZE)

        @total_count = Peptide.count(
            :peptideprotein => PeptideProtein.all(:protein => protein_db));

        return haml :peptide_aggregate
    end

    if filter_peptide
        @all_peptides = peptides_db.all(
            :offset => (page_number - 1) * PAGINATION_SIZE , 
            :limit => PAGINATION_SIZE)

        @total_count = peptides_db.count

        return haml :peptide_aggregate
    end

    if filter_mod
        @all_peptides = Peptide.all(
            :modificationpeptide => {:modification => mod_db},
            :offset => (page_number - 1) * PAGINATION_SIZE , 
            :limit => PAGINATION_SIZE)

        @total_count = Peptide.count(
            :modificationpeptide => {:modification => mod_db});

        return haml :peptide_aggregate
    end

    ###Need to write custom SQL to properly do the joins with modifications

    @all_peptides = Peptide.all(
            :offset => (page_number - 1) * PAGINATION_SIZE , 
            :limit => PAGINATION_SIZE)

    @total_count = Peptide.count

    return haml :peptide_aggregate
end

