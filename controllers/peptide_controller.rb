#Aggregate View
get '/peptide/aggregateview' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)
    @page_number = page_number

    protein = params[:protein]
    peptide = params[:peptide]
    modification = params[:mod]

    sort_direction = params[:sort]
    sort_type = params[:sorttype]

    if protein == nil
        protein = ""
    end

    if peptide == nil
        peptide = ""
    end

    if modification == nil
        modification = ""
    end

    if sort_direction == nil
        sort_direction = ""
    end

    if sort_type == nil
        sort_type = ""
    end

    #Web Rendering Code
    @protein_input = protein
    @peptide_input = peptide
    @modification_input = modification

    @param_string = "protein=" + protein + "&peptide=" + peptide + "&mod=" + CGI.escape(modification)
    @sort_string = "&sort=" + sort_direction + "&sorttype=" + sort_type

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

    query_parameters = Hash.new
    query_parameters[:offset]  = (page_number - 1) * PAGINATION_SIZE
    query_parameters[:limit]  = PAGINATION_SIZE

    count_parameters = Hash.new

    if protein.length > 2
        filter_protein = true
        protein_db = Protein.first(:name => protein)
        query_parameters[:peptideprotein] = PeptideProtein.all(:protein => protein_db)
        count_parameters[:peptideprotein] = PeptideProtein.all(:protein => protein_db)
    end

    if peptide.length > 2
        filter_peptide = true
        query_peptide = "%" + peptide + "%"
        peptides_db = Peptide.all(:sequence.like => query_peptide)
        query_parameters[:sequence.like] = query_peptide
        count_parameters[:sequence.like] = query_peptide
    end

    if modification.length > 2
        filter_mod = true
        mod_db = Modification.first(:name => modification)
        query_parameters[:modificationpeptide] = ModificationPeptide.all(:modification => mod_db)
        count_parameters[:modificationpeptide] = ModificationPeptide.all(:modification => mod_db)
    end

    #Determining the sorting direction and for what field
    if sort_type == "sequence"
        if sort_direction == "up"
            query_parameters[:order] = [:sequence.desc]
        else
            query_parameters[:order] = [:sequence.asc]
        end
    end

    @all_peptides = Peptide.all(query_parameters)
    @total_count = Peptide.count(count_parameters)

    if (@next_page - 1) * PAGINATION_SIZE > @total_count
        @next_page = nil
    end

    return haml :peptide_aggregate


end
