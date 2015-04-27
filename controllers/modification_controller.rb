

get '/modification/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    @all_modifications = Modification.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    haml :modification_all
end


get '/modification/aggregateview' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)
    @page_number = page_number

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

    #@all_proteins_autocomplete = Protein.all().map(&:name)
    @all_modifications = Modification.all().map(&:name)

    query_parameters = Hash.new
    query_parameters[:offset]  = (page_number - 1) * PAGINATION_SIZE
    query_parameters[:limit]  = PAGINATION_SIZE

    count_parameters = Hash.new

    if protein.length > 2
        protein_db = Protein.first(:name => protein)
        query_parameters[:modificationprotein] = ModificationProtein.all(:protein => protein_db)
        count_parameters[:modificationprotein] = ModificationProtein.all(:protein => protein_db)
    end

    if peptide.length > 2
        query_peptide = "%" + peptide + "%"
        peptides_db = Peptide.all(:sequence.like => query_peptide)
        query_parameters[:modificationpeptide] = ModificationPeptide.all(:peptide => peptides_db)
        count_parameters[:modificationpeptide] = ModificationPeptide.all(:peptide => peptides_db)
    end

    if modification.length > 2
        query_parameters[:name] = modification
        count_parameters[:name] = modification
    end

    @all_modifications_display = Modification.all(query_parameters)
    @total_count = Modification.count(count_parameters)


    haml :modification_aggregate
end